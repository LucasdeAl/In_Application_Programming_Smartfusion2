//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Fri May 30 17:52:43 2025
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
    MEMADDR,
    MMUART_0_TXD_M2F,
    SPI_0_DO,
    SRAMBYTEN,
    SRAMCSN,
    SRAMOEN,
    SRAMWEN,
    // Inouts
    MEMDATA,
    SPI_0_CLK,
    SPI_0_SS0
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input         DEVRST_N;
input         MMUART_0_RXD_F2M;
input         SPI_0_DI;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output [10:0] MEMADDR;
output        MMUART_0_TXD_M2F;
output        SPI_0_DO;
output [1:0]  SRAMBYTEN;
output [0:0]  SRAMCSN;
output        SRAMOEN;
output        SRAMWEN;
//--------------------------------------------------------------------
// Inout
//--------------------------------------------------------------------
inout  [15:0] MEMDATA;
inout         SPI_0_CLK;
inout         SPI_0_SS0;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire           DEVRST_N;
wire   [10:0]  MEMADDR_net_0;
wire   [15:0]  MEMDATA;
wire           MMUART_0_RXD_F2M;
wire           MMUART_0_TXD_M2F_net_0;
wire           SPI_0_CLK;
wire           SPI_0_DI;
wire           SPI_0_DO_net_0;
wire           SPI_0_SS0;
wire   [1:0]   SRAMBYTEN_net_0;
wire   [0:0]   SRAMCSN_net_0;
wire           SRAMOEN_net_0;
wire           SRAMWEN_net_0;
wire   [2:0]   teste_sb_0_AMBA_SLAVE_0_HBURST;
wire           teste_sb_0_AMBA_SLAVE_0_HMASTLOCK;
wire   [3:0]   teste_sb_0_AMBA_SLAVE_0_HPROT;
wire   [31:0]  teste_sb_0_AMBA_SLAVE_0_HRDATA;
wire           teste_sb_0_AMBA_SLAVE_0_HREADY;
wire           teste_sb_0_AMBA_SLAVE_0_HREADYOUT;
wire   [1:0]   teste_sb_0_AMBA_SLAVE_0_HRESP;
wire           teste_sb_0_AMBA_SLAVE_0_HSELx;
wire   [2:0]   teste_sb_0_AMBA_SLAVE_0_HSIZE;
wire   [1:0]   teste_sb_0_AMBA_SLAVE_0_HTRANS;
wire   [31:0]  teste_sb_0_AMBA_SLAVE_0_HWDATA;
wire           teste_sb_0_AMBA_SLAVE_0_HWRITE;
wire           teste_sb_0_FIC_0_CLK;
wire           teste_sb_0_POWER_ON_RESET_N;
wire           SPI_0_DO_net_1;
wire           MMUART_0_TXD_M2F_net_1;
wire           SRAMWEN_net_1;
wire           SRAMOEN_net_1;
wire   [0:0]   SRAMCSN_net_1;
wire   [1:0]   SRAMBYTEN_net_1;
wire   [10:0]  MEMADDR_net_1;
wire   [27:11] MEMADDR_slice_0;
wire   [27:0]  MEMADDR_net_2;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire           VCC_net;
//--------------------------------------------------------------------
// Bus Interface Nets Declarations - Unequal Pin Widths
//--------------------------------------------------------------------
wire   [31:0]  teste_sb_0_AMBA_SLAVE_0_HADDR;
wire   [27:0]  teste_sb_0_AMBA_SLAVE_0_HADDR_0;
wire   [27:0]  teste_sb_0_AMBA_SLAVE_0_HADDR_0_27to0;
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
assign SRAMWEN_net_1          = SRAMWEN_net_0;
assign SRAMWEN                = SRAMWEN_net_1;
assign SRAMOEN_net_1          = SRAMOEN_net_0;
assign SRAMOEN                = SRAMOEN_net_1;
assign SRAMCSN_net_1[0]       = SRAMCSN_net_0[0];
assign SRAMCSN[0:0]           = SRAMCSN_net_1[0];
assign SRAMBYTEN_net_1        = SRAMBYTEN_net_0;
assign SRAMBYTEN[1:0]         = SRAMBYTEN_net_1;
assign MEMADDR_net_1          = MEMADDR_net_0;
assign MEMADDR[10:0]          = MEMADDR_net_1;
//--------------------------------------------------------------------
// Slices assignments
//--------------------------------------------------------------------
assign MEMADDR_net_0   = MEMADDR_net_2[10:0];
assign MEMADDR_slice_0 = MEMADDR_net_2[27:11];
//--------------------------------------------------------------------
// Bus Interface Nets Assignments - Unequal Pin Widths
//--------------------------------------------------------------------
assign teste_sb_0_AMBA_SLAVE_0_HADDR_0 = { teste_sb_0_AMBA_SLAVE_0_HADDR_0_27to0 };
assign teste_sb_0_AMBA_SLAVE_0_HADDR_0_27to0 = teste_sb_0_AMBA_SLAVE_0_HADDR[27:0];

