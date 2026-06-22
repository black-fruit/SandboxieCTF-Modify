#!/bin/bash
# Quick test script to verify patches were applied correctly

echo "=================================================="
echo "Sandboxie-Plus Patch Verification"
echo "=================================================="
echo ""

VERIFY_C="Sandboxie-Plus/Sandboxie/core/drv/verify.c"
PROCESS_C="Sandboxie-Plus/Sandboxie/core/drv/process.c"
SANDMAN_CPP="Sandboxie-Plus/SandboxiePlus/SandMan/SandMan.cpp"

PASS=0
FAIL=0

# Check if files exist
if [ ! -f "$VERIFY_C" ]; then
    echo "❌ verify.c not found"
    exit 1
fi

if [ ! -f "$PROCESS_C" ]; then
    echo "❌ process.c not found"
    exit 1
fi

if [ ! -f "$SANDMAN_CPP" ]; then
    echo "❌ SandMan.cpp not found"
    exit 1
fi

echo "[*] Checking patches..."
echo ""

# Test 1: KphSetFakeCertificate
if grep -q "KphSetFakeCertificate" "$VERIFY_C"; then
    echo "✅ Test 1: KphSetFakeCertificate function found"
    ((PASS++))
else
    echo "❌ Test 1: KphSetFakeCertificate function NOT found"
    ((FAIL++))
fi

# Test 2: opt_sec = 1
if grep -q "Verify_CertInfo.opt_sec = 1" "$VERIFY_C"; then
    echo "✅ Test 2: opt_sec bypass found"
    ((PASS++))
else
    echo "❌ Test 2: opt_sec bypass NOT found"
    ((FAIL++))
fi

# Test 3: opt_enc = 1
if grep -q "Verify_CertInfo.opt_enc = 1" "$VERIFY_C"; then
    echo "✅ Test 3: opt_enc bypass found"
    ((PASS++))
else
    echo "❌ Test 3: opt_enc bypass NOT found"
    ((FAIL++))
fi

# Test 4: opt_net = 1
if grep -q "Verify_CertInfo.opt_net = 1" "$VERIFY_C"; then
    echo "✅ Test 4: opt_net bypass found"
    ((PASS++))
else
    echo "❌ Test 4: opt_net bypass NOT found"
    ((FAIL++))
fi

# Test 5: Process.c opt_sec check bypass
if grep -q "if (0) { // CTF" "$PROCESS_C"; then
    echo "✅ Test 5: process.c certificate checks bypassed"
    ((PASS++))
else
    echo "❌ Test 5: process.c certificate checks NOT bypassed"
    ((FAIL++))
fi

# Test 6: Check for Process_ScheduleKill bypass (5-minute timer)
if grep -q "if (0) { // CTF: Bypass" "$PROCESS_C"; then
    echo "✅ Test 6: 5-minute process kill timer bypassed"
    ((PASS++))
else
    echo "❌ Test 6: 5-minute process kill timer NOT bypassed"
    ((FAIL++))
fi

# Test 7: GUI bypass
if grep -q "// CTF: Always pass certificate check in GUI" "$SANDMAN_CPP"; then
    echo "✅ Test 7: GUI certificate check bypassed"
    ((PASS++))
else
    echo "❌ Test 7: GUI certificate check NOT bypassed"
    ((FAIL++))
fi

echo ""
echo "=================================================="
echo "Results: $PASS passed, $FAIL failed"
echo "=================================================="

if [ $FAIL -eq 0 ]; then
    echo ""
    echo "🎉 All patches verified successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Build on Windows with Visual Studio"
    echo "  2. Install patched binaries"
    echo "  3. Test premium features"
    echo ""
    exit 0
else
    echo ""
    echo "⚠️  Some patches failed verification"
    echo "Review manual_patch_guide.md for details"
    echo ""
    exit 1
fi
