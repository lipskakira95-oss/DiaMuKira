$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$LogDir=Join-Path $ProjectRoot '.local/logs'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$Listener=New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback,0)
$Listener.Start();$Port=$Listener.LocalEndpoint.Port;$Listener.Stop()
$Api=Join-Path $ProjectRoot '.local/build/api.exe'
$Arguments=@('-db',(Join-Path $ProjectRoot '.local/data/quiz.sqlite'),'-web',(Join-Path $ProjectRoot 'apps/quiz/build/web'),'-addr',"127.0.0.1:$Port",'-allow-draft')
$Process=Start-Process -FilePath $Api -ArgumentList $Arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $LogDir 'web-smoke.stdout.log') -RedirectStandardError (Join-Path $LogDir 'web-smoke.stderr.log')
try {
 $Ready=$false
 for($Attempt=0;$Attempt -lt 30;$Attempt++){
  try {if((Invoke-RestMethod "http://127.0.0.1:$Port/health" -TimeoutSec 2).status -eq 'ok'){$Ready=$true;break}}catch{Start-Sleep -Milliseconds 200}
 }
 if(-not $Ready){throw 'Web/API server failed to start'}
 & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'smoke-browser.ps1') -Url "http://127.0.0.1:$Port/"
 if($LASTEXITCODE -ne 0){throw 'End-to-end web smoke failed'}
}finally{
 if(-not $Process.HasExited){$Process.Kill();$Process.WaitForExit()}
}
