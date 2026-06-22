# Sandboxie-Plus Certificate Bypass - CTF Challenge Solution

## 🎯 Overview

This directory contains a complete solution for bypassing Sandboxie-Plus premium certificate validation. All high-level paid features will be unlocked without requiring a valid certificate.

## 📁 Files Included

```
leak-bus/
├── README.md                      # This file
├── manual_patch_guide.md          # Detailed manual patching instructions
├── patch_cert_bypass.patch        # Unified diff patch file
├── patcher.py                     # Automated Python patcher (recommended)
├── apply_patch.sh                 # Bash script patcher
├── check_patch.c                  # Patch verification tool
└── Sandboxie-Plus/               # Original source code (to be patched)
```

## 🚀 Quick Start

### Method 1: Automated Python Patcher (Recommended)

```bash
# Apply patches
python3 patcher.py patch

# If something goes wrong, restore backups
python3 patcher.py restore
```

### Method 2: Bash Script

```bash
# Apply patches
./apply_patch.sh
```

### Method 3: Manual Patching

Follow the detailed instructions in [manual_patch_guide.md](manual_patch_guide.md)

## 🔓 What Gets Bypassed

### Kernel Driver Level (verify.c)
- ✅ Digital signature validation (ECDSA P-256)
- ✅ Certificate expiration checks
- ✅ Hardware ID (HWID) binding
- ✅ Certificate type and level verification
- ✅ Certificate blacklist checks

### Process Management Level (process.c)
- ✅ 5-minute process kill timer for unlicensed premium features
- ✅ Immediate termination of ConfidentialBox processes
- ✅ "Box 0" process restrictions for free users

### GUI Level (SandMan.cpp)
- ✅ Certificate warning dialogs
- ✅ Purchase prompts when enabling premium features
- ✅ Feature UI element disabling

## 🎁 Unlocked Premium Features

After patching, the following features are fully unlocked:

### Security Enhanced Features (opt_sec)
- `UseSecurityMode` - Enhanced security isolation
- `SysCallLockDown` - System call restrictions
- `RestrictDevices` - Device access control
- `UseRuleSpecificity` - Advanced rule matching
- `UsePrivacyMode` - Privacy-enhanced sandbox
- `ProtectHostImages` - Host image protection
- `NoSecurityIsolation` - Reduced isolation mode

### Encrypted Sandbox Features (opt_enc)
- `ConfidentialBox` - Fully encrypted sandbox
- `UseFileImage` - File-based sandbox images
- `EnableEFS` - Encrypted File System support

### Advanced Network Features (opt_net)
- `NetworkDnsFilter` - DNS filtering
- `NetworkUseProxy` - Proxy support

### Desktop Isolation (opt_desk)
- `UseSandboxDesktop` - Isolated virtual desktops

## 🔧 Building After Patching

### Prerequisites (Windows Only)

1. **Visual Studio 2019 or 2022** with:
   - Desktop development with C++
   - Windows 10/11 SDK
   - Windows Driver Kit (WDK 10)

2. **Qt Framework 5.15.x or 6.x**
   - Install from https://www.qt.io/download

3. **CMake 3.16+**

### Build Steps

```powershell
# Navigate to Sandboxie-Plus directory
cd Sandboxie-Plus

# Create build directory
mkdir build
cd build

# Configure (adjust Qt path as needed)
cmake .. -G "Visual Studio 17 2022" -A x64 `
  -DCMAKE_PREFIX_PATH="C:\Qt\6.5.0\msvc2019_64"

# Build Release version
cmake --build . --config Release

