# Regenerates assets/manifest.json: the list the loading screen downloads and caches on first visit.
# Run it after adding, removing or replacing files in assets/:
#   powershell -ExecutionPolicy Bypass -File tools/make-manifest.ps1
$root = Split-Path -Parent $PSScriptRoot
$assets = Join-Path $root 'assets'
$skip = '\.(txt|md)$'   # licences/readmes are not needed at runtime
$files = Get-ChildItem $assets -Recurse -File | Where-Object { $_.Name -ne 'manifest.json' -and $_.Name -notmatch $skip } | Sort-Object FullName
$list = foreach ($f in $files) {
  $rel = 'assets/' + $f.FullName.Substring($assets.Length + 1).Replace('\', '/')
  [ordered]@{ u = $rel; s = $f.Length }
}
# version = hash of every path+size, so the loading screen re-downloads only when something changed
$sha = [System.Security.Cryptography.SHA1]::Create()
$sig = ($list | ForEach-Object { $_.u + ':' + $_.s }) -join '|'
$v = -join ($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($sig)) | Select-Object -First 6 | ForEach-Object { $_.ToString('x2') })
$total = [long]0; foreach ($e in $list) { $total += $e.s }
$json = [ordered]@{ v = $v; total = $total; files = @($list) } | ConvertTo-Json -Depth 4 -Compress
[IO.File]::WriteAllText((Join-Path $assets 'manifest.json'), $json, (New-Object Text.UTF8Encoding $false))
Write-Host ("manifest: {0} files, {1:N1} MB, v={2}" -f $list.Count, ($total / 1MB), $v)
