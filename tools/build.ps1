$ErrorActionPreference="Stop"
function HtmlEscape([string]$s){ if($null -eq $s){return ""}; return [System.Net.WebUtility]::HtmlEncode($s) }
$root = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$site = Join-Path $root "site"
$out = Join-Path $root "_site"
if(Test-Path $out){ Remove-Item -Recurse -Force $out }
New-Item -ItemType Directory -Force $out | Out-Null
Copy-Item -Recurse -Force (Join-Path $site "*") $out
New-Item -ItemType Directory -Force (Join-Path $out "pages") | Out-Null
$cfgPath = Join-Path $root "data\config.json"
$scoresPath = Join-Path $root "data\scores.csv"
$cfg = $null; if(Test-Path $cfgPath){ $cfg = Get-Content -Raw $cfgPath | ConvertFrom-Json }
$scoresCount = 0; if(Test-Path $scoresPath){ try{ $scores = Import-Csv $scoresPath; $scoresCount = @($scores).Count } catch { $scoresCount = -1 } }
$now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
 $pagesUrl = ""; if($cfg -and $cfg.pagesUrl){ $pagesUrl = [string]$cfg.pagesUrl }
 $gradesCount = 0; $groupsCount = 0; $teachersCount = 0; if($cfg -and $cfg.entities){ if($cfg.entities.grades){$gradesCount=@($cfg.entities.grades).Count}; if($cfg.entities.groups){$groupsCount=@($cfg.entities.groups).Count}; if($cfg.entities.teachers){$teachersCount=@($cfg.entities.teachers).Count} }
$html = @()
$html += "<!doctype html><html lang='he' dir='rtl'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>מצב מערכת — sefer2</title><link rel='stylesheet' href='../css/style.css'></head><body>"
$html += "<header class='top' style='padding:18px 16px;border-radius:16px;margin:16px auto;max-width:1100px'><div style='display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap'><div><h1 style='margin:0;font-size:22px'>מצב מערכת</h1><div class='sub'>דף תמידי שמופק אוטומטית בזמן Build מתוך data/*</div></div><div class='mono' style='opacity:.9'>$now</div></div></header>"
$html += "<main style='max-width:1100px;margin:0 auto;padding:0 16px 24px'>"
$html += "<section class='card'><h2 style='margin-top:0'>מקור אמת</h2><div class='kv'><div class='mono'>data/config.json</div><div>הגדרות ישויות/קבוצות/מורים (אמיתי בלבד)</div></div><div class='kv'><div class='mono'>data/scores.csv</div><div>ציונים לאירועים (אמיתי בלבד)</div></div></section>"
$html += "<section class='card'><h2 style='margin-top:0'>סטטוס נתונים</h2><div class='kv'><div class='mono'>Grades</div><div>$gradesCount</div></div><div class='kv'><div class='mono'>Groups</div><div>$groupsCount</div></div><div class='kv'><div class='mono'>Teachers</div><div>$teachersCount</div></div><div class='kv'><div class='mono'>Scores rows</div><div>$scoresCount</div></div></section>"
$html += "<section class='card'><h2 style='margin-top:0'>קישורים</h2><div><a href='../index.html'>⬅ חזרה לדף הראשי</a></div>"
if($pagesUrl -ne ""){ $html += "<div style='margin-top:10px' class='mono'>"+(HtmlEscape($pagesUrl))+"</div>" }
$html += "</section>"
$html += "<section class='card'><h2 style='margin-top:0'>כללים מחייבים</h2><div>כל שינוי מהותי בפרויקט חייב להיות מתועד גם ב־<span class='mono'>spec/klalim.md</span> וגם כאן בדף מצב מערכת (נוצר אוטומטית).</div></section>"
$html += "</main><footer>GitHub הוא מקור האמת · אין דמו</footer></body></html>"
$outState = Join-Path $out "pages\state.html"
$html -join "`n" | Set-Content -Encoding utf8 $outState
Write-Host "Built _site + pages/state.html" -ForegroundColor Green

# === Generate pages from config (grades/groups/teachers) ===
$outGrades = Join-Path $out "grades"; New-Item -ItemType Directory -Force $outGrades | Out-Null
$outGroups = Join-Path $out "groups"; New-Item -ItemType Directory -Force $outGroups | Out-Null
$outTeachers = Join-Path $out "teachers"; New-Item -ItemType Directory -Force $outTeachers | Out-Null

function Slug([string]$s){
  if([string]::IsNullOrWhiteSpace($s)){ return "" }
  $x = $s.Trim() -replace "\s+","-"
  return [System.Uri]::EscapeDataString($x)
}

