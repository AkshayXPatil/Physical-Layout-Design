# Physical-Layout-Design
Complete design of USART interface with baud rate selection
- This is a group project submitted by me along with [Akash Tadmare](https://github.com/akash10295) as a part of our Advanced VLSI course.
- The [report](https://github.com/AkshayXPatil/Physical-Layout-Design/blob/master/Report.pdf) file gives an overview of the USART protocol and covers the complete design flow.
- The [usart_tx.v](https://github.com/AkshayXPatil/Physical-Layout-Design/blob/master/uart_tx.v) and [usart_rx.v](https://github.com/AkshayXPatil/Physical-Layout-Design/blob/master/uart_rx.v) are the verilog descriptions for USART transmitter and receiver.
- [siliconsmart.pl](https://github.com/AkshayXPatil/Physical-Layout-Design/blob/master/siliconsmart.pl) is the perl script which automates the library characterization by taking some inputs from the user.
- [native_abs.pl](https://github.com/AkshayXPatil/Physical-Layout-Design/blob/master/native_abs.pl) is the perl script which handles the cross platform conversion of the .LEF file (virtuoso to encounter).
- [addvias.pl](https://github.com/AkshayXPatil/Physical-Layout-Design/blob/master/addvias.pl) and [pin_cover.tcl](https://github.com/AkshayXPatil/Physical-Layout-Design/blob/master/pin_cover.tcl) are the scripts to fix the potential DRC errors after PNR.
