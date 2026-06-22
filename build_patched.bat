@echo off
REM Windows Build Script for Patched Sandboxie-Plus
REM Run this script in Developer Command Prompt for VS 2019/2022

echo ================================================
echo Sandboxie-Plus Patched Build Script
echo ================================================
echo.

REM Check if we're in the right directory
if not exist "Sandboxie-Plus" (
    echo Error: Sandboxie-Plus directory not found
    echo Please run this script from the leak-bus directory
    pause
    exit /b 1
)

REM Set Qt path (modify this to match your Qt installation)
set QT_PATH=C:\Qt\6.5.0\msvc2019_64
if not exist "%QT_PATH%" (
    echo Warning: Qt not found at %QT_PATH%
    echo Please set QT_PATH in this script to your Qt installation
    echo Example: C:\Qt\6.5.0\msvc2019_64
    pause
)

echo [*] Qt Path: %QT_PATH%
echo.

REM Create build directory
cd Sandboxie-Plus
if exist build (
    echo [*] Removing old build directory...
    rmdir /s /q build
)
mkdir build
cd build

echo [*] Configuring CMake...
cmake .. -G "Visual Studio 17 2022" -A x64 ^
    -DCMAKE_PREFIX_PATH="%QT_PATH%" ^
    -DCMAKE_BUILD_TYPE=Release

if %errorlevel% neq 0 (
    echo.
    echo Error: CMake configuration failed
    echo.
    echo Possible solutions:
    echo 1. Install Visual Studio 2022 with C++ workload
    echo 2. Install Windows SDK
    echo 3. Install Windows Driver Kit (WDK)
    echo 4. Set correct Qt path in this script
    pause
    exit /b 1
)

echo.
echo [*] Building Release configuration...
cmake --build . --config Release

if %errorlevel% neq 0 (
    echo.
    echo Error: Build failed
    echo Check the error messages above
    pause
    exit /b 1
)

echo.
echo ================================================
echo Build Successful!
echo ================================================
echo.
echo Output files:
echo   Driver:  build\Sandboxie\core\drv\Release\SbieDrv.sys
echo   Service: build\Sandboxie\core\svc\Release\SbieSvc.exe
echo   GUI:     build\SandboxiePlus\SandMan\Release\SandMan.exe
echo.
echo Next steps:
echo   1. Run install_patched.bat to install the patched version
echo   2. Or manually copy files to C:\Program Files\Sandboxie-Plus\
echo.
pause
