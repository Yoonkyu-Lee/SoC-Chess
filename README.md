# SoC Chess

`SoC Chess` is an FPGA-based interactive chess interface built around a soft-core SoC design. A USB mouse is polled by MicroBlaze firmware, the resulting motion/button state is exposed to SystemVerilog over AXI GPIO, and the FPGA renders the board state to HDMI in real time.

This repository is the cleaned, source-first portfolio version of the project. The tracked source tree focuses on authored HDL, firmware, sprite assets, constraints, and rebuild scripts. Legacy Vivado/Vitis workspaces and course submission artifacts are intentionally excluded from the public-facing structure.

## Architecture

- Firmware on MicroBlaze polls a MAX3421E USB host controller over SPI.
- Mouse deltas and click state are written to dual-channel AXI GPIO.
- HDL converts that GPIO stream into a cursor, board selection state, move application, and piece rendering.
- A VGA timing generator drives the renderer, and a vendored RealDigital HDMI encoder produces TMDS output.

More detail is in [docs/architecture/usb-to-video-pipeline.md](/c:/Users/yoong/Desktop/Library/Personal%20Project/SoC-Chess/docs/architecture/usb-to-video-pipeline.md).

## Repo Layout

- `assets/chess/coe/`: COE files used to regenerate sprite ROM IP.
- `assets/chess/sprites/`: exported sprite images for documentation and portfolio assets.
- `fpga/rtl/`: top-level HDL, game logic, video pipeline, sprite wrappers, and vendored HDMI encoder RTL.
- `fpga/constraints/`: board pin constraints.
- `fpga/scripts/`: Tcl entrypoints to recreate the Vivado project and block design.
- `firmware/usb_mouse_bridge/`: MicroBlaze firmware source and XSCT build scripts.
- `docs/architecture/`: architecture and validation notes.

## Build Flow

Expected toolchain: `Vivado 2022.2` and `Vitis/XSCT 2022.2`.

FPGA project:

```powershell
vivado -mode batch -source fpga/scripts/create_project.tcl
vivado -mode batch -source fpga/scripts/build_bitstream.tcl
```

Firmware project:

```powershell
xsct firmware/usb_mouse_bridge/scripts/create_platform.tcl
xsct firmware/usb_mouse_bridge/scripts/build_firmware.tcl
```

The Vivado flow recreates:

- `soc_chess_fpga` as the clean project name
- `soc_chess_mb` as the MicroBlaze block design
- `clk_wiz_0` and the sprite ROM IPs from the checked-in COE files
- an exportable XSA for the firmware build

## Current Functional Scope

- Mouse-driven piece selection and movement on an 8x8 board
- HDMI video output with rendered board, pieces, selection border, and cursor
- Basic movement rules for all six piece types
- Turn indicator zones on the right side of the frame

Known limitations preserved from the original implementation:

- Sliding pieces do not yet check for blocking pieces along their path
- No check/checkmate detection
- No promotion, en passant, or full castling support

## Verification Status

This refactor was implemented without a connected FPGA board, and Vivado/Vitis are not installed in the current workspace yet. That means the repository has been statically refactored and prepared for reproducible tool-based rebuilds, but the following still need to be run after reinstalling the Xilinx tools:

- Vivado project recreation from Tcl
- block design regeneration
- synthesis / implementation / bitstream export
- XSA export and XSCT firmware build
- optional xsim smoke simulations for cursor motion and chess state updates

The intended validation sequence is documented in [docs/architecture/usb-to-video-pipeline.md](/c:/Users/yoong/Desktop/Library/Personal%20Project/SoC-Chess/docs/architecture/usb-to-video-pipeline.md).