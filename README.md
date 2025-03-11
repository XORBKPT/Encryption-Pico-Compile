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
