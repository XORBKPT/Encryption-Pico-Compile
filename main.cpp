// main.cpp - Pico Message Gadget in C++

#include "pico/stdlib.h"
#include "pico/stdio.h"
#include "mbedtls/aes.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#define MAX_MESSAGE_LEN 256
#define KEY_IV_LEN 16
#define BLOCK_SIZE 16

bool hex_to_bytes(const char* hex, uint8_t* bytes, size_t len) {
    if (strlen(hex) != 2 * len) return false;
    for (size_t i = 0; i < 2 * len; i++) {
        if (!isxdigit((unsigned char)hex[i])) return false;
    }
    for (size_t i = 0; i < len; i++) {
        sscanf(hex + 2 * i, "%2hhx", &bytes[i]);
    }
    return true;
}

void bytes_to_hex(const uint8_t* bytes, size_t len, char* hex) {
    for (size_t i = 0; i < len; i++) {
        sprintf(hex + 2 * i, "%02X", bytes[i]);
    }
    hex[2 * len] = '\0';
}

size_t pkcs7_pad(uint8_t* data, size_t len, uint8_t* padded) {
    size_t pad_len = BLOCK_SIZE - (len % BLOCK_SIZE);
    memcpy(padded, data, len);
    for (size_t i = len; i < len + pad_len; i++) {
        padded[i] = (uint8_t)pad_len;
    }
    return len + pad_len;
}

void print_formatted_hex(const char* hex, size_t len) {
    size_t line_num = 1;
    size_t index = 0;
    while (index < len) {
        printf("%2d ", (int)line_num);
        for (int group = 0; group < 5 && index < len; group++) {
            for (int j = 0; j < 5 && index < len; j++) {
                putchar(hex[index++]);
            }
            putchar(' ');
        }
        putchar('\n');
        if (line_num % 10 == 0) {
            printf("\n\n\n");
        }
        line_num++;
    }
}

int main() {
    stdio_init_all();
    while (!stdio_usb_connected()) {
        sleep_ms(100);
    }

    printf("Pico Message Gadget\n");

    char message[MAX_MESSAGE_LEN];
    char key_hex[33];
    char iv_hex[33];
    uint8_t key[KEY_IV_LEN];
    uint8_t iv[KEY_IV_LEN];
    uint8_t padded[MAX_MESSAGE_LEN + BLOCK_SIZE];
    uint8_t ciphertext[MAX_MESSAGE_LEN + BLOCK_SIZE];
    char hex_output[(MAX_MESSAGE_LEN + BLOCK_SIZE) * 2 + 1];

    printf("Enter characters including spaces: ");
    fgets(message, MAX_MESSAGE_LEN, stdin);
    message[strcspn(message, "\n")] = 0;

    printf("Enter 32 capital hex letters (secret key): ");
    fgets(key_hex, 33, stdin);
    key_hex[strcspn(key_hex, "\n")] = 0;

    printf("Enter 32 capital hex letters (IV, PKCS7 padding): ");
    fgets(iv_hex, 33, stdin);
    iv_hex[strcspn(iv_hex, "\n")] = 0;

    if (strlen(key_hex) != 32 || strlen(iv_hex) != 32) {
        printf("Error: Key and IV must be exactly 32 hex characters.\n");
        return 1;
    }

    if (!hex_to_bytes(key_hex, key, KEY_IV_LEN) || !hex_to_bytes(iv_hex, iv, KEY_IV_LEN)) {
        printf("Error: Invalid hex characters in key or IV.\n");
        return 1;
    }

    size_t msg_len = strlen(message);
    if (msg_len > MAX_MESSAGE_LEN - BLOCK_SIZE) {
        printf("Error: Message too long.\n");
        return 1;
    }

    size_t padded_len = pkcs7_pad((uint8_t*)message, msg_len, padded);

    mbedtls_aes_context aes;
    mbedtls_aes_init(&aes);
    if (mbedtls_aes_setkey_enc(&aes, key, 128) != 0) {
        printf("Error: Failed to set encryption key.\n");
        mbedtls_aes_free(&aes);
        return 1;
    }

    mbedtls_aes_crypt_cbc(&aes, MBEDTLS_AES_ENCRYPT, padded_len, iv, padded, ciphertext);
    mbedtls_aes_free(&aes);

    bytes_to_hex(ciphertext, padded_len, hex_output);
    print_formatted_hex(hex_output, strlen(hex_output));

    printf("Keys will be erased from RAM when the terminal closes.\n");
    return 0;
}
