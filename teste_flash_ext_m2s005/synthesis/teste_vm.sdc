# Written by Synplify Pro version map202309act, Build 044R. Synopsys Run ID: sid1744641616 
# Top Level Design Parameters 

# Clocks 
create_clock -period 10.000 -waveform {0.000 5.000} -name {teste_sb_CCC_0_FCCC|GL0_net_inferred_clock} [get_pins {teste_sb_0/CCC_0/CCC_INST/GL0}] 

# Virtual Clocks 

# Generated Clocks 

# Paths Between Clocks 

# Multicycle Constraints 

# Point-to-point Delay Constraints 

# False Path Constraints 

# Output Load Constraints 

# Driving Cell Constraints 

# Input Delay Constraints 

# Output Delay Constraints 

# Wire Loads 

# Other Constraints 

# syn_hier Attributes 

# set_case Attributes 

# Clock Delay Constraints 
set Inferred_clkgroup_0 [list teste_sb_CCC_0_FCCC|GL0_net_inferred_clock]
set_clock_groups -asynchronous -group $Inferred_clkgroup_0

set_clock_groups -asynchronous -group [get_clocks {teste_sb_CCC_0_FCCC|GL0_net_inferred_clock}]
set_clock_groups -asynchronous -group [get_clocks {teste_sb_FABOSC_0_OSC|RCOSC_25_50MHZ_CCC_inferred_clock}]

# syn_mode Attributes 

# Cells 

# Port DRC Rules 

# Input Transition Constraints 

# Unused constraints (intentionally commented out) 


# Non-forward-annotatable constraints (intentionally commented out) 

# Block Path constraints 

