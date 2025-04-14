set_device -family {SmartFusion2} -die {M2S005} -speed {STD}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\hdl\Ram_interface.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\component\Actel\SgCore\TAMPER\2.1.300\tamper_comps.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\component\work\TAMPER_C0\TAMPER_C0_0\TAMPER_C0_TAMPER_C0_0_TAMPER.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\component\work\TAMPER_C0\TAMPER_C0.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\component\work\TPSRAM_C0\TPSRAM_C0_0\TPSRAM_C0_TPSRAM_C0_0_TPSRAM.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\component\work\TPSRAM_C0\TPSRAM_C0.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\component\work\Dev_Restart_after_IAP_blk\Dev_Restart_after_IAP_blk.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\component\Actel\DirectCore\CoreResetP\7.1.100\rtl\vlog\core\coreresetp_pcie_hotreset.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\component\Actel\DirectCore\CoreResetP\7.1.100\rtl\vlog\core\coreresetp.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\component\work\teste_sb\CCC_0\teste_sb_CCC_0_FCCC.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\component\work\teste_sb\FABOSC_0\teste_sb_FABOSC_0_OSC.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\component\work\teste_sb_MSS\teste_sb_MSS.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\component\work\teste_sb\teste_sb.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\component\work\teste\teste.v}
set_top_level {teste}
map_netlist
check_constraints {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\constraint\synthesis_sdc_errors.log}
write_fdc {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\designer\teste\synthesis.fdc}
