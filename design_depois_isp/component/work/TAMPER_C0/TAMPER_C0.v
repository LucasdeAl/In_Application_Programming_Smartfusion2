//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Mon Apr 14 11:33:03 2025
// Version: 2024.1 2024.1.0.3
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////
// Component Description (Tcl) 
//////////////////////////////////////////////////////////////////////
/*
# Exporting Component Description of TAMPER_C0 to TCL
# Family: SmartFusion2
# Part Number: M2S005-TQ144
# Create and Configure the core component TAMPER_C0
create_and_configure_core -core_vlnv {Actel:SgCore:TAMPER:2.1.300} -component_name {TAMPER_C0} -params {\
"CLK_ERROR_USED:false"  \
"DIGEST_ENVM0_USED:false"  \
"DIGEST_ENVM1_USED:false"  \
"DIGEST_FABRIC_USED:false"  \
"DISABLE_ALL_IOS_USED:false"  \
"LOCKDOWN_ALL_USED:false"  \
"POR_DIGEST_USED:false"  \
"RESET_USED:true"  \
"ZEROIZE_CONFIG:LIKE_NEW"  \
"ZEROIZE_USED:false"   }
# Exporting Component Description of TAMPER_C0 to TCL done
*/

// TAMPER_C0
module TAMPER_C0(
    // Inputs
    RESET_N,
    // Outputs
    DETECT_ATTEMPT,
    DETECT_CATEGORY,
    DETECT_FAIL,
    DIGEST_ERROR,
    JTAG_ACTIVE,
    LOCK_TAMPER_DETECT,
    MESH_SHORT_ERROR,
    SC_ROM_DIGEST_ERROR,
    TAMPER_CHANGE_STROBE
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input        RESET_N;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output       DETECT_ATTEMPT;
output [3:0] DETECT_CATEGORY;
output       DETECT_FAIL;
output       DIGEST_ERROR;
output       JTAG_ACTIVE;
output       LOCK_TAMPER_DETECT;
output       MESH_SHORT_ERROR;
output       SC_ROM_DIGEST_ERROR;
output       TAMPER_CHANGE_STROBE;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire         DETECT_ATTEMPT_net_0;
wire   [3:0] DETECT_CATEGORY_net_0;
wire         DETECT_FAIL_net_0;
wire         DIGEST_ERROR_net_0;
wire         JTAG_ACTIVE_net_0;
wire         LOCK_TAMPER_DETECT_net_0;
wire         MESH_SHORT_ERROR_net_0;
wire         RESET_N;
wire         SC_ROM_DIGEST_ERROR_net_0;
wire         TAMPER_CHANGE_STROBE_net_0;
wire         JTAG_ACTIVE_net_1;
wire         LOCK_TAMPER_DETECT_net_1;
wire         MESH_SHORT_ERROR_net_1;
wire   [3:0] DETECT_CATEGORY_net_1;
wire         DETECT_ATTEMPT_net_1;
wire         DETECT_FAIL_net_1;
wire         DIGEST_ERROR_net_1;
wire         SC_ROM_DIGEST_ERROR_net_1;
wire         TAMPER_CHANGE_STROBE_net_1;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire         GND_net;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign GND_net = 1'b0;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign JTAG_ACTIVE_net_1          = JTAG_ACTIVE_net_0;
assign JTAG_ACTIVE                = JTAG_ACTIVE_net_1;
assign LOCK_TAMPER_DETECT_net_1   = LOCK_TAMPER_DETECT_net_0;
assign LOCK_TAMPER_DETECT         = LOCK_TAMPER_DETECT_net_1;
assign MESH_SHORT_ERROR_net_1     = MESH_SHORT_ERROR_net_0;
assign MESH_SHORT_ERROR           = MESH_SHORT_ERROR_net_1;
assign DETECT_CATEGORY_net_1      = DETECT_CATEGORY_net_0;
assign DETECT_CATEGORY[3:0]       = DETECT_CATEGORY_net_1;
assign DETECT_ATTEMPT_net_1       = DETECT_ATTEMPT_net_0;
assign DETECT_ATTEMPT             = DETECT_ATTEMPT_net_1;
assign DETECT_FAIL_net_1          = DETECT_FAIL_net_0;
assign DETECT_FAIL                = DETECT_FAIL_net_1;
assign DIGEST_ERROR_net_1         = DIGEST_ERROR_net_0;
assign DIGEST_ERROR               = DIGEST_ERROR_net_1;
assign SC_ROM_DIGEST_ERROR_net_1  = SC_ROM_DIGEST_ERROR_net_0;
assign SC_ROM_DIGEST_ERROR        = SC_ROM_DIGEST_ERROR_net_1;
assign TAMPER_CHANGE_STROBE_net_1 = TAMPER_CHANGE_STROBE_net_0;
assign TAMPER_CHANGE_STROBE       = TAMPER_CHANGE_STROBE_net_1;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------TAMPER_C0_TAMPER_C0_0_TAMPER   -   Actel:SgCore:TAMPER:2.1.300
TAMPER_C0_TAMPER_C0_0_TAMPER TAMPER_C0_0(
        // Inputs
        .RESET_N              ( RESET_N ),
        // Outputs
        .JTAG_ACTIVE          ( JTAG_ACTIVE_net_0 ),
        .LOCK_TAMPER_DETECT   ( LOCK_TAMPER_DETECT_net_0 ),
        .MESH_SHORT_ERROR     ( MESH_SHORT_ERROR_net_0 ),
        .DETECT_CATEGORY      ( DETECT_CATEGORY_net_0 ),
        .DETECT_ATTEMPT       ( DETECT_ATTEMPT_net_0 ),
        .DETECT_FAIL          ( DETECT_FAIL_net_0 ),
        .DIGEST_ERROR         ( DIGEST_ERROR_net_0 ),
        .SC_ROM_DIGEST_ERROR  ( SC_ROM_DIGEST_ERROR_net_0 ),
        .TAMPER_CHANGE_STROBE ( TAMPER_CHANGE_STROBE_net_0 ) 
        );


endmodule
