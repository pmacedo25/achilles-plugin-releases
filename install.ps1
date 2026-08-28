Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$OutputEncoding = [System.Text.Encoding]::UTF8

$channel = if ($env:ACHILLES_CHANNEL) { $env:ACHILLES_CHANNEL.Trim().ToLowerInvariant() } else { 'stable' }
if ($channel -notin @('stable', 'beta')) { throw "Unsupported ACHILLES_CHANNEL '$channel'. Use stable or beta." }
$manifestName = if ($channel -eq 'beta') { 'latest-beta.json' } else { 'latest.json' }
$cacheBuster = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
$manifestUrl = "https://raw.githubusercontent.com/pmacedo25/achilles-plugin-releases/main/$manifestName`?cb=$cacheBuster"
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
    Write-Host "Achilles: reading the public $channel manifest..."
    $manifest = Invoke-RestMethod -Uri $manifestUrl -Headers @{ 'Cache-Control' = 'no-cache' }
    if (-not $manifest.version -or -not $manifest.downloadUrl) { throw 'The release manifest is invalid.' }
    $downloadUrl = [string]$manifest.downloadUrl
    if (-not $downloadUrl.StartsWith($allowedDownloadPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'The manifest points to an unexpected download location.'
    }

    $ide = Resolve-IdeCommand
    Write-Host "Achilles: downloading version $($manifest.version)..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $temporaryFile -UseBasicParsing
    if ((Get-Item -LiteralPath $temporaryFile).Length -lt 1MB) { throw 'The downloaded VSIX is unexpectedly small.' }

    $tag = "v$($manifest.version)"
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$releaseRepository/releases/tags/$tag"
    $assetName = Split-Path -Leaf $downloadUrl
    $asset = @($release.assets) | Where-Object { $_.name -eq $assetName } | Select-Object -First 1
    if (-not $asset) { throw 'The VSIX is not present in the official GitHub release.' }
    if ($asset.digest -and ([string]$asset.digest).StartsWith('sha256:')) {
        $expectedHash = ([string]$asset.digest).Substring(7)
        $actualHash = (Get-FileHash -LiteralPath $temporaryFile -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actualHash -ne $expectedHash.ToLowerInvariant()) { throw 'The VSIX integrity check failed.' }
    }

    Write-Host "Achilles: installing with '$ide'..."
    & $ide --install-extension $temporaryFile --force
    if ($LASTEXITCODE -ne 0) { throw "The IDE installer exited with code $LASTEXITCODE." }
    Write-Host "Achilles $($manifest.version) installed. Reload the IDE to activate it."
}
finally {
    if (Test-Path -LiteralPath $temporaryFile) { Remove-Item -LiteralPath $temporaryFile -Force }
}
