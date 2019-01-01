# Physical-Layout-Design
Complete design of USART interface with baud rate selection
- This is a group project submitted by me along with Akash Tadmare as a part of our Advanced VLSI course.
- The report file gives an overview of the USART protocol and covers the coplete design flow.
- The usart_tx.v and usart_rx.v are the verilog descriptions for USART transmitter and receiver.
- siliconsmart.pl is the perl script which automates the library characterization by taking some inputs from the user.
- addvias.pl and pin_cover.tcl are the scripts to fix the potential DRC errors after PNR
- native_abs.pl is the perl script which handles the cross platform conversion of the .LEF file (virtuoso to encounter)
