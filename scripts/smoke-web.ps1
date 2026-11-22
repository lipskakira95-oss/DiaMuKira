param(
 [string]$WebRoot='',
 [string]$ProfileRoot=''
)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$WebRoot=if($WebRoot){(Resolve-Path -LiteralPath $WebRoot).Path}else{Join-Path $ProjectRoot 'apps/quiz/build/web'}
$ProfileRoot=if($ProfileRoot){$ProfileRoot}else{Join-Path $ProjectRoot '.local/browser-smoke'}
$LogDir=Join-Path $ProjectRoot '.local/logs'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$Listener=New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback,0)
$Listener.Start();$Port=$Listener.LocalEndpoint.Port;$Listener.Stop()
$Api=Join-Path $ProjectRoot '.local/build/api.exe'
$Arguments=@('-db',(Join-Path $ProjectRoot '.local/data/quiz.sqlite'),'-web',$WebRoot,'-addr',"127.0.0.1:$Port",'-allow-draft')
$Process=Start-Process -FilePath $Api -ArgumentList $Arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $LogDir 'web-smoke.stdout.log') -RedirectStandardError (Join-Path $LogDir 'web-smoke.stderr.log')
try {
 $Ready=$false
 for($Attempt=0;$Attempt -lt 30;$Attempt++){
  try {if((Invoke-RestMethod "http://127.0.0.1:$Port/health" -TimeoutSec 2).status -eq 'ok'){$Ready=$true;break}}catch{Start-Sleep -Milliseconds 200}
 }
 if(-not $Ready){throw 'Web/API server failed to start'}
 $Browsers=@(
  @{Name='Chrome';Path='C:/Program Files/Google/Chrome/Application/chrome.exe';Profile=($ProfileRoot + '-chrome')},
  @{Name='Edge';Path='C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe';Profile=($ProfileRoot + '-edge')}
 )
 foreach($Browser in $Browsers){
  if(-not (Test-Path $Browser.Path)){throw ($Browser.Name + ' is required for the web quality matrix')}
  Write-Output ('Running web smoke in ' + $Browser.Name)
  & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'smoke-browser.ps1') -Url "http://127.0.0.1:$Port/" -Chrome $Browser.Path -Profile $Browser.Profile
  if($LASTEXITCODE -ne 0){throw ($Browser.Name + ' end-to-end web smoke failed')}
 }
}finally{
 if(-not $Process.HasExited){$Process.Kill();$Process.WaitForExit()}
}
