################################ Main IO ################################ 
# Clock generation
# clk => 100.00MHz
create_clock -add -name clk_0 -period 10.0 -waveform {0.000 5.000} [get_ports clk]
    set_property PACKAGE_PIN N14 [get_ports {clk}]
        set_property IOSTANDARD LVCMOS33 [get_ports {clk}]

# Onboard LED IO instantiation
set_property PACKAGE_PIN K13 [get_ports {led[0]}]           # LED 0 on AU board
    set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]   # 3.3V CMOS declaration
set_property PACKAGE_PIN K12 [get_ports {led[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property PACKAGE_PIN L14 [get_ports {led[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property PACKAGE_PIN L13 [get_ports {led[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property PACKAGE_PIN M16 [get_ports {led[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
set_property PACKAGE_PIN M14 [get_ports {led[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]
set_property PACKAGE_PIN M12 [get_ports {led[6]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]
set_property PACKAGE_PIN N16 [get_ports {led[7]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]

# Reset button
set_property PACKAGE_PIN P6 [get_ports {rst_n}]
    set_property IOSTANDARD LVCMOS33 [get_ports {res_n}]

# USB
set_property PACKAGE_PIN P15 [get_ports {usb_rx}]
    set_property IOSTANDARD LVCMOS33 [get_ports {usb_rx}]
set_property PACKAGE_PIN P16 [get_ports {usb_tx}]
    set_property IOSTANDARD LVCMOS33 [get_ports {usb_tx}]
    
