// Simple patch verification tool
// Compile: gcc -o check_patch check_patch.c
// Usage: ./check_patch <path_to_verify.c> <path_to_process.c> <path_to_SandMan.cpp>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int check_file_contains(const char* filename, const char* search_string) {
    FILE *fp = fopen(filename, "r");
    if (!fp) {
        printf("[-] Failed to open: %s\n", filename);
        return -1;
    }

    char line[1024];
    int found = 0;
    while (fgets(line, sizeof(line), fp)) {
        if (strstr(line, search_string)) {
            found = 1;
            break;
        }
    }

    fclose(fp);
    return found;
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf("Usage: %s <verify.c> <process.c> <SandMan.cpp>\n", argv[0]);
        return 1;
    }

    printf("===========================================\n");
    printf("Sandboxie-Plus Patch Verification Tool\n");
    printf("===========================================\n\n");

    int all_passed = 1;

    // Check verify.c
    printf("[*] Checking verify.c patches...\n");
    if (check_file_contains(argv[1], "KphSetFakeCertificate")) {
        printf("[+] Found KphSetFakeCertificate function\n");
    } else {
        printf("[-] Missing KphSetFakeCertificate function\n");
        all_passed = 0;
    }

    if (check_file_contains(argv[1], "Verify_CertInfo.opt_sec = 1")) {
        printf("[+] Found opt_sec bypass\n");
    } else {
        printf("[-] Missing opt_sec bypass\n");
        all_passed = 0;
    }

    if (check_file_contains(argv[1], "Verify_CertInfo.opt_enc = 1")) {
        printf("[+] Found opt_enc bypass\n");
    } else {
        printf("[-] Missing opt_enc bypass\n");
        all_passed = 0;
    }

    // Check process.c
    printf("\n[*] Checking process.c patches...\n");
    if (check_file_contains(argv[2], "if (0) { // CTF: Bypass opt_sec check") ||
        check_file_contains(argv[2], "if (0) { // CTF")) {
        printf("[+] Found opt_sec process check bypass\n");
    } else {
        printf("[-] Missing opt_sec process check bypass\n");
        all_passed = 0;
    }

    if (check_file_contains(argv[2], "CTF: Never kill")) {
        printf("[+] Found process kill bypass\n");
    } else {
        printf("[-] Missing process kill bypass\n");
        all_passed = 0;
    }

    // Check SandMan.cpp
    printf("\n[*] Checking SandMan.cpp patches...\n");
    if (check_file_contains(argv[3], "// CTF: Always pass certificate check in GUI")) {
        printf("[+] Found GUI certificate check bypass\n");
    } else {
        printf("[-] Missing GUI certificate check bypass\n");
        all_passed = 0;
    }

    printf("\n===========================================\n");
    if (all_passed) {
        printf("[+] All patches verified successfully!\n");
        printf("[+] Ready to build patched version\n");
        return 0;
    } else {
        printf("[-] Some patches are missing or incomplete\n");
        printf("[-] Please review the manual patch guide\n");
        return 1;
    }
}