# Output files:
# - build/Sandboxie/core/drv/Release/SbieDrv.sys
# - build/Sandboxie/core/svc/Release/SbieSvc.exe  
# - build/SandboxiePlus/SandMan/Release/SandMan.exe
```

## 📦 Installation

### Backup Original Files First!

```cmd
cd "C:\Program Files\Sandboxie-Plus"
mkdir backup
copy SbieDrv.sys backup\
copy SbieSvc.exe backup\
copy SandMan.exe backup\
```

### Stop Service

```cmd
net stop SbieSvc
```

### Replace Files

```cmd
copy /Y build\Sandboxie\core\drv\Release\SbieDrv.sys "C:\Program Files\Sandboxie-Plus\"
copy /Y build\Sandboxie\core\svc\Release\SbieSvc.exe "C:\Program Files\Sandboxie-Plus\"
copy /Y build\SandboxiePlus\SandMan\Release\SandMan.exe "C:\Program Files\Sandboxie-Plus\"
```

### Start Service

```cmd
net start SbieSvc
```

### Launch GUI

```cmd
"C:\Program Files\Sandboxie-Plus\SandMan.exe"
```

## ✅ Verification Tests

### Test 1: Check Certificate Status in GUI

1. Open SandMan.exe
2. Go to **Help → About**
3. Verify:
   - Certificate Status: **Active** ✅
   - Certificate Level: **MAXLEVEL** ✅
   - Security Enhanced (opt_sec): **Enabled** ✅
   - Encrypted Boxes (opt_enc): **Enabled** ✅
   - Advanced Network (opt_net): **Enabled** ✅
   - Desktop Isolation (opt_desk): **Enabled** ✅

### Test 2: UseSecurityMode (No 5-Minute Kill)

1. Create a new sandbox named "TestBox"
2. Right-click → Sandbox Settings
3. Go to **Advanced → Security**
4. Check **UseSecurityMode**
5. Apply settings
6. Run a long-running program (e.g., notepad.exe) in the sandbox
7. Wait 10+ minutes
8. **Expected:** Process continues running (no termination) ✅

### Test 3: ConfidentialBox (Encrypted Sandbox)

1. Create a new sandbox named "EncryptedBox"
2. Right-click → Sandbox Settings
3. Go to **Advanced → Box Protection**
4. Check **ConfidentialBox**
5. Apply settings
6. Try to launch a program in this sandbox
7. **Expected:** Program launches successfully (no immediate termination) ✅

### Test 4: Verify via Code

```cpp
#include <windows.h>
#include <stdio.h>

typedef struct {
    unsigned long long State;
    struct {
        unsigned long active : 1;
        unsigned long expired : 1;
        unsigned long outdated : 1;
        unsigned long reservd_1 : 2;
        unsigned long grace_period : 1;
        unsigned long locked : 1;
        unsigned long lock_req : 1;
        unsigned long type : 5;
        unsigned long level : 3;
        unsigned long reservd_3 : 8;
        unsigned long reservd_4 : 4;
        unsigned long opt_desk : 1;
        unsigned long opt_net : 1;
        unsigned long opt_enc : 1;
        unsigned long opt_sec : 1;
        long expirers_in_sec;
    };
} SCertInfo;

extern "C" __declspec(dllimport) LONG SbieApi_QueryDrvInfo(LONG InfoClass, void* InfoData, LONG InfoDataSize);

int main() {
    SCertInfo info = {0};
    
    LONG result = SbieApi_QueryDrvInfo(-1, &info, sizeof(info));
    
    printf("QueryDrvInfo result: 0x%08X\n", result);
    printf("\nCertificate Info:\n");
    printf("  Active:     %d (should be 1)\n", info.active);
    printf("  Level:      %d (should be 7 = MAXLEVEL)\n", info.level);
    printf("  Type:       %d\n", info.type);
    printf("  opt_sec:    %d (should be 1)\n", info.opt_sec);
    printf("  opt_enc:    %d (should be 1)\n", info.opt_enc);
    printf("  opt_net:    %d (should be 1)\n", info.opt_net);
    printf("  opt_desk:   %d (should be 1)\n", info.opt_desk);
    printf("  Expires in: %d seconds\n", info.expirers_in_sec);
    
    if (info.active && info.opt_sec && info.opt_enc && info.level == 7) {
        printf("\n✅ PATCH SUCCESSFUL - All features unlocked!\n");
        return 0;
    } else {
        printf("\n❌ PATCH FAILED - Features not fully unlocked\n");
        return 1;
    }
}
```

Compile and run this test program to verify the patch.

## 🛠️ Troubleshooting

### Patch Verification Tool

Use the included verification tool to check if patches were applied correctly:

```bash
# Compile the verification tool
gcc -o check_patch check_patch.c

# Run verification
./check_patch \
  Sandboxie-Plus/Sandboxie/core/drv/verify.c \
  Sandboxie-Plus/Sandboxie/core/drv/process.c \
  Sandboxie-Plus/SandboxiePlus/SandMan/SandMan.cpp
