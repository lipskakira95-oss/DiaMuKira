param([string]$SourceSdk='C:/src')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$TargetSdk=Join-Path $ProjectRoot '.local/tools/flutter'
New-Item -ItemType Directory -Force -Path $TargetSdk | Out-Null
# Copy, never link or move: SDK tools must write only inside this project.
& robocopy $SourceSdk $TargetSdk /E /XJ /R:1 /W:1 /NFL /NDL /NJH /NJS /NP /XD agent-artifacts .idea .vscode .agents .claude .gemini
if ($LASTEXITCODE -ge 8) { throw 'Local Flutter SDK copy failed' }
Write-Output "Local Flutter SDK: $TargetSdk"
