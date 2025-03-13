Thank you for sharing the next README to refine! Below is a polished, self-contained GitHub README for the **Pico Message Gadget** project, incorporating the provided details and ensuring clarity, structure, and usability for both beginners and advanced students. It addresses the key differences between the C++ and ARM assembly versions, enhances formatting, and includes all necessary instructions.

---

# Pico Message Gadget

The **Pico Message Gadget** is a message encryption tool for the Raspberry Pi Pico, implemented in both C++ and ARM assembly. It utilizes AES-CBC encryption with PKCS7 padding, built with the Pico SDK and mbedTLS library. The C++ version is designed to be accessible for beginners, while the ARM assembly version offers advanced students a deep dive into low-level programming on the ARM Cortex-M0+ processor.

## Features

- Encrypts user-input messages using a 128-bit AES key and initialization vector (IV).
- Displays ciphertext in a formatted, readable hex layout.
- Includes input validation and error handling.
- Showcases both high-level (C++) and low-level (ARM assembly) programming techniques.

## Prerequisites

- **Raspberry Pi Pico** with a USB cable.
- **Pico SDK** installed (refer to [Pico SDK Setup](https://www.raspberrypi.com/documentation/microcontrollers/raspberry-pi-pico.html)).
- **CMake** and **GNU ARM Toolchain** (e.g., `arm-none-eabi-gcc`).
- **Git** for cloning the repository.

## Repository Structure

```
pico_message_gadget/
├── main.cpp           # C++ implementation
├── main.S             # ARM assembly implementation
├── utils.c            # Helper functions (used by both versions)
├── utils.h            # Header for utils.c
├── CMakeLists.txt     # Build configuration
├── pico_sdk_import.cmake  # Pico SDK import script (assumed available)
├── README.md          # This file
└── .gitignore         # Ignore build artifacts
```

## Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/pico_message_gadget.git
   cd pico_message_gadget
   ```
   Replace `yourusername` with your actual GitHub username.

2. **Set Up Pico SDK**
   - Ensure the Pico SDK is installed and the `PICO_SDK_PATH` environment variable is set:
     ```bash
     export PICO_SDK_PATH=/path/to/pico-sdk
     ```
   - Place `pico_sdk_import.cmake` in the project directory (available from the Pico SDK).

3. **Choose Implementation**
   - For **C++**: In `CMakeLists.txt`, uncomment `main.cpp` and comment out `main.S`.
   - For **Assembly**: In `CMakeLists.txt`, uncomment `main.S` and comment out `main.cpp`.

4. **Build the Project**
   ```bash
   mkdir build
   cd build
   cmake ..
   make
   ```
   This generates a `pico_message_gadget.uf2` file.

5. **Flash to Pico**
   - Hold the **BOOTSEL** button on the Pico and connect it via USB.
   - Copy the `.uf2` file to the Pico (it mounts as a USB drive).
   - The Pico will reboot and run the program.

6. **Run the Program**
   - Open a terminal (e.g., PuTTY or Minicom) at 115200 baud.
   - Follow the prompts to input a message, key, and IV.

## Usage Example

```
Pico Message Gadget
Enter characters including spaces: Hello Pico
Enter 32 capital hex letters (secret key): 0123456789ABCDEF0123456789ABCDEF
Enter 32 capital hex letters (IV, PKCS7 padding): FEDCBA9876543210FEDCBA9876543210
1 5E6A8 7F9B2 3C4D1 E5F06 
Keys will be erased from RAM when the terminal closes.
```

## C++ Version Overview

The C++ implementation (`main.cpp`) provides a straightforward, high-level approach:
- Initializes the Pico’s USB stdio for communication.
- Prompts the user for a message, key, and IV.
- Validates inputs and performs AES-CBC encryption with PKCS7 padding using mbedTLS.
- Outputs the ciphertext in a formatted hex layout.

## Assembly Version Overview

The ARM assembly implementation (`main.S`) replicates the C++ functionality at a low-level, tailored for the Raspberry Pi Pico’s ARM Cortex-M0+ processor. Key differences from the C++ version include:

- **Manual Register Management**: Uses registers (e.g., `r0`-`r5`) instead of variables. Arguments are passed via `r0`, `r1`, etc., and registers are preserved manually as needed.
- **Stack Handling**: Explicitly sets up and tears down the stack frame with `push` and `pop` instructions.
- **Function Calls**: Calls C functions (e.g., from Pico SDK or mbedTLS) using `bl`, with arguments loaded into registers per the ARM calling convention.
- **No Automatic Memory Management**: Pre-allocates memory for variables in the `.bss` section, unlike C++’s automatic stack-allocated locals.
- **Comments**: Each section is annotated with the corresponding C++ code for educational clarity.

## Learning Objectives

- Gain insight into the ARM Cortex-M0+ instruction set.
- Explore low-level memory and register management.
- Compare high-level abstraction (C++) with machine-level code (assembly).

## Troubleshooting

- **Build Errors**: Verify that the Pico SDK and mbedTLS are correctly linked in `CMakeLists.txt`.
- **No Output**: Check the USB connection and terminal baud rate (115200).
- **Assembly Issues**: Ensure proper register usage and stack alignment in `main.S`.

## License

This project is open-source under the MIT License.

## `.gitignore`

The `.gitignore` file excludes build artifacts:
```
build/
*.uf2
*.elf
*.bin
*.map
*.hex
*.dis
CMakeCache.txt
CMakeFiles/
Makefile
cmake_install.cmake
```

---

### Instructions for Students

1. **Switch Between Versions**
   - Edit `CMakeLists.txt` to toggle between `main.cpp` (C++) and `main.S` (assembly).
   - Rebuild the project after switching files.

2. **Study the Code**
   - Compare `main.cpp` and `main.S` side-by-side to understand how C++ constructs map to assembly.
   - Pay attention to register usage, stack management, and function calls in `main.S`.

3. **Build and Test**
   - Follow the setup instructions to build the project.
   - Test with sample inputs to confirm that encryption outputs match between the C++ and assembly versions.

---

This README is now GitHub-ready, offering clear setup steps, usage details, and educational insights. Let me know if you’d like further adjustments or have additional READMEs to refine!
