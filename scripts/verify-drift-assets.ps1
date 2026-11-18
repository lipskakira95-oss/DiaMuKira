$ErrorActionPreference='Stop'
$Root=Split-Path -Parent $PSScriptRoot
$Expected=@{
 'apps/quiz/web/drift_worker.js'='48C950CD8E3BC3CDDB34816C860E228BE8832BEF07A297C27E9907C057FF8162'
 'apps/quiz/web/sqlite3.wasm'='E7451780E78C56FF864FE9317A0FBCD6AEB2E8DE3BEBA7F5EFD963202F7EC3D9'
}
foreach($RelativePath in $Expected.Keys){
 $Path=Join-Path $Root $RelativePath
 if(-not (Test-Path -LiteralPath $Path)){throw "Missing Drift web asset: $RelativePath"}
 $Actual=(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
 if($Actual -ne $Expected[$RelativePath]){throw "Unexpected SHA256 for $RelativePath`: $Actual"}
 Write-Output "Verified $RelativePath ($Actual)"
}
