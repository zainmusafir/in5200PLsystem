set_false_path -from [get_clocks clk_fpga_0] -to [get_clocks -of_objects [get_pins G_PS.mla_ps/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins G_PS.mla_ps/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0]] -to [get_clocks clk_fpga_0]

create_pblock pblock_xbar
add_cells_to_pblock [get_pblocks pblock_xbar] [get_cells -quiet [list G_PS.mla_ps/axi_cpu_interconnect/xbar]]
resize_pblock [get_pblocks pblock_xbar] -add {SLICE_X26Y75:SLICE_X49Y124}
resize_pblock [get_pblocks pblock_xbar] -add {DSP48_X2Y30:DSP48_X2Y49}
resize_pblock [get_pblocks pblock_xbar] -add {RAMB18_X2Y30:RAMB18_X2Y49}
resize_pblock [get_pblocks pblock_xbar] -add {RAMB36_X2Y15:RAMB36_X2Y24}






