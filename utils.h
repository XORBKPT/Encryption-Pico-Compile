// utils.h - Header for helper functions

#ifndef UTILS_H
#define UTILS_H

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

#define BLOCK_SIZE 16

bool hex_to_bytes(const char* hex, uint8_t* bytes, size_t len);
void bytes_to_hex(const uint8_t* bytes, size_t len, char* hex);
size_t pkcs7_pad(uint8_t* data, size_t len, uint8_t* padded);
void print_formatted_hex(const char* hex, size_t len);

#endif
