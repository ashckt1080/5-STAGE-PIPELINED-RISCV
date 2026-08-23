## 100 MHz onboard clock
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { clk }]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0.000 5.000} [get_ports { clk }]

## Reset button - BTN0
set_property -dict { PACKAGE_PIN D9 IOSTANDARD LVCMOS33 } [get_ports { raw_rst }]

## Four user LEDs
set_property -dict { PACKAGE_PIN H5 IOSTANDARD LVCMOS33 } [get_ports { debug_led[0] }]
set_property -dict { PACKAGE_PIN J5 IOSTANDARD LVCMOS33 } [get_ports { debug_led[1] }]
set_property -dict { PACKAGE_PIN T9 IOSTANDARD LVCMOS33 } [get_ports { debug_led[2] }]
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { debug_led[3] }]

# raw_rst is asynchronous to clk.
# Ignore timing only from the external reset pin into the synchronizer.
set_false_path -from [get_ports {raw_rst}] \
               -to [get_pins -of_objects [get_cells -hier -filter {ASYNC_REG == TRUE}] -filter {REF_PIN_NAME == D}]