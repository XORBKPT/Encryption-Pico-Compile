pico_message_gadget/
├── main.cpp           # C++ version
├── main.S             # ARM assembly version
├── utils.c            # Helper functions in C
├── utils.h            # Header for utils.c
├── CMakeLists.txt     # Build configuration
├── pico_sdk_import.cmake  # Pico SDK import script (assumed available)
├── README.md          # Detailed instructions
└── .gitignore         # Ignore build artifacts

Key Differences from C++
Manual Register Management: Assembly uses registers (e.g., r0-r5) instead of C++ variables. We manually pass arguments and preserve registers as needed.
Stack Handling: The stack frame is explicitly set up and torn down (push/pop).
Function Calls: C functions are called with bl, and arguments are loaded into r0, r1, etc., per the ARM calling convention.
No Automatic Memory Management: Memory for variables is pre-allocated in .bss, unlike C++’s stack-allocated locals.

C++ program:

Initializes the Pico’s USB stdio.
Prompts for a message, key, and IV.
Validates inputs and performs AES-CBC encryption with PKCS7 padding.
Outputs the ciphertext in a formatted hex layout.

ARM Assembly Version with C++ Mapping
Explains which sections correspond to the C++ code.
Sculpted for the Raspberry Pi Pico’s ARM Cortex-M0+ processor.

README.md
markdown

Collapse

Wrap

Copy
# Pico Message Gadget

This repository contains a message encryption program for the Raspberry Pi Pico, implemented in both C++ and ARM assembly. It uses AES-CBC encryption with PKCS7 padding, leveraging the Pico SDK and mbedTLS library. The C++ version is beginner-friendly, while the ARM assembly version is designed for advanced students to explore low-level programming.

## Features

- Encrypts user-input messages using a 128-bit AES key and IV.
- Formats ciphertext output in a readable hex layout.
- Includes input validation and error handling.
- Demonstrates high-level (C++) and low-level (ARM assembly) programming.

## Prerequisites

- **Raspberry Pi Pico** with a USB cable.
- **Pico SDK** installed (see [Pico SDK Setup](https://www.raspberrypi.com/documentation/microcontrollers/raspberry-pi-pico.html)).
- **CMake** and **GNU ARM Toolchain** (e.g., `arm-none-eabi-gcc`).
- **Git** for cloning the repository.

## Repository Structure
pico_message_gadget/
├── main.cpp           # C++ implementation
├── main.S             # ARM assembly implementation
├── utils.c            # Helper functions (used by both versions)
├── utils.h            # Header for utils.c
├── CMakeLists.txt     # Build configuration
├── pico_sdk_import.cmake  # Pico SDK import script (assumed available)
├── README.md          # This file
└── .gitignore         # Ignore build artifacts

text

Collapse

Wrap

Copy

## Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/pico_message_gadget.git
   cd pico_message_gadget
Set Up Pico SDK
Ensure the Pico SDK is installed and the PICO_SDK_PATH environment variable is set (e.g., export PICO_SDK_PATH=/path/to/pico-sdk).
Place pico_sdk_import.cmake in the project directory (available from the Pico SDK).
Choose Implementation
For C++: In CMakeLists.txt, comment out main.S and uncomment main.cpp.
For Assembly: In CMakeLists.txt, ensure main.S is included and main.cpp is commented out.
Build the Project
bash

Collapse

Wrap

Copy
mkdir build
cd build
cmake ..
make
This generates a pico_message_gadget.uf2 file.
Flash to Pico
Hold the BOOTSEL button on the Pico and connect it via USB.
Copy the .uf2 file to the Pico (it appears as a USB drive).
The Pico will reboot and run the program.
Run the Program
Open a terminal (e.g., PuTTY, Minicom) at 115200 baud.
Follow the prompts to enter a message, key, and IV.
Usage Example
text

Collapse

Wrap

Copy
Pico Message Gadget
Enter characters including spaces: Hello Pico
Enter 32 capital hex letters (secret key): 0123456789ABCDEF0123456789ABCDEF
Enter 32 capital hex letters (IV, PKCS7 padding): FEDCBA9876543210FEDCBA9876543210
1 5E6A8 7F9B2 3C4D1 E5F06 
Keys will be erased from RAM when the terminal closes.
Assembly Version Notes
The main.S file is an ARM assembly implementation of the same functionality as main.cpp. Key aspects:

Direct C Function Calls: Interfaces with Pico SDK and mbedTLS functions.
Register Usage: Manages ARM registers manually (e.g., r0 for arguments, r4/r5 for variables).
Stack Management: Explicitly handles the stack for function calls and local data.
Comments: Each section is annotated with the corresponding C++ code for learning purposes.
Learning Objectives
Understand ARM Cortex-M0+ instruction set.
Explore low-level memory and register management.
Compare high-level abstraction (C++) with machine-level code (assembly).
Troubleshooting
Build Errors: Ensure the Pico SDK and mbedTLS are correctly linked.
No Output: Verify USB connection and terminal settings.
Assembly Issues: Check register usage and stack alignment.
Contributing
Feel free to fork this repository, submit issues, or contribute improvements via pull requests!

License
This project is open-source under the MIT License.

text

Collapse

Wrap

Copy

7. **`.gitignore`**
.gitignore - Ignore build artifacts
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

text

Collapse

Wrap

Copy

---

### Instructions for Students

1. **Switch Between Versions:**
   - Edit `CMakeLists.txt` to toggle between `main.cpp` (C++) and `main.S` (assembly).
   - Rebuild after changing the source file.

2. **Study the Code:**
   - Compare `main.cpp` and `main.S` side-by-side to see how C++ constructs translate to assembly.
   - Focus on register usage, stack management, and function calls in `main.S`.

3. **Build and Test:**
   - Follow the README’s build instructions.
   - Test with sample inputs to verify encryption output matches between versions.

This setup provides a comprehensive learning tool, bridging high-level programming with low-level
