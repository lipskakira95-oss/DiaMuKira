$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$LogDir = Join-Path $ProjectRoot '.local/logs'
$DataDir = Join-Path $ProjectRoot '.local/data'
New-Item -ItemType Directory -Force -Path $LogDir,$DataDir | Out-Null
$DatabasePath = Join-Path $DataDir 'quiz.sqlite'
$Importer = Join-Path $ProjectRoot '.local/build/contentimport.exe'
$Api = Join-Path $ProjectRoot '.local/build/api.exe'
& $Importer -csv (Join-Path $ProjectRoot 'content/questions.uk.csv') -db $DatabasePath
if ($LASTEXITCODE -ne 0) { throw 'CSV import failed' }

$Socket = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, 0)
$Socket.Start()
$Port = $Socket.LocalEndpoint.Port
$Socket.Stop()
$Arguments = @('-db', $DatabasePath, '-addr', "127.0.0.1:$Port", '-allow-draft')
$Process = Start-Process -FilePath $Api -ArgumentList $Arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $LogDir 'api.stdout.log') -RedirectStandardError (Join-Path $LogDir 'api.stderr.log')
try {
    $Healthy = $false
    for ($Attempt = 0; $Attempt -lt 30; $Attempt++) {
        try {
            $Health = Invoke-RestMethod "http://127.0.0.1:$Port/health" -TimeoutSec 2
            if ($Health.status -eq 'ok') { $Healthy = $true; break }
        } catch { Start-Sleep -Milliseconds 200 }
    }
    if (-not $Healthy) { throw 'API did not become healthy' }
    $Content = Invoke-RestMethod "http://127.0.0.1:$Port/api/v1/content" -TimeoutSec 5
    if ($Content.questions.Count -ne 152 -or $Content.mode -ne 'draft') { throw 'Unexpected content response' }
    $Content.questions | Group-Object category_id | Select-Object Name,Count
    $Version = Invoke-RestMethod "http://127.0.0.1:$Port/api/v1/content/version" -TimeoutSec 5
    if ($Version.content_version -ne 'draft-1') { throw 'Unexpected content version' }
    Write-Output 'SMOKE PASS: CSV -> SQLite -> running HTTP API -> 152 draft questions'
} finally {
    if (-not $Process.HasExited) { $Process.Kill(); $Process.WaitForExit() }
}
