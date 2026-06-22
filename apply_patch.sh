#!/bin/bash

# CTF Challenge: Sandboxie-Plus Certificate Bypass Patch
# This script applies patches to bypass all certificate validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/Sandboxie-Plus"

echo "=================================================="
echo "Sandboxie-Plus Certificate Bypass Patcher"
echo "CTF Challenge - Bypass Premium Features"
echo "=================================================="
echo ""

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Sandboxie-Plus directory not found at $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

echo "[*] Backing up original files..."
cp Sandboxie/core/drv/verify.c Sandboxie/core/drv/verify.c.bak
cp Sandboxie/core/drv/process.c Sandboxie/core/drv/process.c.bak
cp SandboxiePlus/SandMan/SandMan.cpp SandboxiePlus/SandMan/SandMan.cpp.bak

echo "[+] Backup complete"
echo ""

echo "[*] Applying patches..."

# Patch 1: verify.c - Bypass kernel-level certificate validation
echo "[*] Patching verify.c (kernel driver certificate validation)..."
cat > /tmp/verify_patch.txt << 'EOF'
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

EOF

sed -i.tmp '534 r /tmp/verify_patch.txt' Sandboxie/core/drv/verify.c

# Replace KphValidateCertificate function
sed -i.tmp '/^_FX NTSTATUS KphValidateCertificate()/,/^}$/{
/^_FX NTSTATUS KphValidateCertificate()/{
n
a\
{\
    \/\/ CTF: Always return fake certificate\
    KphSetFakeCertificate();\
    return STATUS_SUCCESS;\
}
:a
n
ba
}
}' Sandboxie/core/drv/verify.c

echo "[+] verify.c patched"

# Patch 2: process.c - Remove 5-minute kill timer and certificate checks
echo "[*] Patching process.c (remove process kill timers)..."

# Disable opt_sec check (line 783)
sed -i.tmp '783s/if (!(Verify_CertInfo.active && Verify_CertInfo.opt_sec) && !proc->image_sbie) {/if (0) { \/\/ CTF: Bypass opt_sec check/' Sandboxie/core/drv/process.c

# Disable opt_enc check (line 814)
sed -i.tmp '814s/if (!(Verify_CertInfo.active && Verify_CertInfo.opt_enc) && !proc->image_sbie) {/if (0) { \/\/ CTF: Bypass opt_enc check/' Sandboxie/core/drv/process.c

# Disable free user kill (line 1299)
sed -i.tmp '1299s/if(!Verify_CertInfo.active)/if(0) \/\/ CTF: Never kill/' Sandboxie/core/drv/process.c

echo "[+] process.c patched"

# Patch 3: SandMan.cpp - Bypass GUI certificate checks
echo "[*] Patching SandMan.cpp (GUI certificate checks)..."

sed -i.tmp '/^bool CSandMan::CheckCertificate(QWidget\* pWidget, int iType)$/,/^}$/{
/^bool CSandMan::CheckCertificate(QWidget\* pWidget, int iType)$/{
n
a\
{\
	\/\/ CTF: Always pass certificate check in GUI\
	return true;\
}
:a
n
ba
}
}' SandboxiePlus/SandMan/SandMan.cpp

echo "[+] SandMan.cpp patched"

# Clean up temp files
rm -f /tmp/verify_patch.txt
rm -f Sandboxie/core/drv/verify.c.tmp
rm -f Sandboxie/core/drv/process.c.tmp
rm -f SandboxiePlus/SandMan/SandMan.cpp.tmp

echo ""
echo "=================================================="
echo "[+] All patches applied successfully!"
echo "=================================================="
echo ""
echo "Modified files:"
echo "  - Sandboxie/core/drv/verify.c"
echo "  - Sandboxie/core/drv/process.c"
echo "  - SandboxiePlus/SandMan/SandMan.cpp"
echo ""
echo "Backup files created with .bak extension"
echo ""
echo "Next steps:"
echo "  1. Build the project with your Windows build environment"
echo "  2. Replace the driver and GUI executable"
echo "  3. Test premium features without certificate"
echo ""
echo "To restore original files:"
echo "  cp *.bak <original_name>"
echo ""
