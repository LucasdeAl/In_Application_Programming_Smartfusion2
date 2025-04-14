set_component teste_sb_MSS
# Microchip Technology Inc.
# Date: 2025-Apr-10 12:55:43
#

create_clock -period 80 [ get_pins { MSS_ADLIB_INST/CLK_CONFIG_APB } ]
set_false_path -ignore_errors -through [ get_pins { MSS_ADLIB_INST/CONFIG_PRESET_N } ]
