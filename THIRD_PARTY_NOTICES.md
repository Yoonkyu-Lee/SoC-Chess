# Third-Party Notices

## RealDigital HDMI Encoder RTL

Files:

- `fpga/rtl/vendor/hdmi_tx/encode.v`
- `fpga/rtl/vendor/hdmi_tx/hdmi_tx_v1_0.v`
- `fpga/rtl/vendor/hdmi_tx/serdes_10_to_1.v`
- `fpga/rtl/vendor/hdmi_tx/srldelay.v`

These files are vendored from the RealDigital HDMI encoder source used by the original design. The retained file headers identify the code as `Copyright @ 2017 RealDigital.org` and license it under the BSD 3-Clause License.

## Xilinx Platform Support Code

Files:

- `firmware/usb_mouse_bridge/src/platform.c`
- `firmware/usb_mouse_bridge/include/platform.h`
- `firmware/usb_mouse_bridge/include/platform_config.h`

These files retain their original Xilinx license headers. That license is permissive for use with Xilinx-targeted software and should remain attached to the copied files.

## Lightweight USB Host Stack (`lw_usb`)

Files:

- `firmware/usb_mouse_bridge/src/lw_usb/*`

The local snapshot includes provenance text in `firmware/usb_mouse_bridge/src/lw_usb/README`, but it does not include an explicit software license in the copied source files. The code is kept here to preserve the original project structure and rebuild path, but the licensing for this subtree should be verified or replaced before publishing the repository as a fully public portfolio artifact.

