# USB-to-Video Pipeline

## System Partition

The design is split intentionally between firmware and HDL:

- Firmware handles USB host interaction with the MAX3421E controller.
- HDL handles cursor integration, board state storage, move validation, and pixel generation.

That split keeps protocol handling in software while preserving deterministic pixel timing and board updates in hardware.

## End-to-End Data Flow

1. The MAX3421E USB host controller is connected to MicroBlaze over AXI Quad SPI.
2. The firmware in `firmware/usb_mouse_bridge/src/usb_mouse_bridge.c` polls the attached mouse and packs X delta, Y delta, and button state into AXI GPIO outputs.
3. `fpga/rtl/video/mouse_cursor.sv` converts the signed deltas into a screen-space cursor position.
4. `fpga/rtl/game/chess_game_logic.sv` interprets cursor position plus click state as piece selection and destination selection events.
5. `fpga/rtl/video/chess_renderer.sv` owns the board array, applies piece writes from the game logic, and composites the board, pieces, selection border, cursor, and turn indicator.
6. `fpga/rtl/common/vga_controller.sv` generates the 640x480 timing domain.
7. `fpga/rtl/vendor/hdmi_tx/hdmi_tx_v1_0.v` serializes the rendered RGB stream into TMDS for HDMI output.

## Rebuild Strategy

The clean repository is Tcl-first:

- `fpga/scripts/create_project.tcl` creates a fresh Vivado project, adds authored RTL, regenerates the clock wizard and sprite ROM IP, and recreates the block design.
- `fpga/scripts/build_bitstream.tcl` is the non-interactive synthesis/implementation/bitstream entrypoint.
- `firmware/usb_mouse_bridge/scripts/create_platform.tcl` creates a Vitis platform from the exported XSA.
- `firmware/usb_mouse_bridge/scripts/build_firmware.tcl` rebuilds the firmware application from the clean source tree.

## Verification Plan

Without hardware:

- Recreate the Vivado project from Tcl
- Validate and regenerate the block design
- Run synthesis and implementation
- Export an XSA
- Rebuild the firmware ELF in XSCT

Recommended follow-up smoke simulations once Vivado is installed:

- `mouse_cursor`: signed delta accumulation and screen-edge clamp behavior
- `chess_game_logic`: select -> move -> clear-origin -> turn-toggle sequence
- `chess_renderer`: board indexing and selection overlay behavior

With hardware later:

- Validate USB mouse enumeration and button/delta propagation
- Validate live HDMI output
- Validate cursor feel and click responsiveness on the target Spartan-7 board

