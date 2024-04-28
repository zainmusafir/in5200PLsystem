#!/usr/bin/tclsh

puts stdout "Reading design files ..."

#Path to repo
set repo_path $::env(MLA_DESIGN)

# MLA Package target file
set package_path $repo_path/

if {$::psmodule=="SIMPLE"} {
# Select SIMPLE processor system
set zedboard_package_list "/packages/zedboard_target_pck.vhd"
} else {
# Select FACERECON prosessor system
set zedboard_package_list "/packages/zedboard_facerecon_target_pck.vhd"
}

# PSIF Package files
set package_path $repo_path/
set psif_package_list "if/psif/packages/psif_pck.vhd \
                       if/psif/packages/psif_odi_pck.vhd \
                       if/psif/packages/psif_dti_pck.vhd \
                       if/psif/packages/psif_zu_pck.vhd \
                       if/psif/packages/psif_scu_pck.vhd \
                       if/psif/packages/psif_aui_pck.vhd"

# Read design IPs
set design_ip_path $repo_path/
set design_ip_list "if/psif/hdl/pif/axi4pifb/psif_axi4pifb_ent.vhd \
                    if/psif/hdl/pif/axi4pifb/psif_axi4pifb_rtl.vhd \
                    if/psif/hdl/pif/odi/psif_odi_reg_ent.vhd \
                    if/psif/hdl/pif/odi/psif_odi_reg_rtl.vhd \
                    if/psif/hdl/pif/dti/psif_dti_reg_ent.vhd \
                    if/psif/hdl/pif/dti/psif_dti_reg_rtl.vhd \
                    if/psif/hdl/pif/zu/psif_zu_reg_ent.vhd \
                    if/psif/hdl/pif/zu/psif_zu_reg_rtl.vhd \
                    if/psif/hdl/pif/scu/psif_scu_reg_ent.vhd \
                    if/psif/hdl/pif/scu/psif_scu_reg_rtl.vhd \
                    if/psif/hdl/pif/aui/psif_aui_reg_ent.vhd \
                    if/psif/hdl/pif/aui/psif_aui_reg_rtl.vhd"

# Read Chiper HLS IP
set inv_chiper_ip_path_vhdl $repo_path/core/zu/hdl/
set inv_chiper_ip_list_vhdl "aes_inv_cipher_dmy.vhd"


# VHDL design files
set vhdl_modules_path $repo_path/
set vhdl_module_list "core/cru/hdl/cru_ent.vhd \
                      core/cru/hdl/cru_rtl.vhd \
                      core/odi/hdl/ascii_rom.vhd \
                      core/odi/hdl/delay.vhd \
                      core/odi/hdl/oled_ctrl.vhd \
                      core/odi/hdl/oled_ex.vhd \
                      core/odi/hdl/oled_init.vhd \
                      core/odi/hdl/spi_ctrl.vhd \
                      core/odi/hdl/odi_ent.vhd \
                      core/odi/hdl/odi_str.vhd \
                      core/dti/hdl/dti_spi_ent.vhd \
                      core/dti/hdl/dti_spi_dmy.vhd \
                      core/dti/hdl/dti_ent.vhd \
                      core/dti/hdl/dti_str.vhd \
                      core/dti/hdl/spictrl_ent.vhd \
                      core/dti/hdl/spictrl_rtl.vhd \
                      core/zu/hdl/zu_fsm_ent.vhd \
                      core/zu/hdl/zu_fsm_dmy.vhd \
                      core/zu/hdl/zu_ent.vhd \
                      core/zu/hdl/zu_str.vhd \
                      core/scu/hdl/scu_fsm_ent.vhd \
                      core/scu/hdl/scu_fsm_rtl.vhd \
                      core/scu/hdl/scu_edge_regenerator_ent.vhd \
                      core/scu/hdl/scu_edge_regenerator_rtl.vhd \
                      core/scu/hdl/scu_ent.vhd \
                      core/scu/hdl/scu_str.vhd \
                      core/aui/hdl/aui_ent.vhd \
                      core/aui/hdl/aui_aurorarxctrl_ent.vhd \
                      core/aui/hdl/aui_aurorarxctrl_dmy.vhd \
                      core/aui/hdl/aui_auroratxctrl_ent.vhd \
                      core/aui/hdl/aui_auroratxctrl_dmy.vhd \
                      core/aui/hdl/aurora_8b10b_0_dmy.vhd \
                      core/aui/hdl/aui_str.vhd"

# Core VHDL design files
set core_path $repo_path/core/hdl/
set core_list "core_ent.vhd \
               core_str.vhd"


# Top VHDL design files
set top_path $repo_path/top/hdl/
set top_list "top_ent.vhd \
              top_str.vhd"


##############################################################
## Read HDL package files, design files and IP design files ##
##############################################################

foreach zedboard_pck_sourcefile $zedboard_package_list {
    read_vhdl -library mla_lib -vhdl2008 $package_path$zedboard_pck_sourcefile
}
foreach psif_pck_sourcefile $psif_package_list {
    read_vhdl -library psif_lib -vhdl2008 $package_path$psif_pck_sourcefile
}
foreach design_ip_sourcefile $design_ip_list {
    read_vhdl -vhdl2008 $design_ip_path$design_ip_sourcefile
}
foreach design_ip_sourcefile $inv_chiper_ip_list_vhdl {
    read_vhdl -vhdl2008 $inv_chiper_ip_path_vhdl$design_ip_sourcefile
}
foreach vhdl_sourcefile $vhdl_module_list {
    read_vhdl -vhdl2008 $vhdl_modules_path$vhdl_sourcefile
}
foreach core_sourcefile $core_list {
    read_vhdl -vhdl2008 $core_path$core_sourcefile
}
foreach top_sourcefile $top_list {
    read_vhdl -vhdl2008 $top_path$top_sourcefile
}

puts stdout "Reading design files done."

