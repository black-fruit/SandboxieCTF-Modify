# Sandboxie-Plus Certificate Bypass - Manual Patch Guide

## CTF Challenge: Bypass Premium Feature Restrictions

This guide provides manual patching instructions to bypass all certificate validation in Sandboxie-Plus.

---

## 🎯 Target Features to Unlock

After patching, the following premium features will be available without a certificate:

- **opt_sec** - Security enhanced sandbox modes:
  - UseSecurityMode
  - SysCallLockDown
  - RestrictDevices
  - UseRuleSpecificity
  - UsePrivacyMode
  - ProtectHostImages
  - NoSecurityIsolation

- **opt_enc** - Encrypted sandbox features:
  - ConfidentialBox
  - UseFileImage
  - EnableEFS

- **opt_net** - Advanced networking:
  - NetworkDnsFilter
  - NetworkUseProxy

- **opt_desk** - Isolated desktops:
  - UseSandboxDesktop

---

## 📝 Patch Instructions

### Patch 1: Bypass Kernel Driver Certificate Validation

**File:** `Sandboxie-Plus/Sandboxie/core/drv/verify.c`

**Location:** After line 534 (`SCertInfo Verify_CertInfo = { 0 };`)

**Action:** Add the following function:

```c
// CTF Challenge: Bypass certificate validation
_FX VOID KphSetFakeCertificate()
{
    Verify_CertInfo.active = 1;
    Verify_CertInfo.expired = 0;
    Verify_CertInfo.outdated = 0;
    Verify_CertInfo.type = eCertMaxLevel;
    Verify_CertInfo.level = eCertMaxLevel;
    Verify_CertInfo.opt_desk = 1;
    Verify_CertInfo.opt_net = 1;
    Verify_CertInfo.opt_enc = 1;
    Verify_CertInfo.opt_sec = 1;
    Verify_CertInfo.expirers_in_sec = 0x7FFFFFFF; // ~68 years
}
```

**Location:** Line 536 (`_FX NTSTATUS KphValidateCertificate()`)

**Action:** Replace the entire function body with:

```c
_FX NTSTATUS KphValidateCertificate()
{
    // CTF: Always return fake certificate with max privileges
    KphSetFakeCertificate();
    return STATUS_SUCCESS;
}
```

**Explanation:** This makes the kernel driver always report a valid MAXLEVEL certificate with all premium features enabled.

---

### Patch 2: Remove Process Kill Timers

**File:** `Sandboxie-Plus/Sandboxie/core/drv/process.c`

#### 2.1 Bypass opt_sec check (line ~783)

**Find:**
```c
if (!(Verify_CertInfo.active && Verify_CertInfo.opt_sec) && !proc->image_sbie) {
```

**Replace with:**
```c
if (0) { // CTF: Bypass opt_sec check - never kill processes
```

**Explanation:** This prevents the 5-minute process termination for security-enhanced features.

#### 2.2 Bypass opt_enc check (line ~814)

**Find:**
```c
if (!(Verify_CertInfo.active && Verify_CertInfo.opt_enc) && !proc->image_sbie) {
```

**Replace with:**
```c
if (0) { // CTF: Bypass opt_enc check - allow encrypted boxes
```

**Explanation:** This allows ConfidentialBox to start without immediate termination.

#### 2.3 Disable free user process kill (line ~1299)

**Find:**
```c
if(!Verify_CertInfo.active)
    Process_KillOne(proc, 0);
```

**Replace with:**
```c
if(0) // CTF: Never kill processes based on certificate
    Process_KillOne(proc, 0);
```

**Explanation:** Prevents killing processes in "box 0" for unlicensed users.

---

### Patch 3: Bypass GUI Certificate Checks

**File:** `Sandboxie-Plus/SandboxiePlus/SandMan/SandMan.cpp`

**Location:** Line ~3471 (`bool CSandMan::CheckCertificate(QWidget* pWidget, int iType)`)

**Find:**
```cpp
bool CSandMan::CheckCertificate(QWidget* pWidget, int iType)
{
    int type = iType == -1 ? 1 : 0;

    if(g_CertInfo.active)
    {
        if (iType == 1 ? g_CertInfo.opt_enc : g_CertInfo.opt_net)
            return true;
        ...
    }
    return true;
}
```

**Replace with:**
```cpp
bool CSandMan::CheckCertificate(QWidget* pWidget, int iType)
{
    // CTF: Always pass certificate check in GUI
    return true;
}
```

**Explanation:** This disables certificate warnings in the GUI when enabling premium features.

---

## 🔧 Building the Patched Version

### Windows Build Requirements

1. **Visual Studio 2019 or later** with:
   - C++ Desktop Development workload
   - Windows 10/11 SDK
   - Windows Driver Kit (WDK)

2. **Qt Framework** (5.15.x or 6.x)

3. **CMake** (3.16 or later)

### Build Commands

