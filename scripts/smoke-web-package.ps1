param([Parameter(Mandatory=$true)][string]$Package)
$ErrorActionPreference='Stop'
$Root=Split-Path -Parent $PSScriptRoot
$packagePath=(Resolve-Path -LiteralPath $Package).Path
$temporaryRoot=(Resolve-Path -LiteralPath (Join-Path $Root '.local/tmp')).Path
$target=Join-Path $temporaryRoot ('release-smoke-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $target | Out-Null
try {
 Expand-Archive -LiteralPath $packagePath -DestinationPath $target
 if(-not (Test-Path -LiteralPath (Join-Path $target 'release.json'))){throw 'Package has no release.json'}
 & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'smoke-web.ps1') -WebRoot $target -ProfileRoot (Join-Path $target 'browser-profile')
 if($LASTEXITCODE -ne 0){throw 'Packaged web smoke failed'}
 Write-Host 'PACKAGED WEB SMOKE PASS'
} finally {
 if(Test-Path -LiteralPath $target){
  $resolvedTarget=(Resolve-Path -LiteralPath $target).Path
  if(-not $resolvedTarget.StartsWith($temporaryRoot + [IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Refusing to remove a path outside .local/tmp'}
  Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
 }
}
