set_device -family {SmartFusion2} -die {M2S005} -speed {STD}
read_verilog -mode system_verilog -lib COREMEMCTRL_LIB {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\Actel\DirectCore\CoreMemCtrl\2.2.106\rtl\vlog\core\corememctrl.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\work\CoreMemCtrl_C0\CoreMemCtrl_C0.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\hdl\Ram_interface.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\Actel\SgCore\TAMPER\2.1.300\tamper_comps.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\work\TAMPER_C0\TAMPER_C0_0\TAMPER_C0_TAMPER_C0_0_TAMPER.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\work\TAMPER_C0\TAMPER_C0.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\work\TPSRAM_C0\TPSRAM_C0_0\TPSRAM_C0_TPSRAM_C0_0_TPSRAM.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\work\TPSRAM_C0\TPSRAM_C0.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\work\Dev_Restart_after_IAP_blk\Dev_Restart_after_IAP_blk.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\hdl\hamming_decoder.sv}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\hdl\hamming_encoder.sv}
 add_include_path  {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\hdl}
 add_include_path  {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\hdl}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\hdl\hamming_top_design.sv}
 add_include_path  {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\hdl}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\hdl\fpga_top_design.sv}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\hdl\led_blink.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\Actel\DirectCore\CoreResetP\7.1.100\rtl\vlog\core\coreresetp_pcie_hotreset.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\Actel\DirectCore\CoreResetP\7.1.100\rtl\vlog\core\coreresetp.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\work\teste_sb\CCC_0\teste_sb_CCC_0_FCCC.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\work\teste_sb\FABOSC_0\teste_sb_FABOSC_0_OSC.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\work\teste_sb_MSS\teste_sb_MSS.v}
read_verilog -mode system_verilog -lib COREAHBLITE_LIB {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\Actel\DirectCore\CoreAHBLite\5.2.100\rtl\vlog\core\coreahblite_slavearbiter.v}
read_verilog -mode system_verilog -lib COREAHBLITE_LIB {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\Actel\DirectCore\CoreAHBLite\5.2.100\rtl\vlog\core\coreahblite_slavestage.v}
read_verilog -mode system_verilog -lib COREAHBLITE_LIB {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\Actel\DirectCore\CoreAHBLite\5.2.100\rtl\vlog\core\coreahblite_defaultslavesm.v}
read_verilog -mode system_verilog -lib COREAHBLITE_LIB {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\Actel\DirectCore\CoreAHBLite\5.2.100\rtl\vlog\core\coreahblite_addrdec.v}
read_verilog -mode system_verilog -lib COREAHBLITE_LIB {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\Actel\DirectCore\CoreAHBLite\5.2.100\rtl\vlog\core\coreahblite_masterstage.v}
read_verilog -mode system_verilog -lib COREAHBLITE_LIB {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\Actel\DirectCore\CoreAHBLite\5.2.100\rtl\vlog\core\coreahblite_matrix4x16.v}
read_verilog -mode system_verilog -lib COREAHBLITE_LIB {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\Actel\DirectCore\CoreAHBLite\5.2.100\rtl\vlog\core\coreahblite.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\work\teste_sb\teste_sb.v}
read_verilog -mode system_verilog {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\component\work\teste\teste.v}
set_top_level {teste}
map_netlist
check_constraints {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\constraint\synthesis_sdc_errors.log}
write_fdc {C:\Users\Lucas\Documents\Nascerr\design_depois_isp\designer\teste\synthesis.fdc}
