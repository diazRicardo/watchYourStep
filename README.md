# 🎮 Watch Your Step (FPGA VGA Game)

An FPGA-based implementation of the game **“Watch Your Step”** on the Basys3 board using Verilog and VGA output.  
This project was the **final project for my Logic Design (CSE 100)** course. It demonstrates VGA signal generation, synchronous digital design, and interactive gameplay.  

---

## 📹 Demo
[![Watch the demo](images/demo_thumbnail.png)](https://youtu.be/your-demo-link)  
*(Click to watch the game in action!)*

---

## ✨ Features
- VGA controller generating **640x480 display** at 60Hz
- Player character with **jump mechanic** controlled by power bar
- Moving **platform hole** that the player must avoid
- Moving **ball object** that the player can tag to score points
- **Score display** on the 7-segment LEDs
- **Game-over state** when the player falls through the hole
- **Extra Credit:** Implemented **color-change effect** when ball is tagged

---

## 🖼️ System Overview
![System Block Diagram](images/system_block_diagram.png)

---

## ⚙️ Hardware & Tools
- **Board:** Digilent Basys3 FPGA (Xilinx Artix-7)
- **Display:** VGA monitor (640x480)
- **HDL:** Verilog (structural, using only `assign` and FDRE flip-flops)
- **Toolchain:** Vivado [version]

---

## 📂 Repo Structure
├── /src # Verilog source files

├── /test # Testbenches & simulation outputs

├── /images # Diagrams, screenshots

└── README.md # This file


---

## 🚀 How to Run
### Prerequisites
- Vivado [version]
- Basys3 FPGA board
- VGA monitor

### Build & Run
Clone this repo:
   ```bash
   git clone https://github.com/your-username/watch-your-step-fpga.git
   cd watch-your-step-fpga
Open project in Vivado

Generate bitstream and program FPGA

Connect VGA monitor to Basys3 board

Use pushbuttons to play:

btnC → Start game

btnU → Jump (hold to charge power bar, release to jump)

btnR → Reset game

## 🧩 Provided Files

We were given starter modules/files to use in this project:

labVGA_clks.v → Generates 25MHz VGA clock and digit select signal

test_lab6_syncs.v → Testbench for VGA sync validation

Ring Counter / Hex7Seg display logic (from earlier labs)

## 🧩 Lessons Learned

Designing VGA synchronization logic (Hsync/Vsync, pixel addressing)

Timing gameplay logic to frame refresh cycles

Using purely structural Verilog (only assign and FDRE)

Debugging with both simulation and real monitor feedback

## 🔮 Future Work

Add second extra credit feature: lives system with btnL input

Add sound effects with PMOD audio

Optimize object rendering for higher resolution
