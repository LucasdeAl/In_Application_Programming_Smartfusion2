//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Fri May 30 17:44:48 2025
// Version: 2024.1 2024.1.0.3
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////
// Component Description (Tcl) 
//////////////////////////////////////////////////////////////////////
/*
# Exporting Component Description of CoreMemCtrl_C0 to TCL
# Family: SmartFusion2
# Part Number: M2S005-TQ144
# Create and Configure the core component CoreMemCtrl_C0
create_and_configure_core -core_vlnv {Actel:DirectCore:CoreMemCtrl:2.2.106} -component_name {CoreMemCtrl_C0} -params {\
"DQ_SIZE_GEN:16"  \
"DQ_SIZE_SRAM_GEN:16"  \
"ENABLE_FLASH_IF:true"  \
"ENABLE_SRAM_IF:true"  \
"FLASH_DQ_SIZE:8"  \
"FLASH_TYPE:0"  \
"FLOW_THROUGH:0"  \
"MEM_0_BASEADDR:08000000"  \
"MEM_0_BASEADDR_GEN:134217728"  \
"MEM_0_DQ_SIZE:16"  \
"MEM_0_ENDADDR:09FFFFFF"  \
"MEM_0_ENDADDR_GEN:167772159"  \
"MEM_1_BASEADDR:0A000000"  \
"MEM_1_BASEADDR_GEN:167772160"  \
"MEM_1_DQ_SIZE:8"  \
"MEM_1_ENDADDR:0BFFFFFF"  \
"MEM_1_ENDADDR_GEN:201326591"  \
"MEM_2_BASEADDR:0C000000"  \
"MEM_2_BASEADDR_GEN:201326592"  \
"MEM_2_DQ_SIZE:8"  \
"MEM_2_ENDADDR:0DFFFFFF"  \
"MEM_2_ENDADDR_GEN:234881023"  \
"MEM_3_BASEADDR:0E000000"  \
"MEM_3_BASEADDR_GEN:234881024"  \
"MEM_3_DQ_SIZE:8"  \
"MEM_3_ENDADDR:0FFFFFFF"  \
"MEM_3_ENDADDR_GEN:268435455"  \
"MEMORY_ADDRESS_CONFIG_MODE:0"  \
"NUM_MEMORY_CHIP:1"  \
"NUM_WS_FLASH_READ:1"  \
"NUM_WS_FLASH_WRITE:1"  \
"NUM_WS_SRAM_READ_CH0:1"  \
"NUM_WS_SRAM_READ_CH1:1"  \
"NUM_WS_SRAM_READ_CH2:1"  \
"NUM_WS_SRAM_READ_CH3:1"  \
"NUM_WS_SRAM_WRITE_CH0:1"  \
"NUM_WS_SRAM_WRITE_CH1:1"  \
"NUM_WS_SRAM_WRITE_CH2:1"  \
"NUM_WS_SRAM_WRITE_CH3:1"  \
"SHARED_RW:0"  \
"SYNC_SRAM:0"   }
# Exporting Component Description of CoreMemCtrl_C0 to TCL done
*/