```

### Common Issues

**Issue:** Driver fails to load after patching
- **Solution:** Disable Driver Signature Enforcement on Windows
  ```cmd
  bcdedit /set testsigning on
  ```
  Reboot and try again.

**Issue:** Service won't start (Error 577 or 1275)
- **Solution:** The driver signature is invalid. Use test signing mode or sign the driver with a test certificate.

**Issue:** Process still gets killed after 5 minutes
- **Solution:** Verify that process.c patches were applied correctly. Check line ~783 and ~814.

**Issue:** GUI shows "Certificate not valid"
- **Solution:** Verify SandMan.cpp was patched. The CheckCertificate function should return true immediately.

## 🔄 Restoring Original Version

### From Backups Created by Patcher

```bash
# Using Python patcher
python3 patcher.py restore

# Or manually
cp Sandboxie-Plus/Sandboxie/core/drv/verify.c.bak \
   Sandboxie-Plus/Sandboxie/core/drv/verify.c
   
cp Sandboxie-Plus/Sandboxie/core/drv/process.c.bak \
   Sandboxie-Plus/Sandboxie/core/drv/process.c
   
cp Sandboxie-Plus/SandboxiePlus/SandMan/SandMan.cpp.bak \
   Sandboxie-Plus/SandboxiePlus/SandMan/SandMan.cpp
```

### From Installation Backup

```cmd
cd "C:\Program Files\Sandboxie-Plus"
net stop SbieSvc
copy /Y backup\SbieDrv.sys .
copy /Y backup\SbieSvc.exe .
copy /Y backup\SandMan.exe .
net start SbieSvc
```

## 📚 Technical Details

### Patch Locations

| File | Function | Line Range | Purpose |
|------|----------|------------|---------|
| verify.c | KphSetFakeCertificate | ~535-548 | Creates fake certificate with max privileges |
| verify.c | KphValidateCertificate | ~536-540 | Bypasses all validation, returns fake cert |
| process.c | Process_NotifyProcess_Create | ~783 | Disables opt_sec check (5-min timer) |
| process.c | Process_NotifyProcess_Create | ~814 | Disables opt_enc check (ConfidentialBox) |
| process.c | Process_KillOne | ~1299 | Prevents killing unlicensed processes |
| SandMan.cpp | CheckCertificate | ~3471 | GUI always passes cert checks |

### Certificate Structure

```c
typedef union _SCertInfo {
    unsigned long long State;
    struct {
        unsigned long active      : 1;  // Set to 1
        unsigned long expired     : 1;  // Set to 0
        unsigned long outdated    : 1;  // Set to 0
        unsigned long type        : 5;  // Set to eCertMaxLevel (7)
        unsigned long level       : 3;  // Set to eCertMaxLevel (7)
        unsigned long opt_desk    : 1;  // Set to 1
        unsigned long opt_net     : 1;  // Set to 1
        unsigned long opt_enc     : 1;  // Set to 1
        unsigned long opt_sec     : 1;  // Set to 1
        long expirers_in_sec;           // Set to 0x7FFFFFFF
    };
} SCertInfo;
```

## ⚠️ Legal Disclaimer

This patch is provided for:
- ✅ Educational purposes (CTF challenges, security research)
- ✅ Testing and evaluation in isolated environments
- ✅ Understanding software protection mechanisms

**NOT for:**
- ❌ Commercial use
- ❌ Distribution of patched binaries
- ❌ Circumventing legitimate license purchases
- ❌ Violating software license agreements

Sandboxie-Plus is licensed under GPLv3. This patch modifies the source code, which is permitted under the GPL, but using it to avoid purchasing a commercial license may violate the project's terms of service.

**Support the developers:** If you find Sandboxie-Plus useful, please purchase a legitimate license at https://sandboxie-plus.com/

## 🎓 Learning Resources

- **Source Code:** https://github.com/sandboxie-plus/Sandboxie
- **Certificate Implementation:** `Sandboxie/core/drv/verify.c`
- **API Documentation:** `Sandboxie/core/drv/api.c`
- **Windows Driver Development:** https://docs.microsoft.com/windows-hardware/drivers/

## 🏆 CTF Challenge Complete!

If you successfully:
1. ✅ Applied the patches
2. ✅ Built the modified version
3. ✅ Installed and tested
4. ✅ Verified all premium features work

**Congratulations!** You've completed the Sandboxie-Plus certificate bypass challenge.

---

**Created for CTF/Educational Purposes**  
**Last Updated:** 2024
