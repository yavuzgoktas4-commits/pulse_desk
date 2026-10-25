$ErrorActionPreference = "Continue"
$env:PATH = "C:\Users\pc\scoop\apps\ruby\current\bin;C:\Users\pc\scoop\apps\ruby\current\gems\bin;C:\Users\pc\scoop\apps\postgresql\current\bin;C:\Users\pc\scoop\shims;" + $env:PATH
Set-Location "c:\Users\pc\Desktop\SaaS\pulse_desk"

Write-Host "=== [1/3] PostgreSQL Kontrol Ediliyor / Başlatılıyor ==="
$pgReady = & "C:\Users\pc\scoop\apps\postgresql\current\bin\pg_isready.exe" -h localhost -p 5432 2>&1
if ($LASTEXITCODE -ne 0) {
    Remove-Item "C:\Users\pc\scoop\apps\postgresql\current\data\postmaster.pid" -ErrorAction SilentlyContinue
    Start-Process -FilePath "C:\Users\pc\scoop\apps\postgresql\current\bin\postgres.exe" -ArgumentList "-D `"C:\Users\pc\scoop\apps\postgresql\current\data`"" -WindowStyle Hidden
    Start-Sleep -Seconds 3
}
& "C:\Users\pc\scoop\apps\postgresql\current\bin\pg_isready.exe" -h localhost -p 5432

Write-Host "=== [2/3] AbisiDesk Rails Sunucusu Başlatılıyor (http://localhost:3000) ==="
Remove-Item "c:\Users\pc\Desktop\SaaS\pulse_desk\tmp\pids\server.pid" -ErrorAction SilentlyContinue
Start-Process -FilePath "C:\Users\pc\scoop\apps\ruby\current\bin\ruby.exe" -ArgumentList "bin/rails server -b 0.0.0.0 -p 3000" -WorkingDirectory "c:\Users\pc\Desktop\SaaS\pulse_desk" -WindowStyle Hidden

Start-Sleep -Seconds 3
Write-Host "=== [3/3] AbisiDesk Telegram Bot (@Abisinin_Destek_Bot) Başlatılıyor ==="
& "C:\Users\pc\scoop\apps\ruby\current\bin\ruby.exe" "bin/telegram_bot"
