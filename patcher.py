#!/usr/bin/env python3
"""
Sandboxie-Plus Certificate Bypass Patcher
Automated patching tool for CTF challenge
"""

import os
import sys
import shutil
from pathlib import Path

class SandboxiePatcher:
    def __init__(self, base_dir):
        self.base_dir = Path(base_dir)
        self.backup_suffix = '.bak'
        self.files_to_patch = {
            'verify.c': self.base_dir / 'Sandboxie-Plus/Sandboxie/core/drv/verify.c',
            'process.c': self.base_dir / 'Sandboxie-Plus/Sandboxie/core/drv/process.c',
            'SandMan.cpp': self.base_dir / 'Sandboxie-Plus/SandboxiePlus/SandMan/SandMan.cpp'
        }

    def backup_file(self, filepath):
        """Backup a file before patching"""
        backup_path = str(filepath) + self.backup_suffix
        if not os.path.exists(backup_path):
            shutil.copy2(filepath, backup_path)
            print(f"[+] Backed up: {filepath.name}")
        else:
            print(f"[!] Backup already exists: {filepath.name}")

    def patch_verify_c(self, filepath):
        """Patch verify.c to bypass certificate validation"""
        print(f"\n[*] Patching {filepath.name}...")

        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()

        # Add fake certificate function after SCertInfo declaration
        fake_cert_function = '''
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
'''

        # Insert after SCertInfo Verify_CertInfo = { 0 };
        if 'SCertInfo Verify_CertInfo = { 0 };' in content:
            content = content.replace(
                'SCertInfo Verify_CertInfo = { 0 };',
                'SCertInfo Verify_CertInfo = { 0 };' + fake_cert_function
            )
            print("[+] Added KphSetFakeCertificate function")

        # Replace KphValidateCertificate function
        start_marker = '_FX NTSTATUS KphValidateCertificate()'
        if start_marker in content:
            # Find the function and replace its body
            start_idx = content.find(start_marker)
            open_brace = content.find('{', start_idx)

            # Simple function body replacement
            new_function = '''_FX NTSTATUS KphValidateCertificate()
{
    // CTF: Always return fake certificate with max privileges
    KphSetFakeCertificate();
    return STATUS_SUCCESS;
}'''

            # Find the end of the function (matching braces)
            brace_count = 0
            end_idx = open_brace
            for i in range(open_brace, len(content)):
                if content[i] == '{':
                    brace_count += 1
                elif content[i] == '}':
                    brace_count -= 1
                    if brace_count == 0:
                        end_idx = i + 1
                        break

            content = content[:start_idx] + new_function + '\n' + content[end_idx:]
            print("[+] Replaced KphValidateCertificate function body")

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

        print(f"[+] {filepath.name} patched successfully")

    def patch_process_c(self, filepath):
        """Patch process.c to remove certificate checks and kill timers"""
        print(f"\n[*] Patching {filepath.name}...")

        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()

        patched_lines = []
        for i, line in enumerate(lines):
            # Patch opt_sec check
            if 'if (!(Verify_CertInfo.active && Verify_CertInfo.opt_sec) && !proc->image_sbie)' in line:
                patched_lines.append('    if (0) { // CTF: Bypass opt_sec check - never kill processes\n')
                print(f"[+] Patched opt_sec check at line {i+1}")
            # Patch opt_enc check
            elif 'if (!(Verify_CertInfo.active && Verify_CertInfo.opt_enc) && !proc->image_sbie)' in line:
                patched_lines.append('    if (0) { // CTF: Bypass opt_enc check - allow encrypted boxes\n')
                print(f"[+] Patched opt_enc check at line {i+1}")
            # Patch free user kill
            elif 'if(!Verify_CertInfo.active)' in line and 'Process_KillOne' in lines[i+1] if i+1 < len(lines) else False:
                patched_lines.append('            if(0) // CTF: Never kill processes based on certificate\n')
                print(f"[+] Patched process kill check at line {i+1}")
            else:
                patched_lines.append(line)

        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(patched_lines)

        print(f"[+] {filepath.name} patched successfully")

    def patch_sandman_cpp(self, filepath):
        """Patch SandMan.cpp to bypass GUI certificate checks"""
        print(f"\n[*] Patching {filepath.name}...")

        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()

        # Replace CheckCertificate function
        function_start = 'bool CSandMan::CheckCertificate(QWidget* pWidget, int iType)'
        if function_start in content:
            start_idx = content.find(function_start)
            open_brace = content.find('{', start_idx)

            # Find the end of the function
            brace_count = 0
            end_idx = open_brace
            for i in range(open_brace, len(content)):
                if content[i] == '{':
                    brace_count += 1
                elif content[i] == '}':
                    brace_count -= 1
                    if brace_count == 0:
                        end_idx = i + 1
                        break

            new_function = '''bool CSandMan::CheckCertificate(QWidget* pWidget, int iType)
{
	// CTF: Always pass certificate check in GUI
	return true;
}'''

            content = content[:start_idx] + new_function + '\n' + content[end_idx:]
            print("[+] Replaced CheckCertificate function body")

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

        print(f"[+] {filepath.name} patched successfully")

    def apply_patches(self):
        """Apply all patches"""
        print("=" * 50)
        print("Sandboxie-Plus Certificate Bypass Patcher")
        print("CTF Challenge - Automated Patching Tool")
        print("=" * 50)

        # Check if files exist
        for name, filepath in self.files_to_patch.items():
            if not filepath.exists():
                print(f"[!] Error: File not found: {filepath}")
                return False

        # Backup files
        print("\n[*] Creating backups...")
        for filepath in self.files_to_patch.values():
            self.backup_file(filepath)

        # Apply patches
        try:
            self.patch_verify_c(self.files_to_patch['verify.c'])
            self.patch_process_c(self.files_to_patch['process.c'])
            self.patch_sandman_cpp(self.files_to_patch['SandMan.cpp'])
        except Exception as e:
            print(f"\n[!] Error during patching: {e}")
            print("[!] You may need to restore from backups")
            return False

        print("\n" + "=" * 50)
        print("[+] All patches applied successfully!")
        print("=" * 50)
        print("\n📋 Next steps:")
        print("  1. Build the project on Windows with Visual Studio")
        print("  2. Replace SbieDrv.sys, SbieSvc.exe, and SandMan.exe")
        print("  3. Test premium features")
        print("\n💾 Backups saved with .bak extension")
        print("🔧 See manual_patch_guide.md for build instructions")

        return True

    def restore_backups(self):
        """Restore original files from backups"""
        print("\n[*] Restoring from backups...")
        for filepath in self.files_to_patch.values():
            backup_path = str(filepath) + self.backup_suffix
            if os.path.exists(backup_path):
                shutil.copy2(backup_path, filepath)
                print(f"[+] Restored: {filepath.name}")
            else:
                print(f"[!] No backup found for: {filepath.name}")

def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print(f"  {sys.argv[0]} patch   - Apply patches")
        print(f"  {sys.argv[0]} restore - Restore from backups")
        sys.exit(1)

    base_dir = os.path.dirname(os.path.abspath(__file__))
    patcher = SandboxiePatcher(base_dir)

    if sys.argv[1] == 'patch':
        success = patcher.apply_patches()
        sys.exit(0 if success else 1)
    elif sys.argv[1] == 'restore':
        patcher.restore_backups()
        sys.exit(0)
    else:
        print(f"Unknown command: {sys.argv[1]}")
        sys.exit(1)

if __name__ == '__main__':
    main()