//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------CoreMemCtrl_C0
CoreMemCtrl_C0 CoreMemCtrl_C0_0(
        // Inputs
        .HCLK      ( teste_sb_0_FIC_0_CLK ),
        .HRESETN   ( teste_sb_0_POWER_ON_RESET_N ),
        .REMAP     ( VCC_net ),
        .HADDR     ( teste_sb_0_AMBA_SLAVE_0_HADDR_0 ),
        .HTRANS    ( teste_sb_0_AMBA_SLAVE_0_HTRANS ),
        .HWRITE    ( teste_sb_0_AMBA_SLAVE_0_HWRITE ),
        .HSIZE     ( teste_sb_0_AMBA_SLAVE_0_HSIZE ),
        .HWDATA    ( teste_sb_0_AMBA_SLAVE_0_HWDATA ),
        .HREADYIN  ( teste_sb_0_AMBA_SLAVE_0_HREADY ),
        .HSEL      ( teste_sb_0_AMBA_SLAVE_0_HSELx ),
        // Outputs
        .HRDATA    ( teste_sb_0_AMBA_SLAVE_0_HRDATA ),
        .HREADY    ( teste_sb_0_AMBA_SLAVE_0_HREADYOUT ),
        .HRESP     ( teste_sb_0_AMBA_SLAVE_0_HRESP ),
        .FLASHCSN  (  ),
        .FLASHOEN  (  ),
        .FLASHWEN  (  ),
        .SRAMCSN   ( SRAMCSN_net_0 ),
        .SRAMOEN   ( SRAMOEN_net_0 ),
        .SRAMWEN   ( SRAMWEN_net_0 ),
        .SRAMBYTEN ( SRAMBYTEN_net_0 ),
        .MEMADDR   ( MEMADDR_net_2 ),
        // Inouts
        .MEMDATA   ( MEMDATA ) 
        );

//--------Dev_Restart_after_IAP_blk
Dev_Restart_after_IAP_blk Dev_Restart_after_IAP_blk_0(
        // Inputs
        .CLK    ( teste_sb_0_FIC_0_CLK ),
        .RESETn ( teste_sb_0_POWER_ON_RESET_N ) 
        );

//--------teste_sb
teste_sb teste_sb_0(
        // Inputs
        .SPI_0_DI                  ( SPI_0_DI ),
        .FAB_RESET_N               ( VCC_net ), // tied to 1'b1 from definition
        .AMBA_SLAVE_0_HRDATA_S0    ( teste_sb_0_AMBA_SLAVE_0_HRDATA ),
        .AMBA_SLAVE_0_HREADYOUT_S0 ( teste_sb_0_AMBA_SLAVE_0_HREADYOUT ),
        .AMBA_SLAVE_0_HRESP_S0     ( teste_sb_0_AMBA_SLAVE_0_HRESP ),
        .DEVRST_N                  ( DEVRST_N ),
        .MMUART_0_RXD_F2M          ( MMUART_0_RXD_F2M ),
        // Outputs
        .SPI_0_DO                  ( SPI_0_DO_net_0 ),
        .POWER_ON_RESET_N          ( teste_sb_0_POWER_ON_RESET_N ),
        .INIT_DONE                 (  ),
        .AMBA_SLAVE_0_HADDR_S0     ( teste_sb_0_AMBA_SLAVE_0_HADDR ),
        .AMBA_SLAVE_0_HTRANS_S0    ( teste_sb_0_AMBA_SLAVE_0_HTRANS ),
        .AMBA_SLAVE_0_HWRITE_S0    ( teste_sb_0_AMBA_SLAVE_0_HWRITE ),
        .AMBA_SLAVE_0_HSIZE_S0     ( teste_sb_0_AMBA_SLAVE_0_HSIZE ),
        .AMBA_SLAVE_0_HWDATA_S0    ( teste_sb_0_AMBA_SLAVE_0_HWDATA ),
        .AMBA_SLAVE_0_HSEL_S0      ( teste_sb_0_AMBA_SLAVE_0_HSELx ),
        .AMBA_SLAVE_0_HREADY_S0    ( teste_sb_0_AMBA_SLAVE_0_HREADY ),
        .AMBA_SLAVE_0_HMASTLOCK_S0 ( teste_sb_0_AMBA_SLAVE_0_HMASTLOCK ),
        .AMBA_SLAVE_0_HBURST_S0    ( teste_sb_0_AMBA_SLAVE_0_HBURST ),
        .AMBA_SLAVE_0_HPROT_S0     ( teste_sb_0_AMBA_SLAVE_0_HPROT ),
        .FIC_0_CLK                 ( teste_sb_0_FIC_0_CLK ),
        .FIC_0_LOCK                (  ),
        .MSS_READY                 (  ),
        .MMUART_0_TXD_M2F          ( MMUART_0_TXD_M2F_net_0 ),
        // Inouts
        .SPI_0_CLK                 ( SPI_0_CLK ),
        .SPI_0_SS0                 ( SPI_0_SS0 ) 
        );


endmodule
