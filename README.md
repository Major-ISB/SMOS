# SMOS (Saint Marc Operating System)

> [!IMPORTANT]
> This is a prototype project developed for educational purposes within the Computer Science department of Saint Marc High School.

---

## Project Overview
SMOS is an experimental operating system built from scratch to explore the fundamentals of low-level computing. By interfacing directly with the hardware, this project implements core OS concepts without relying on existing kernels.

### Core Technologies
| Component | Language | Purpose |
| :--- | :--- | :--- |
| **Bootloader** | Assembly (x86) | Initializing CPU registers and loading the kernel |
| **Kernel Logic** | C | Memory management, I/O operations, and system logic |

---

## Features & Goals
- [x] Custom Bootloader implementation
- [x] Basic Kernel initialization

---

## Behind the Code
> [!NOTE]
> This project is maintained by a student driven by curiosity about how software communicates with hardware at the most granular level.

## Credits & Acknowledgments
The development of SMOS is supported by the following open-source resources:

* **Bootloader & Kernel Foundations**: 
  * [Jothini231](https://github.com/Jothini231)
  * [Simple-Kernel-in-C-and-Assembly](https://github.com/chipsetx/Simple-Kernel-in-C-and-Assembly)

---

## Repository Metadata
* **Target Architecture**: x86 (32-bit)
* **License**: GPL v2.0
* **Environment**: Developed for QEMU