@echo off
setlocal EnableExtensions EnableDelayedExpansion

cd /d "%~dp0" || goto :fail_cd

set "MAIN_FILE=app.py"
set "VENV_NAME=.venv"
set "FALLBACK_VENV_NAME=.venv-start"
set "PYTHON_VERSION=3.11.9"
set "PYTHON_VERSION_SHORT=3.11"
set "VENV_PY=%VENV_NAME%\Scripts\python.exe"
set "PYTHON_CMD="
set "VENV_PY_SHORT="

echo START.bat - College ERP

call :find_python
if errorlevel 1 call :install_python

if not exist "%VENV_PY%" (
    echo Creating virtual environment %VENV_NAME%...
    %PYTHON_CMD% -m venv "%VENV_NAME%"
    if errorlevel 1 call :fail "Virtual environment creation failed"
)

for /f "tokens=*" %%V in ('"%VENV_PY%" -c "import sys; print(str(sys.version_info.major)+'.'+str(sys.version_info.minor))" 2^>nul') do set "VENV_PY_SHORT=%%V"
if not "%VENV_PY_SHORT%"=="%PYTHON_VERSION_SHORT%" (
    echo Existing %VENV_NAME% is locked, broken, or not Python %PYTHON_VERSION_SHORT%.
    echo Using fallback virtual environment %FALLBACK_VENV_NAME%...
    set "VENV_NAME=%FALLBACK_VENV_NAME%"
    set "VENV_PY=%FALLBACK_VENV_NAME%\Scripts\python.exe"
    if not exist "!VENV_PY!" (
        %PYTHON_CMD% -m venv "%FALLBACK_VENV_NAME%"
        if errorlevel 1 call :fail "Fallback virtual environment creation failed"
    )
)

if not exist "%VENV_PY%" call :fail "Virtual environment python not found: %VENV_PY%"
if not exist "requirements.txt" call :fail "requirements.txt not found"
if not exist "%MAIN_FILE%" call :fail "%MAIN_FILE% not found"

echo Updating pip...
"%VENV_PY%" -m ensurepip --upgrade >nul 2>nul
"%VENV_PY%" -m pip install --upgrade pip
if errorlevel 1 call :fail "pip upgrade failed"

echo Installing requirements...
"%VENV_PY%" -m pip install -r requirements.txt
if errorlevel 1 call :fail "Package install failed"

echo Verifying Django...
"%VENV_PY%" -c "import django; print('Django ' + django.get_version() + ' ready')"
if errorlevel 1 call :fail "Django verification failed"

echo Starting app at http://127.0.0.1:8000/
"%VENV_PY%" "%MAIN_FILE%"
if errorlevel 1 call :fail "Launch failed: %MAIN_FILE%"
exit /b 0

:find_python
python --version >nul 2>nul
if not errorlevel 1 (
    for /f "tokens=2" %%V in ('python --version 2^>^&1') do set "CURRENT_PY=%%V"
    echo !CURRENT_PY! | findstr /b "%PYTHON_VERSION_SHORT%." >nul
    if not errorlevel 1 (
        set "PYTHON_CMD=python"
        exit /b 0
    )
)

py -%PYTHON_VERSION_SHORT% --version >nul 2>nul
if not errorlevel 1 (
    for /f "tokens=2" %%V in ('py -%PYTHON_VERSION_SHORT% --version 2^>^&1') do set "CURRENT_PY=%%V"
    echo !CURRENT_PY! | findstr /b "%PYTHON_VERSION_SHORT%." >nul
    if not errorlevel 1 (
        set "PYTHON_CMD=py -%PYTHON_VERSION_SHORT%"
        exit /b 0
    )
)

exit /b 1

:install_python
echo Python %PYTHON_VERSION% not found. Downloading and installing automatically...
set "PYTHON_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe"
set "PYTHON_INSTALLER=%TEMP%\python_installer.exe"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri '%PYTHON_URL%' -OutFile '%PYTHON_INSTALLER%' -UseBasicParsing } catch { Write-Error $_.Exception.Message; exit 1 }"
if errorlevel 1 call :fail "Python download failed: %PYTHON_URL%"

"%PYTHON_INSTALLER%" /quiet InstallAllUsers=0 PrependPath=1 Include_pip=1
if errorlevel 1 call :fail "Python silent installer failed"
del /f /q "%PYTHON_INSTALLER%" >nul 2>nul

for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "USER_PATH=%%B"
for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do set "SYSTEM_PATH=%%B"
set "PATH=%USER_PATH%;%SYSTEM_PATH%"

call :find_python
if errorlevel 1 call :fail "Python installed but verification failed. Expected %PYTHON_VERSION_SHORT%"
exit /b 0

:fail_cd
echo ERROR: Could not enter project folder
pause
exit /b 1

:fail
color 0C
echo ERROR: %~1
pause
exit /b 1
