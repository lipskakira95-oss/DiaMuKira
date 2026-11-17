param([Parameter(ValueFromRemainingArguments=$true)][string[]]$FlutterArguments)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$env:FLUTTER_SUPPRESS_ANALYTICS='true'
$env:DART_SUPPRESS_ANALYTICS='true'
$env:APPDATA=Join-Path $ProjectRoot '.local/config/appdata'
$env:LOCALAPPDATA=Join-Path $ProjectRoot '.local/cache/localappdata'
$env:XDG_CONFIG_HOME=Join-Path $ProjectRoot '.local/config'
New-Item -ItemType Directory -Force -Path $env:APPDATA,$env:LOCALAPPDATA | Out-Null
$FlutterExecutable=Join-Path $ProjectRoot '.local/tools/flutter/bin/flutter.bat'
if (-not (Test-Path -LiteralPath $FlutterExecutable)) { throw 'Run scripts/bootstrap-flutter.ps1 first' }
& $FlutterExecutable @FlutterArguments
exit $LASTEXITCODE
