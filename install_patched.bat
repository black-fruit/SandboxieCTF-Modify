@echo off
REM Installation script for patched Sandboxie-Plus
REM Must be run as Administrator

echo ================================================
echo Sandboxie-Plus Patched Installation Script
echo ================================================
echo.

REM Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: This script must be run as Administrator
    echo Right-click and select "Run as administrator"
    pause
    exit /b 1
)

set INSTALL_DIR=C:\Program Files\Sandboxie-Plus
set BUILD_DIR=%~dp0Sandboxie-Plus\build\Release

REM Check if build files exist
if not exist "%BUILD_DIR%\Sandboxie\core\drv\Release\SbieDrv.sys" (
    echo Error: Build files not found
    echo Please run build_patched.bat first
    pause
    exit /b 1
)

echo [*] Installation directory: %INSTALL_DIR%
echo.

REM Backup existing files
echo [*] Creating backup...
if not exist "%INSTALL_DIR%\backup" mkdir "%INSTALL_DIR%\backup"

copy /Y "%INSTALL_DIR%\SbieDrv.sys" "%INSTALL_DIR%\backup\SbieDrv.sys.bak" >nul 2>&1
copy /Y "%INSTALL_DIR%\SbieSvc.exe" "%INSTALL_DIR%\backup\SbieSvc.exe.bak" >nul 2>&1
copy /Y "%INSTALL_DIR%\SandMan.exe" "%INSTALL_DIR%\backup\SandMan.exe.bak" >nul 2>&1

echo [+] Backup complete
echo.

REM Stop service
echo [*] Stopping Sandboxie service...
net stop SbieSvc >nul 2>&1
timeout /t 2 /nobreak >nul

REM Copy patched files
echo [*] Installing patched files...

copy /Y "%BUILD_DIR%\Sandboxie\core\drv\Release\SbieDrv.sys" "%INSTALL_DIR%\SbieDrv.sys"
if %errorlevel% neq 0 goto :install_error

copy /Y "%BUILD_DIR%\Sandboxie\core\svc\Release\SbieSvc.exe" "%INSTALL_DIR%\SbieSvc.exe"
if %errorlevel% neq 0 goto :install_error

copy /Y "%BUILD_DIR%\SandboxiePlus\SandMan\Release\SandMan.exe" "%INSTALL_DIR%\SandMan.exe"
if %errorlevel% neq 0 goto :install_error

echo [+] Files installed successfully
echo.

REM Enable test signing (required for unsigned driver)
echo [*] Enabling test signing mode...
bcdedit /set testsigning on
if %errorlevel% neq 0 (
    echo Warning: Failed to enable test signing
    echo You may need to enable it manually: bcdedit /set testsigning on
    echo Or disable driver signature enforcement in boot options
)
echo.

REM Start service
echo [*] Starting Sandboxie service...
net start SbieSvc
if %errorlevel% neq 0 (
    echo Warning: Service failed to start
    echo Try restarting your computer with test signing enabled
    goto :end
)

echo.
echo ================================================
echo Installation Successful!
echo ================================================
echo.
echo Patched Sandboxie-Plus is now installed
echo.
echo IMPORTANT:
echo   1. A system restart is required for test signing mode
echo   2. After restart, all premium features will be unlocked
echo   3. Original files backed up to: %INSTALL_DIR%\backup
echo.
echo To verify installation:
echo   1. Launch SandMan.exe
echo   2. Go to Help - About
echo   3. Check certificate status (should show MAXLEVEL)
echo.

goto :end

:install_error
echo.
echo Error: Failed to copy files
echo Make sure Sandboxie is completely stopped
pause
exit /b 1

:end
echo Press any key to restart now, or close this window to restart later
pause >nul
shutdown /r /t 10 /c "Restarting to enable test signing for Sandboxie-Plus"
echo.
echo Computer will restart in 10 seconds...
echo Close this window to cancel restart
timeout /t 10
