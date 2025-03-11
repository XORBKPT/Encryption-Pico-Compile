@ main.S - ARM Assembly version of the Pico Message Gadget
@ Translated from the C++ version to demonstrate low-level ARM programming

@ Define constants (same as C++ #defines)
.equ MAX_MESSAGE_LEN, 256
.equ KEY_IV_LEN, 16
.equ BLOCK_SIZE, 16
.equ MBEDTLS_AES_ENCRYPT, 1  @ From mbedTLS header

@ External function declarations (C functions called from assembly)
.extern stdio_init_all         @ void stdio_init_all();
.extern stdio_usb_connected    @ bool stdio_usb_connected();
.extern sleep_ms               @ void sleep_ms(uint32_t ms);
.extern printf                 @ int printf(const char* format, ...);
.extern fgets                  @ char* fgets(char* str, int num, FILE* stream);
.extern strlen                 @ size_t strlen(const char* str);
.extern mbedtls_aes_init       @ void mbedtls_aes_init(mbedtls_aes_context* ctx);
.extern mbedtls_aes_setkey_enc @ int mbedtls_aes_setkey_enc(mbedtls_aes_context* ctx, const uint8_t* key, unsigned int keybits);
.extern mbedtls_aes_crypt_cbc  @ int mbedtls_aes_crypt_cbc(mbedtls_aes_context* ctx, int mode, size_t length, uint8_t* iv, const uint8_t* input, uint8_t* output);
.extern mbedtls_aes_free       @ void mbedtls_aes_free(mbedtls_aes_context* ctx);
.extern hex_to_bytes           @ bool hex_to_bytes(const char* hex, uint8_t* bytes, size_t len);
.extern bytes_to_hex           @ void bytes_to_hex(const uint8_t* bytes, size_t len, char* hex);
.extern pkcs7_pad              @ size_t pkcs7_pad(uint8_t* data, size_t len, uint8_t* padded);
.extern print_formatted_hex     @ void print_formatted_hex(const char* hex, size_t len);

@ Data section (initialized data, equivalent to C++ string literals)
.section .data
welcome:    .asciz "Pico Message Gadget\n"
prompt_msg: .asciz "Enter characters including spaces: "
prompt_key: .asciz "Enter 32 capital hex letters (secret key): "
prompt_iv:  .asciz "Enter 32 capital hex letters (IV, PKCS7 padding): "
error_len:  .asciz "Error: Key and IV must be exactly 32 hex characters.\n"
error_hex:  .asciz "Error: Invalid hex characters in key or IV.\n"
error_msg:  .asciz "Error: Message too long.\n"
error_key:  .asciz "Error: Failed to set encryption key.\n"
keys_erased:.asciz "Keys will be erased from RAM when the terminal closes.\n"

@ BSS section (uninitialized data, equivalent to C++ local arrays)
.section .bss
.align 4
message:    .space MAX_MESSAGE_LEN                    @ char message[MAX_MESSAGE_LEN];
key_hex:    .space 33                                 @ char key_hex[33];
iv_hex:     .space 33                                 @ char iv_hex[33];
key:        .space KEY_IV_LEN                         @ uint8_t key[KEY_IV_LEN];
iv:         .space KEY_IV_LEN                         @ uint8_t iv[KEY_IV_LEN];
padded:     .space MAX_MESSAGE_LEN + BLOCK_SIZE       @ uint8_t padded[MAX_MESSAGE_LEN + BLOCK_SIZE];
ciphertext: .space MAX_MESSAGE_LEN + BLOCK_SIZE       @ uint8_t ciphertext[MAX_MESSAGE_LEN + BLOCK_SIZE];
hex_output: .space (MAX_MESSAGE_LEN + BLOCK_SIZE) * 2 + 1  @ char hex_output[(MAX_MESSAGE_LEN + BLOCK_SIZE) * 2 + 1];
aes_ctx:    .space 256                                @ mbedtls_aes_context aes; (size estimated, adjust per mbedTLS)

@ Text section (code)
.section .text
.global main
main:
    @ === C++: Setup stack frame (no direct equivalent, assembly-specific) ===
    push {fp, lr}           @ Save frame pointer and link register
    mov fp, sp              @ Set frame pointer to current stack pointer

    @ === C++: stdio_init_all(); ===
    bl stdio_init_all       @ Initialize standard I/O

    @ === C++: while (!stdio_usb_connected()) { sleep_ms(100); } ===
wait_usb:
    bl stdio_usb_connected  @ Check USB connection
    cmp r0, #0              @ Compare return value with 0 (false)
    beq sleep_100ms         @ If not connected, sleep
    b continue              @ If connected, proceed
sleep_100ms:
    mov r0, #100            @ Argument: 100ms
    bl sleep_ms             @ Sleep for 100ms
    b wait_usb              @ Loop back to check again

continue:
    @ === C++: printf("Pico Message Gadget\n"); ===
    ldr r0, =welcome        @ Load address of welcome message
    bl printf               @ Print welcome message

    @ === C++: printf("Enter characters including spaces: "); fgets(message, MAX_MESSAGE_LEN, stdin); ===
    ldr r0, =prompt_msg     @ Load prompt for message
    bl printf               @ Print prompt
    ldr r0, =message        @ Buffer to store message
    mov r1, #MAX_MESSAGE_LEN @ Maximum length
    bl fgets                @ Read message from stdin

    @ === C++: printf("Enter 32 capital hex letters (secret key): "); fgets(key_hex, 33, stdin); ===
    ldr r0, =prompt_key     @ Load prompt for key
    bl printf               @ Print prompt
    ldr r0, =key_hex        @ Buffer to store key
    mov r1, #33             @ Maximum length (32 chars + null)
    bl fgets                @ Read key from stdin

    @ === C++: printf("Enter 32 capital hex letters (IV, PKCS7 padding): "); fgets(iv_hex, 33, stdin); ===
    ldr r0, =prompt_iv      @ Load prompt for IV
    bl printf               @ Print prompt
    ldr r0, =iv_hex         @ Buffer to store IV
    mov r1, #33             @ Maximum length (32 chars + null)
    bl fgets                @ Read IV from stdin

    @ === C++: if (strlen(key_hex) != 32 || strlen(iv_hex) != 32) { ... } ===
    ldr r0, =key_hex        @ Load key_hex address
    bl strlen               @ Get length of key_hex
    cmp r0, #32             @ Compare with 32
    bne error_length        @ If not 32, error
    ldr r0, =iv_hex         @ Load iv_hex address
    bl strlen               @ Get length of iv_hex
    cmp r0, #32             @ Compare with 32
    bne error_length        @ If not 32, error

    @ === C++: if (!hex_to_bytes(key_hex, key, KEY_IV_LEN) || !hex_to_bytes(iv_hex, iv, KEY_IV_LEN)) { ... } ===
    ldr r0, =key_hex        @ Source: key_hex
    ldr r1, =key            @ Destination: key
    mov r2, #KEY_IV_LEN     @ Length: 16 bytes
    bl hex_to_bytes         @ Convert hex to bytes
    cmp r0, #0              @ Check return value (0 = false)
    beq error_hex           @ If false, error
    ldr r0, =iv_hex         @ Source: iv_hex
    ldr r1, =iv             @ Destination: iv
    mov r2, #KEY_IV_LEN     @ Length: 16 bytes
    bl hex_to_bytes         @ Convert hex to bytes
    cmp r0, #0              @ Check return value
    beq error_hex           @ If false, error

    @ === C++: size_t msg_len = strlen(message); ===
    ldr r0, =message        @ Load message address
    bl strlen               @ Get message length
    mov r4, r0              @ Store msg_len in r4

    @ === C++: if (msg_len > MAX_MESSAGE_LEN - BLOCK_SIZE) { ... } ===
    cmp r4, #MAX_MESSAGE_LEN - BLOCK_SIZE  @ Compare with max allowed length
    bge error_msg_len       @ If too long, error

    @ === C++: size_t padded_len = pkcs7_pad((uint8_t*)message, msg_len, padded); ===
    ldr r0, =message        @ Source data
    mov r1, r4              @ Length (msg_len from r4)
    ldr r2, =padded         @ Destination buffer
    bl pkcs7_pad            @ Apply PKCS7 padding
    mov r5, r0              @ Store padded_len in r5

    @ === C++: mbedtls_aes_init(&aes); ===
    ldr r0, =aes_ctx        @ Load AES context address
    bl mbedtls_aes_init     @ Initialize AES context

    @ === C++: if (mbedtls_aes_setkey_enc(&aes, key, 128) != 0) { ... } ===
    ldr r0, =aes_ctx        @ AES context
    ldr r1, =key            @ Key buffer
    mov r2, #128            @ Key size in bits
    bl mbedtls_aes_setkey_enc  @ Set encryption key
    cmp r0, #0              @ Check return value (0 = success)
    bne error_setkey        @ If not 0, error

    @ === C++: mbedtls_aes_crypt_cbc(&aes, MBEDTLS_AES_ENCRYPT, padded_len, iv, padded, ciphertext); ===
    ldr r0, =aes_ctx        @ AES context
    mov r1, #MBEDTLS_AES_ENCRYPT  @ Mode: encrypt
    mov r2, r5              @ Length (padded_len from r5)
    ldr r3, =iv             @ IV
    push {r3}               @ Push r3 to stack (callee-saved)
    ldr r3, =padded         @ Input data
    ldr r4, =ciphertext     @ Output buffer
    push {r4}               @ Push r4 to stack
    bl mbedtls_aes_crypt_cbc  @ Perform AES-CBC encryption
    pop {r4}                @ Restore r4
    pop {r3}                @ Restore r3

    @ === C++: mbedtls_aes_free(&aes); ===
    ldr r0, =aes_ctx        @ AES context
    bl mbedtls_aes_free     @ Free AES context

    @ === C++: bytes_to_hex(ciphertext, padded_len, hex_output); ===
    ldr r0, =ciphertext     @ Source: ciphertext
    mov r1, r5              @ Length (padded_len from r5)
    ldr r2, =hex_output     @ Destination: hex_output
    bl bytes_to_hex         @ Convert to hex string

    @ === C++: print_formatted_hex(hex_output, strlen(hex_output)); ===
    ldr r0, =hex_output     @ Load hex_output address
    bl strlen               @ Get length of hex_output
    mov r1, r0              @ Length argument
    ldr r0, =hex_output     @ String argument
    bl print_formatted_hex  @ Print formatted hex

    @ === C++: printf("Keys will be erased from RAM when the terminal closes.\n"); ===
    ldr r0, =keys_erased    @ Load message
    bl printf               @ Print message

    @ === C++: return 0; ===
    mov r0, #0              @ Return code 0
    pop {fp, pc}            @ Restore frame pointer and return

@ Error handlers (equivalent to C++ error printf and return 1)
error_length:
    ldr r0, =error_len      @ Load error message
    bl printf               @ Print error
    mov r0, #1              @ Return code 1
    pop {fp, pc}            @ Return

error_hex:
    ldr r0, =error_hex      @ Load error message
    bl printf               @ Print error
    mov r0, #1              @ Return code 1
    pop {fp, pc}            @ Return

error_msg_len:
    ldr r0, =error_msg      @ Load error message
    bl printf               @ Print error
    mov r0, #1              @ Return code 1
    pop {fp, pc}            @ Return

error_setkey:
    ldr r0, =error_key      @ Load error message
    bl printf               @ Print error
    mov r0, #1              @ Return code 1
    pop {fp, pc}            @ Return
