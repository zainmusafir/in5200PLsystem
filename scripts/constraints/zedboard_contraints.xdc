# ----------------------------------------------------------------------------
# External Primary Clocks
# ----------------------------------------------------------------------------
create_clock -period 10.000 -name refclk -waveform {0.000 5.000} [get_ports refclk]

# ----------------------------------------------------------------------------
# Internal Clocks
# ----------------------------------------------------------------------------
# create_clock -period 10.000 -name clk_fpga_0 -waveform {0.000 5.000} [get_ports clk_fpga_0]

# ----------------------------------------------------------------------------
# Asynchronous Clocks Groups
# ----------------------------------------------------------------------------
# Setting the the asynchronous clocks manually or as shown under using the -include_generated_clocks switch
#   to use the primary input clock (i.e. refclk) and then the Vivado tool will find the internal generated clocks.
# set_clock_groups -asynchronous -group [get_clocks clk_fpga_0] -group [get_clocks clk_out1_clk_wiz_0]
set_clock_groups -asynchronous -group [get_clocks clk_fpga_0] -group [get_clocks -include_generated_clocks refclk]
# Facerecon design
set_clock_groups -asynchronous -group [get_clocks clk_fpga_0] -group [get_clocks mmcm_clk_0_s]

# ----------------------------------------------------------------------------
# Design Properties Constraints
# ----------------------------------------------------------------------------
set_property ASYNC_REG true [get_cells -hier *_s1_reg*]
set_property ASYNC_REG true [get_cells -hier *_s2_reg*]
set_property ASYNC_REG true [get_cells -hier *_s3_reg*]

# ----------------------------------------------------------------------------
# Pinout and Related I/O Constraints
# ----------------------------------------------------------------------------
# Reference clock in bank 33
set_property PACKAGE_PIN Y9 [get_ports refclk]

# ----------------------------------------------------------------------------
# Push buttons in bank 34
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN P16 [get_ports fpga_rst]
set_property PACKAGE_PIN R18 [get_ports alarm_ack_btn]

# ----------------------------------------------------------------------------
# hdmi
# ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports hdmi_out_clk]
set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports hdmi_vsync]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports hdmi_hsync]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports hdmi_data_e]
set_property -dict {PACKAGE_PIN Y13 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[0]}]
set_property -dict {PACKAGE_PIN AA13 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[1]}]
set_property -dict {PACKAGE_PIN AA14 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[2]}]
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[3]}]
set_property -dict {PACKAGE_PIN AB15 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[4]}]
set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[5]}]
set_property -dict {PACKAGE_PIN AA16 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[6]}]
set_property -dict {PACKAGE_PIN AB17 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[7]}]
set_property -dict {PACKAGE_PIN AA17 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[8]}]
set_property -dict {PACKAGE_PIN Y15 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[9]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[10]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[11]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[12]}]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[13]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[14]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {hdmi_data[15]}]

# ----------------------------------------------------------------------------
# iic
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN AA18 [get_ports {iic_mux_scl[1]}]
set_property PULLUP true [get_ports {iic_mux_scl[1]}]
set_property PACKAGE_PIN Y16 [get_ports {iic_mux_sda[1]}]
set_property PULLUP true [get_ports {iic_mux_sda[1]}]
set_property PACKAGE_PIN AB4 [get_ports {iic_mux_scl[0]}]
set_property PULLUP true [get_ports {iic_mux_scl[0]}]
set_property PACKAGE_PIN AB5 [get_ports {iic_mux_sda[0]}]
set_property PULLUP true [get_ports {iic_mux_sda[0]}]

# ----------------------------------------------------------------------------
# otg
# ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports otg_vbusoc]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS25} [get_ports otg_resetn]

# ----------------------------------------------------------------------------
# LEDs in bank 33
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN T22 [get_ports {led_8bit[0]}]
set_property PACKAGE_PIN T21 [get_ports {led_8bit[1]}]
set_property PACKAGE_PIN U22 [get_ports {led_8bit[2]}]
set_property PACKAGE_PIN U21 [get_ports {led_8bit[3]}]
set_property PACKAGE_PIN V22 [get_ports {led_8bit[4]}]
set_property PACKAGE_PIN W22 [get_ports {led_8bit[5]}]
set_property PACKAGE_PIN U19 [get_ports {led_8bit[6]}]
set_property PACKAGE_PIN U14 [get_ports {led_8bit[7]}]

# ----------------------------------------------------------------------------
# OLED Display - Bank 13
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN U10 [get_ports oled_dc]
set_property PACKAGE_PIN U9 [get_ports oled_res]
set_property PACKAGE_PIN AB12 [get_ports oled_sclk]
set_property PACKAGE_PIN AA12 [get_ports oled_sdin]
set_property PACKAGE_PIN U11 [get_ports oled_vbat]
set_property PACKAGE_PIN U12 [get_ports oled_vdd]

# ----------------------------------------------------------------------------
# JA Pmod - Bank 13
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN Y11 [get_ports dti_ce]
set_property PACKAGE_PIN AA11 [get_ports dti_sdi]
set_property PACKAGE_PIN Y10 [get_ports dti_sdo]
set_property PACKAGE_PIN AA9 [get_ports dti_sclk]
# set_property PACKAGE_PIN AB11 [get_ports {JA7}];    # "JA7"
# set_property PACKAGE_PIN AB10 [get_ports {JA8}];    # "JA8"
# set_property PACKAGE_PIN AB9  [get_ports {JA9}];    # "JA9"
# set_property PACKAGE_PIN AA8  [get_ports {JA10}];   # "JA10"

# ----------------------------------------------------------------------------
# FMC connector; just used I/O as dummy for RFI module
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN L21 [get_ports rf_gt_refclk1_p]
set_property PACKAGE_PIN L22 [get_ports rf_gt_refclk1_n]
set_property PACKAGE_PIN R19 [get_ports rf_rxp]
set_property PACKAGE_PIN T19 [get_ports rf_rxn]
set_property PACKAGE_PIN K19 [get_ports rf_txp]
set_property PACKAGE_PIN K20 [get_ports rf_txn]

# Note that the bank voltage for IO Bank 13 is fixed to 3.3V on ZedBoard.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]]

# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]]

# Set the bank voltage for IO Bank 34 to 3.3V.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]]
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 34]];
# set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];

# Set the bank voltage for IO Bank 35 to 3.3V. (currently not used)
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]]
# # set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 35]];
# # set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]];



