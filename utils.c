// utils.c - Helper functions for Pico Message Gadget

#include "utils.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>

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
