//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Mon Apr 14 11:39:58 2025
// Version: 2024.1 2024.1.0.3
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// Dev_Restart_after_IAP_blk
module Dev_Restart_after_IAP_blk(
    // Inputs
    CLK,
    RESETn
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  CLK;
input  RESETn;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire         CLK;
wire         Ram_intferface_0_o_reset_n;
wire   [5:0] Ram_intferface_0_o_TPSRAM_RADDR_sv;
wire         Ram_intferface_0_o_TPSRAM_REN;
wire   [5:0] Ram_intferface_0_o_TPSRAM_WADDR_sv;
wire   [7:0] Ram_intferface_0_o_TPSRAM_WD;
wire         Ram_intferface_0_o_TPSRAM_WEN;
wire         RESETn;
wire   [7:0] TPSRAM_C0_0_RD;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------Ram_intferface
Ram_intferface Ram_intferface_0(
        // Inputs
        .CLK               ( CLK ),
        .RESETn            ( RESETn ),
        .i_TPSRAM_RD_sv    ( TPSRAM_C0_0_RD ),
        // Outputs
        .o_reset_n         ( Ram_intferface_0_o_reset_n ),
        .o_TPSRAM_WADDR_sv ( Ram_intferface_0_o_TPSRAM_WADDR_sv ),
        .o_TPSRAM_RADDR_sv ( Ram_intferface_0_o_TPSRAM_RADDR_sv ),
        .o_TPSRAM_WD       ( Ram_intferface_0_o_TPSRAM_WD ),
        .o_TPSRAM_WEN      ( Ram_intferface_0_o_TPSRAM_WEN ),
        .o_TPSRAM_REN      ( Ram_intferface_0_o_TPSRAM_REN ) 
        );

//--------TAMPER_C0
TAMPER_C0 TAMPER_C0_0(
        // Inputs
        .RESET_N              ( Ram_intferface_0_o_reset_n ),
        // Outputs
        .JTAG_ACTIVE          (  ),
        .LOCK_TAMPER_DETECT   (  ),
        .MESH_SHORT_ERROR     (  ),
        .DETECT_CATEGORY      (  ),
        .DETECT_ATTEMPT       (  ),
        .DETECT_FAIL          (  ),
        .DIGEST_ERROR         (  ),
        .SC_ROM_DIGEST_ERROR  (  ),
        .TAMPER_CHANGE_STROBE (  ) 
        );

//--------TPSRAM_C0
TPSRAM_C0 TPSRAM_C0_0(
        // Inputs
        .WD    ( Ram_intferface_0_o_TPSRAM_WD ),
        .WADDR ( Ram_intferface_0_o_TPSRAM_WADDR_sv ),
        .RADDR ( Ram_intferface_0_o_TPSRAM_RADDR_sv ),
        .WEN   ( Ram_intferface_0_o_TPSRAM_WEN ),
        .REN   ( Ram_intferface_0_o_TPSRAM_REN ),
        .CLK   ( CLK ),
        // Outputs
        .RD    ( TPSRAM_C0_0_RD ) 
        );


endmodule
