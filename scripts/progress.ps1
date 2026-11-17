param([int]$IntervalSeconds=180, [switch]$Once)
$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$StateFile = Join-Path $ProjectRoot '.local/progress/state.json'
$EventsFile = Join-Path $ProjectRoot '.local/progress/events.jsonl'
New-Item -ItemType Directory -Force -Path (Split-Path $StateFile) | Out-Null
$Started = Get-Date
$NextEvent = $Started.AddSeconds($IntervalSeconds)
do {
    if (Test-Path -LiteralPath $StateFile) {
        $State = Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($State.stop) { break }
    } else { $State = @{stage='unknown';status='No state recorded'} }
    if ($Once -or (Get-Date) -ge $NextEvent) {
        $CacheRoot = Join-Path $ProjectRoot '.local/cache'
        $CacheBytes = (Get-ChildItem -LiteralPath $CacheRoot -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        $Event = [ordered]@{time=(Get-Date).ToUniversalTime().ToString('o');stage=$State.stage;status=$State.status;elapsed_seconds=[int]((Get-Date)-$Started).TotalSeconds;cache_mb=[math]::Round($CacheBytes/1MB,1);tokens='not measured';ram='not measured'}
        $Line = $Event | ConvertTo-Json -Compress
        Add-Content -LiteralPath $EventsFile -Value $Line -Encoding UTF8
        Write-Output $Line
        $NextEvent = (Get-Date).AddSeconds($IntervalSeconds)
    }
    if (-not $Once) { Start-Sleep -Seconds 5 }
} while (-not $Once)
