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
$AndroidStudioJdk = 'C:/Program Files/Android/Android Studio/jbr'
if (-not $env:JAVA_HOME -and (Test-Path -LiteralPath (Join-Path $AndroidStudioJdk 'bin/java.exe'))) {
    $env:JAVA_HOME = $AndroidStudioJdk
    $env:PATH = (Join-Path $AndroidStudioJdk 'bin') + [IO.Path]::PathSeparator + $env:PATH
}
$ProjectNdk = Join-Path $ProjectRoot '.local/tools/android-sdk/ndk/28.2.13676358'
if (Test-Path -LiteralPath (Join-Path $ProjectNdk 'source.properties')) {
    $env:ANDROID_HOME = Join-Path $ProjectRoot '.local/tools/android-sdk'
    $env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
    $env:ANDROID_NDK_HOME = $ProjectNdk
    $env:ANDROID_NDK_ROOT = $ProjectNdk
}
foreach ($CacheDir in @($env:GOMODCACHE, $env:GOCACHE, $env:GOPATH, $env:PUB_CACHE, $env:GRADLE_USER_HOME, $env:TEMP)) {
    New-Item -ItemType Directory -Force -Path $CacheDir | Out-Null
}
