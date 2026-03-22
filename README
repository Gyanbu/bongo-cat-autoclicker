# BongoCat Input Hook

A lightweight x64 utility that uses **DLL Sideloading** to intercept and modify keyboard input states within the BongoCat process via function hooking.

## 🛠 Technical Overview

This project implements a proxy for `version.dll`. When placed in the application directory, BongoCat loads this library instead of the system default. It passes all standard version calls to the OS while applying an inline hook to `GetAsyncKeyState`.

### Specifications
* **Method:** DLL Sideloading (Search Order Hijacking)
* **Hook Target:** `user32.dll!GetAsyncKeyState`
* **Architecture:** x86-64
* **Patch Size:** 12-byte absolute jump
* **Input Logic:** * Monitors for specific key query (Virtual Key `0x46`).
    * Returns a randomized state using the `RDRAND` instruction.
    * Returns `0` for all other queried keys to ensure clean execution.

---

## 🚀 Usage

### 1. Build
Compile the project using the master branch of [Zig compiler](https://ziglang.org/download/):
!!! IMPORTANT !!!
Use the master branch
```bash
zig build
```
### 2. Installation

  Locate the generated version.dll in zig-out/bin/.

  Place version.dll in the same folder as BongoCat.exe.

### 3. Execution

Run BongoCat normally.