# grades
foreach($g in @($cfg.entities.grades)){
  $gid = [string]$g.id; $gname = HtmlEscape([string]$g.name)
  $htmlG = @()
  $htmlG += "<!doctype html><html lang='he' dir='rtl'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>$gname</title><link rel='stylesheet' href='../css/style.css'></head><body>"
  $htmlG += "<header class='top' style='padding:14px 16px;border-radius:16px;margin:16px auto;max-width:1100px'><h1 style='margin:0'>$gname</h1><div class='sub'>בחירת קבוצה</div></header><main style='max-width:1100px;margin:0 auto;padding:0 16px 24px'>"
  foreach($grp in @($cfg.entities.groups) | Where-Object { [string]$_.grade -eq $gid }){
    $id=[string]$grp.id; $nm=HtmlEscape([string]$grp.name); $t=HtmlEscape([string]$grp.teacher)
    $htmlG += "<section class='card'><div style='display:flex;justify-content:space-between;gap:10px;flex-wrap:wrap;align-items:center'><div><div style='font-weight:800'>$nm</div><div class='sub'>מורה: "+( if([string]::IsNullOrWhiteSpace($t)){"טרם הוגדר"}else{$t})+"</div></div><a class='btn' href='../groups/$id.html'>כניסה</a></div></section>"
  }
  $htmlG += "<section class='card'><a href='../index.html'>⬅ חזרה</a></section></main><footer>GitHub הוא מקור האמת · אין דמו</footer></body></html>"
  ($htmlG -join "
") | Set-Content -Encoding utf8 (Join-Path $outGrades "$gid.html")
}

# groups
foreach($grp in @($cfg.entities.groups)){
  $id=[string]$grp.id; $nm=HtmlEscape([string]$grp.name); $gid=HtmlEscape([string]$grp.grade); $t=HtmlEscape([string]$grp.teacher)
  $tShow = if([string]::IsNullOrWhiteSpace($t)){"טרם הוגדר"}else{$t}
  $htmlP = @()
  $htmlP += "<!doctype html><html lang='he' dir='rtl'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>$nm</title><link rel='stylesheet' href='../css/style.css'></head><body>"
  $htmlP += "<header class='top' style='padding:14px 16px;border-radius:16px;margin:16px auto;max-width:1100px'><h1 style='margin:0'>$nm</h1><div class='sub'>שכבה: $gid · מורה: $tShow</div></header><main style='max-width:1100px;margin:0 auto;padding:0 16px 24px'>"
  $htmlP += "<section class='card'><h2 style='margin-top:0'>פעולות</h2><div style='display:flex;gap:10px;flex-wrap:wrap'><a class='btn' href='../grades/$gid.html'>חזרה לשכבה</a><a class='btn' href='../pages/state.html'>מצב מערכת</a></div></section>"
  $htmlP += "<section class='card'><h2 style='margin-top:0'>ציונים (scores.csv)</h2><div class='sub'>כאן נציג אירועים אמיתיים מקובץ data/scores.csv (בשלב הבא).</div></section>"
  $htmlP += "</main><footer>GitHub הוא מקור האמת · אין דמו</footer></body></html>"
  ($htmlP -join "
") | Set-Content -Encoding utf8 (Join-Path $outGroups "$id.html")
}

# teachers index
$htmlT = @()
$htmlT += "<!doctype html><html lang='he' dir='rtl'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>מורים</title><link rel='stylesheet' href='../css/style.css'></head><body>"
$htmlT += "<header class='top' style='padding:14px 16px;border-radius:16px;margin:16px auto;max-width:1100px'><h1 style='margin:0'>מורים</h1><div class='sub'>רשימה מתוך data/config.json</div></header><main style='max-width:1100px;margin:0 auto;padding:0 16px 24px'>"
foreach($t in @($cfg.entities.teachers)){
  $n=[string]$t.name; $slug = Slug $n
  $htmlT += "<section class='card'><div style='display:flex;justify-content:space-between;gap:10px;align-items:center;flex-wrap:wrap'><div style='font-weight:800'>"+(HtmlEscape $n)+"</div><a class='btn' href='./$slug.html'>כניסה</a></div></section>"
  $htmlOne = @()
  $htmlOne += "<!doctype html><html lang='he' dir='rtl'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>"+(HtmlEscape $n)+"</title><link rel='stylesheet' href='../css/style.css'></head><body>"
  $htmlOne += "<header class='top' style='padding:14px 16px;border-radius:16px;margin:16px auto;max-width:1100px'><h1 style='margin:0'>"+(HtmlEscape $n)+"</h1><div class='sub'>דף מורה (מינימלי, נתונים אמיתיים בהמשך)</div></header><main style='max-width:1100px;margin:0 auto;padding:0 16px 24px'>"
  $htmlOne += "<section class='card'><a class='btn' href='./index.html'>⬅ חזרה לרשימת מורים</a></section>"
  $htmlOne += "</main><footer>GitHub הוא מקור האמת · אין דמו</footer></body></html>"
  ($htmlOne -join "
") | Set-Content -Encoding utf8 (Join-Path $outTeachers "$slug.html")
}
$htmlT += "<section class='card'><a href='../index.html'>⬅ חזרה לדף הראשי</a></section></main><footer>GitHub הוא מקור האמת · אין דמו</footer></body></html>"
($htmlT -join "
") | Set-Content -Encoding utf8 (Join-Path $outTeachers "index.html")
