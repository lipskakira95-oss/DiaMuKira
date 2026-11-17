$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$env:GOMODCACHE = Join-Path $ProjectRoot '.local/cache/go-mod'
$env:GOCACHE = Join-Path $ProjectRoot '.local/cache/go-build'
$env:GOPATH = Join-Path $ProjectRoot '.local/tools/go'
$env:GOTOOLCHAIN = 'local'
$env:PUB_CACHE = Join-Path $ProjectRoot '.local/cache/pub'
$env:GRADLE_USER_HOME = Join-Path $ProjectRoot '.local/cache/gradle'
$env:TEMP = Join-Path $ProjectRoot '.local/tmp'
$env:TMP = $env:TEMP
$env:TMPDIR = $env:TEMP
foreach ($CacheDir in @($env:GOMODCACHE, $env:GOCACHE, $env:GOPATH, $env:PUB_CACHE, $env:GRADLE_USER_HOME, $env:TEMP)) {
    New-Item -ItemType Directory -Force -Path $CacheDir | Out-Null
}
