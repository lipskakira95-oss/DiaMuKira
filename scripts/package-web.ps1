param(
 [string]$ApiBaseUrl='',
 [switch]$OfflineOnly,
 [switch]$SameOriginApi
)
$ErrorActionPreference='Stop'
$Root=Split-Path -Parent $PSScriptRoot
$metadata=Get-Content (Join-Path $Root 'release/release.json') -Raw -Encoding utf8 | ConvertFrom-Json
if(@($ApiBaseUrl -ne '',[bool]$OfflineOnly,[bool]$SameOriginApi).Where({$_}).Count -ne 1){
 throw 'Choose exactly one: -ApiBaseUrl https://..., -SameOriginApi, or -OfflineOnly'
}
$buildArguments=@('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $PSScriptRoot 'build-web.ps1'))
if($ApiBaseUrl){$buildArguments += @('-ApiBaseUrl',$ApiBaseUrl)}
if($OfflineOnly){$buildArguments += '-OfflineOnly'}
& powershell @buildArguments
if($LASTEXITCODE -ne 0){throw 'Web build failed'}

$safeVersion=$metadata.version -replace '[^0-9A-Za-z.-]','-'
$name="diia-my-web-$safeVersion-$($metadata.release_channel)"
$releaseRoot=Join-Path $Root '.local/release'
$staging=Join-Path $releaseRoot $name
$archive=Join-Path $releaseRoot ($name + '.zip')
New-Item -ItemType Directory -Force -Path $releaseRoot | Out-Null
if((Test-Path -LiteralPath $staging) -or (Test-Path -LiteralPath $archive)){
 throw "Release output already exists: $name"
}
New-Item -ItemType Directory -Path $staging | Out-Null
Copy-Item -Path (Join-Path $Root 'apps/quiz/build/web/*') -Destination $staging -Recurse
Copy-Item -LiteralPath (Join-Path $Root 'release/release.json') -Destination (Join-Path $staging 'release.json')
Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $archive -CompressionLevel Optimal
$hash=(Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
"$hash  $([IO.Path]::GetFileName($archive))" | Set-Content -LiteralPath ($archive + '.sha256') -Encoding ascii
Write-Host "Web package: $archive"
Write-Host "SHA256: $hash"
