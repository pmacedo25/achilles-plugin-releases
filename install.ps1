Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$OutputEncoding = [System.Text.Encoding]::UTF8

$channel = if ($env:ACHILLES_CHANNEL) { $env:ACHILLES_CHANNEL.Trim().ToLowerInvariant() } else { 'stable' }
if ($channel -notin @('stable', 'beta')) { throw "Unsupported ACHILLES_CHANNEL '$channel'. Use stable or beta." }
$releaseRepository = 'pmacedo25/achilles-plugin-releases'
$allowedDownloadPrefix = "https://github.com/$releaseRepository/releases/download/"
$temporaryFile = Join-Path ([System.IO.Path]::GetTempPath()) "achilles-$([guid]::NewGuid().ToString('N')).vsix"

function Resolve-IdeCommand {
    $requested = if ($env:ACHILLES_IDE) { $env:ACHILLES_IDE.Trim().ToLowerInvariant() } else { '' }
    $supported = if ($requested) { @($requested) } else { @('code', 'cursor', 'codium') }
    foreach ($candidate in $supported) {
        if ($candidate -notin @('code', 'cursor', 'codium')) {
            throw "Unsupported ACHILLES_IDE '$candidate'. Use code, cursor, or codium."
        }
        if (Get-Command $candidate -ErrorAction SilentlyContinue) { return $candidate }
    }
    throw 'No supported IDE CLI was found. Add code, cursor, or codium to PATH and try again.'
}

try {
    Write-Host "Achilles: reading the public $channel release channel..."
    if ($channel -eq 'beta') {
        $releases = Invoke-RestMethod -Uri "https://api.github.com/repos/$releaseRepository/releases?per_page=30"
        $release = $releases | Where-Object { $_.prerelease -and -not $_.draft -and $_.tag_name -match '-beta$' } | Select-Object -First 1
    }
    else {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$releaseRepository/releases/latest"
    }
    if (-not $release -or -not $release.tag_name) { throw "No published $channel release was found." }

    $version = ([string]$release.tag_name).TrimStart('v')
    $expectedAssetName = "achilles-plugin-$version.vsix"
    $asset = @($release.assets) | Where-Object { $_.name -eq $expectedAssetName } | Select-Object -First 1
    if (-not $asset) { throw "The expected VSIX '$expectedAssetName' is not present in the official GitHub release." }
    $downloadUrl = [string]$asset.browser_download_url
    if (-not $downloadUrl.StartsWith($allowedDownloadPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'The release points to an unexpected download location.'
    }

    $ide = Resolve-IdeCommand
    Write-Host "Achilles: downloading version $version..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $temporaryFile -UseBasicParsing
    if ((Get-Item -LiteralPath $temporaryFile).Length -lt 1MB) { throw 'The downloaded VSIX is unexpectedly small.' }

    if ($asset.digest -and ([string]$asset.digest).StartsWith('sha256:')) {
        $expectedHash = ([string]$asset.digest).Substring(7)
        $actualHash = (Get-FileHash -LiteralPath $temporaryFile -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actualHash -ne $expectedHash.ToLowerInvariant()) { throw 'The VSIX integrity check failed.' }
    }

    Write-Host "Achilles: installing with '$ide'..."
    & $ide --install-extension $temporaryFile --force
    if ($LASTEXITCODE -ne 0) { throw "The IDE installer exited with code $LASTEXITCODE." }
    Write-Host "Achilles $version installed. Reload the IDE to activate it."
}
finally {
    if (Test-Path -LiteralPath $temporaryFile) { Remove-Item -LiteralPath $temporaryFile -Force }
}
