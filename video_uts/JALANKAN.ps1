# Jalankan dari folder video_uts:  powershell -ExecutionPolicy Bypass -File .\JALANKAN.ps1
$ErrorActionPreference = "Stop"
Write-Host "1/3 Membuat suara narasi (Gadis)..." -ForegroundColor Cyan
Push-Location tts
npm install --no-audit --no-fund
node buat_suara.js
Pop-Location

Write-Host "2/3 Mengunduh Remotion versi Linux (untuk dirender oleh Claude)..." -ForegroundColor Cyan
Push-Location remotion
npm install --no-audit --no-fund --os=linux --cpu=x64 --libc=glibc
Pop-Location

Write-Host "3/3 Membungkus jadi satu file..." -ForegroundColor Cyan
tar -czf remotion_linux.tgz -C remotion node_modules
Write-Host "SELESAI. Bilang ke Claude: 'sudah'" -ForegroundColor Green
