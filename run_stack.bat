@echo off
echo Starting Meal 4 U Full Stack...

:: Start Backend in a new window
start "Meal 4 U Backend" cmd /k "cd backend && venv\Scripts\activate && uvicorn main:app --reload"

:: Start Frontend in a new window
echo Waiting for backend to start...
timeout /t 5

start "Meal 4 U App" cmd /k "flutter run"

echo Stack started!
