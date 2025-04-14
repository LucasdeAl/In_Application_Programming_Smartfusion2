//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Mon Apr 14 11:40:03 2025
// Version: 2024.1 2024.1.0.3
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// teste
module teste(
    // Inputs
    DEVRST_N,
    MMUART_0_RXD_F2M,
    SPI_0_DI,
    // Outputs
    MMUART_0_TXD_M2F,
    SPI_0_DO,
    // Inouts
    SPI_0_CLK,
    SPI_0_SS0
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  DEVRST_N;
input  MMUART_0_RXD_F2M;
input  SPI_0_DI;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output MMUART_0_TXD_M2F;
output SPI_0_DO;
//--------------------------------------------------------------------
// Inout
//--------------------------------------------------------------------
inout  SPI_0_CLK;
inout  SPI_0_SS0;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   DEVRST_N;
wire   MMUART_0_RXD_F2M;
wire   MMUART_0_TXD_M2F_net_0;
wire   SPI_0_CLK;
wire   SPI_0_DI;
wire   SPI_0_DO_net_0;
wire   SPI_0_SS0;
wire   teste_sb_0_FAB_CCC_GL0;
wire   teste_sb_0_POWER_ON_RESET_N;
wire   SPI_0_DO_net_1;
wire   MMUART_0_TXD_M2F_net_1;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire   VCC_net;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign VCC_net = 1'b1;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign SPI_0_DO_net_1         = SPI_0_DO_net_0;
assign SPI_0_DO               = SPI_0_DO_net_1;
assign MMUART_0_TXD_M2F_net_1 = MMUART_0_TXD_M2F_net_0;
assign MMUART_0_TXD_M2F       = MMUART_0_TXD_M2F_net_1;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------Dev_Restart_after_IAP_blk
Dev_Restart_after_IAP_blk Dev_Restart_after_IAP_blk_0(
        // Inputs
        .CLK    ( teste_sb_0_FAB_CCC_GL0 ),
        .RESETn ( teste_sb_0_POWER_ON_RESET_N ) 
        );

//--------teste_sb
teste_sb teste_sb_0(
        // Inputs
        .SPI_0_DI         ( SPI_0_DI ),
        .FAB_RESET_N      ( VCC_net ), // tied to 1'b1 from definition
        .DEVRST_N         ( DEVRST_N ),
        .MMUART_0_RXD_F2M ( MMUART_0_RXD_F2M ),
        // Outputs
        .SPI_0_DO         ( SPI_0_DO_net_0 ),
        .POWER_ON_RESET_N ( teste_sb_0_POWER_ON_RESET_N ),
        .INIT_DONE        (  ),
        .FAB_CCC_GL0      ( teste_sb_0_FAB_CCC_GL0 ),
        .FAB_CCC_LOCK     (  ),
        .MSS_READY        (  ),
        .MMUART_0_TXD_M2F ( MMUART_0_TXD_M2F_net_0 ),
        // Inouts
        .SPI_0_CLK        ( SPI_0_CLK ),
        .SPI_0_SS0        ( SPI_0_SS0 ) 
        );


endmodule