// CoreMemCtrl_C0
module CoreMemCtrl_C0(
    // Inputs
    HADDR,
    HCLK,
    HREADYIN,
    HRESETN,
    HSEL,
    HSIZE,
    HTRANS,
    HWDATA,
    HWRITE,
    REMAP,
    // Outputs
    FLASHCSN,
    FLASHOEN,
    FLASHWEN,
    HRDATA,
    HREADY,
    HRESP,
    MEMADDR,
    SRAMBYTEN,
    SRAMCSN,
    SRAMOEN,
    SRAMWEN,
    // Inouts
    MEMDATA
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  [27:0] HADDR;
input         HCLK;
input         HREADYIN;
input         HRESETN;
input         HSEL;
input  [2:0]  HSIZE;
input  [1:0]  HTRANS;
input  [31:0] HWDATA;
input         HWRITE;
input         REMAP;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output        FLASHCSN;
output        FLASHOEN;
output        FLASHWEN;
output [31:0] HRDATA;
output        HREADY;
output [1:0]  HRESP;
output [27:0] MEMADDR;
output [1:0]  SRAMBYTEN;
output [0:0]  SRAMCSN;
output        SRAMOEN;
output        SRAMWEN;
//--------------------------------------------------------------------
// Inout
//--------------------------------------------------------------------
inout  [15:0] MEMDATA;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   [27:0] HADDR;
wire   [31:0] AHBslave_HRDATA;
wire          HREADYIN;
wire          AHBslave_HREADYOUT;
wire   [1:0]  AHBslave_HRESP;
wire          HSEL;
wire   [2:0]  HSIZE;
wire   [1:0]  HTRANS;
wire   [31:0] HWDATA;
wire          HWRITE;
wire          FLASHCSN_net_0;
wire          FLASHOEN_net_0;
wire          FLASHWEN_net_0;
wire          HCLK;
wire          HRESETN;
wire   [27:0] MEMADDR_net_0;
wire   [15:0] MEMDATA;
wire          REMAP;
wire   [1:0]  SRAMBYTEN_net_0;
wire   [0:0]  SRAMCSN_net_0;
wire          SRAMOEN_net_0;
wire          SRAMWEN_net_0;
wire   [31:0] AHBslave_HRDATA_net_0;
wire          AHBslave_HREADYOUT_net_0;
wire   [1:0]  AHBslave_HRESP_net_0;
wire          FLASHCSN_net_1;
wire          FLASHOEN_net_1;
wire          FLASHWEN_net_1;
wire   [0:0]  SRAMCSN_net_1;
wire          SRAMOEN_net_1;
wire          SRAMWEN_net_1;
wire   [1:0]  SRAMBYTEN_net_1;
wire   [27:0] MEMADDR_net_1;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign AHBslave_HRDATA_net_0    = AHBslave_HRDATA;
assign HRDATA[31:0]             = AHBslave_HRDATA_net_0;
assign AHBslave_HREADYOUT_net_0 = AHBslave_HREADYOUT;
assign HREADY                   = AHBslave_HREADYOUT_net_0;
assign AHBslave_HRESP_net_0     = AHBslave_HRESP;
assign HRESP[1:0]               = AHBslave_HRESP_net_0;
assign FLASHCSN_net_1           = FLASHCSN_net_0;
assign FLASHCSN                 = FLASHCSN_net_1;
assign FLASHOEN_net_1           = FLASHOEN_net_0;
assign FLASHOEN                 = FLASHOEN_net_1;
assign FLASHWEN_net_1           = FLASHWEN_net_0;
assign FLASHWEN                 = FLASHWEN_net_1;
assign SRAMCSN_net_1[0]         = SRAMCSN_net_0[0];
assign SRAMCSN[0:0]             = SRAMCSN_net_1[0];
assign SRAMOEN_net_1            = SRAMOEN_net_0;
assign SRAMOEN                  = SRAMOEN_net_1;
assign SRAMWEN_net_1            = SRAMWEN_net_0;
assign SRAMWEN                  = SRAMWEN_net_1;
assign SRAMBYTEN_net_1          = SRAMBYTEN_net_0;
assign SRAMBYTEN[1:0]           = SRAMBYTEN_net_1;
assign MEMADDR_net_1            = MEMADDR_net_0;
assign MEMADDR[27:0]            = MEMADDR_net_1;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------CoreMemCtrl   -   Actel:DirectCore:CoreMemCtrl:2.2.106
CoreMemCtrl #( 
        .ENABLE_FLASH_IF            ( 1 ),
        .ENABLE_SRAM_IF             ( 1 ),
        .FAMILY                     ( 19 ),
        .FLASH_DQ_SIZE              ( 8 ),
        .FLASH_TYPE                 ( 0 ),
        .FLOW_THROUGH               ( 0 ),
        .MEM_0_BASEADDR_GEN         ( 134217728 ),
        .MEM_0_DQ_SIZE              ( 16 ),
        .MEM_0_ENDADDR_GEN          ( 167772159 ),
        .MEM_1_BASEADDR_GEN         ( 167772160 ),
        .MEM_1_DQ_SIZE              ( 8 ),
        .MEM_1_ENDADDR_GEN          ( 201326591 ),
        .MEM_2_BASEADDR_GEN         ( 201326592 ),
        .MEM_2_DQ_SIZE              ( 8 ),
        .MEM_2_ENDADDR_GEN          ( 234881023 ),
        .MEM_3_BASEADDR_GEN         ( 234881024 ),
        .MEM_3_DQ_SIZE              ( 8 ),
        .MEM_3_ENDADDR_GEN          ( 268435455 ),
        .MEMORY_ADDRESS_CONFIG_MODE ( 0 ),
        .NUM_MEMORY_CHIP            ( 1 ),
        .NUM_WS_FLASH_READ          ( 1 ),
        .NUM_WS_FLASH_WRITE         ( 1 ),
        .NUM_WS_SRAM_READ_CH0       ( 1 ),
        .NUM_WS_SRAM_READ_CH1       ( 1 ),
        .NUM_WS_SRAM_READ_CH2       ( 1 ),
        .NUM_WS_SRAM_READ_CH3       ( 1 ),
        .NUM_WS_SRAM_WRITE_CH0      ( 1 ),
        .NUM_WS_SRAM_WRITE_CH1      ( 1 ),
        .NUM_WS_SRAM_WRITE_CH2      ( 1 ),
        .NUM_WS_SRAM_WRITE_CH3      ( 1 ),
        .SHARED_RW                  ( 0 ),
        .SYNC_SRAM                  ( 0 ) )
CoreMemCtrl_C0_0(
        // Inputs
        .HCLK      ( HCLK ),
        .HRESETN   ( HRESETN ),
        .HSEL      ( HSEL ),
        .HWRITE    ( HWRITE ),
        .HREADYIN  ( HREADYIN ),
        .HTRANS    ( HTRANS ),
        .HSIZE     ( HSIZE ),
        .HWDATA    ( HWDATA ),
        .HADDR     ( HADDR ),
        .REMAP     ( REMAP ),
        // Outputs
        .HREADY    ( AHBslave_HREADYOUT ),
        .HRESP     ( AHBslave_HRESP ),
        .HRDATA    ( AHBslave_HRDATA ),
        .FLASHCSN  ( FLASHCSN_net_0 ),
        .FLASHOEN  ( FLASHOEN_net_0 ),
        .FLASHWEN  ( FLASHWEN_net_0 ),
        .SRAMCLK   (  ),
        .SRAMCSN   ( SRAMCSN_net_0 ),
        .SRAMOEN   ( SRAMOEN_net_0 ),
        .SRAMWEN   ( SRAMWEN_net_0 ),
        .SRAMBYTEN ( SRAMBYTEN_net_0 ),
        .MEMREADN  (  ),
        .MEMWRITEN (  ),
        .MEMADDR   ( MEMADDR_net_0 ),
        // Inouts
        .MEMDATA   ( MEMDATA ) 
        );


endmodule
