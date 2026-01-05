@echo off
cd /d "%~dp0"
echo Starting Fake News API...
".\venv\Scripts\python.exe" -m uvicorn main:app --reload --port 8001
pause