```powershell
# Navigate to project directory
cd Sandboxie-Plus

# Create build directory
mkdir build
cd build

# Configure with CMake
cmake .. -G "Visual Studio 16 2019" -A x64

# Build the project
cmake --build . --config Release

# Build output locations:
# - Driver: build/Sandboxie/core/drv/Release/SbieDrv.sys
# - Service: build/Sandboxie/core/svc/Release/SbieSvc.exe
# - GUI: build/SandboxiePlus/SandMan/Release/SandMan.exe
```

### Installation

1. **Stop Sandboxie Service:**
   ```cmd
   sc stop SbieSvc
   ```

2. **Replace files** (backup originals first):
   ```cmd
   copy /Y build\Sandboxie\core\drv\Release\SbieDrv.sys "C:\Program Files\Sandboxie-Plus\SbieDrv.sys"
   copy /Y build\Sandboxie\core\svc\Release\SbieSvc.exe "C:\Program Files\Sandboxie-Plus\SbieSvc.exe"
   copy /Y build\SandboxiePlus\SandMan\Release\SandMan.exe "C:\Program Files\Sandboxie-Plus\SandMan.exe"
   ```

3. **Start service:**
   ```cmd
   sc start SbieSvc
   ```

4. **Launch GUI:**
   ```cmd
   "C:\Program Files\Sandboxie-Plus\SandMan.exe"
   ```

---

## ✅ Testing the Patch

### Test 1: Check Certificate Status

In the GUI, go to **Help → About**. You should see:
- Certificate Status: **Active**
- Certificate Level: **MAXLEVEL**
- All premium features listed as **Enabled**

### Test 2: Enable Security Features

1. Create a new sandbox
2. Go to **Sandbox Settings → Advanced → Security Mode**
3. Enable **UseSecurityMode** - should work without warnings
4. Launch a program in the sandbox
5. Verify it runs for more than 5 minutes without termination

### Test 3: Enable Encrypted Box

1. Create a new sandbox
2. Go to **Sandbox Settings → Advanced → Box Protection**
3. Enable **ConfidentialBox** - should work without immediate termination
4. Launch a program - should start successfully

### Test 4: Check Driver Info

Use the SbieAPI to query driver info:

```cpp
SCertInfo info;
SbieApi_QueryDrvInfo(-1, &info, sizeof(info));

printf("Active: %d\n", info.active);           // Should be 1
printf("opt_sec: %d\n", info.opt_sec);         // Should be 1
printf("opt_enc: %d\n", info.opt_enc);         // Should be 1
printf("opt_net: %d\n", info.opt_net);         // Should be 1
printf("opt_desk: %d\n", info.opt_desk);       // Should be 1
printf("Level: %d\n", info.level);             // Should be 7 (MAXLEVEL)
```

---

## 🔍 How the Bypass Works

### Layer 1: Kernel Driver (verify.c)

The kernel driver is the primary enforcement point. By modifying `KphValidateCertificate()` to always set maximum privileges, we bypass:
- Digital signature verification
- Certificate expiry checks
- Hardware ID binding
- Certificate blacklist checks

### Layer 2: Process Management (process.c)

The driver checks certificates when creating sandboxed processes. By disabling the conditional checks:
- Processes using premium features won't be killed after 5 minutes
- ConfidentialBox processes can start
- No "Box 0" restrictions for free users

### Layer 3: GUI (SandMan.cpp)

The GUI performs its own checks before allowing users to enable features. By returning `true` unconditionally:
- No purchase prompts when enabling premium features
- No warning dialogs
- All UI elements remain enabled

---

## 🛡️ Security Considerations

This patch is for **CTF/educational purposes** only:

1. **Legal:** Using cracked software violates the Sandboxie-Plus license
2. **Updates:** Patched versions cannot auto-update without losing the patches
3. **Support:** You won't receive official support with modified binaries
4. **Detection:** Some AV software may flag modified system drivers

---

## 📦 Restore Original Files

If you backed up files with the script:

```bash
cd Sandboxie-Plus
cp Sandboxie/core/drv/verify.c.bak Sandboxie/core/drv/verify.c
cp Sandboxie/core/drv/process.c.bak Sandboxie/core/drv/process.c
cp SandboxiePlus/SandMan/SandMan.cpp.bak SandboxiePlus/SandMan/SandMan.cpp
```

Then rebuild with the original code.

---

## 📚 References

- Sandboxie-Plus GitHub: https://github.com/sandboxie-plus/Sandboxie
- Certificate structure: `Sandboxie/core/drv/verify.h`
- API definitions: `Sandboxie/core/drv/api.c`
- User layer API: `SandboxiePlus/QSbieAPI/SbieAPI.cpp`

---

## ✨ Summary

This patch provides a **complete bypass** of Sandboxie-Plus premium features by:

1. ✅ Faking a MAXLEVEL certificate in the kernel driver
2. ✅ Disabling all certificate checks in process creation
3. ✅ Removing the 5-minute kill timer for premium features
4. ✅ Bypassing GUI purchase prompts
5. ✅ Enabling all opt_sec, opt_enc, opt_net, and opt_desk features

**Result:** Full access to all premium Sandboxie-Plus features without a valid certificate.

---

**CTF Challenge Complete! 🎉**
