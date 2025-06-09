// ********************************************************************/
// Actel Corporation Proprietary and Confidential
// Copyright 2009 Actel Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
//
// corememctrl.v
//
// Description :
//          Memory Controller
//          AHB slave which is designed to interface to Flash and
//          either asynchronous or synchronous SRAM.
//
// Revision Information:
// Date         Description
// ----         -----------------------------------------
//
//
// SVN Revision Information:
// SVN $Revision: 37897 $
// SVN $Date: 2021-03-26 00:50:06 +0530 (Fri, 26 Mar 2021) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
//
// Notes:
// 
//
// *********************************************************************/

`timescale 1ns/100ps

module CoreMemCtrl (
    HCLK,               // AHB Clock
    HRESETN,            // AHB Reset
    HSEL,               // AHB select
    HWRITE,             // AHB Write
    HREADYIN,           // AHB HREADY input
    HTRANS,             // AHB HTRANS
    HSIZE,              // AHB transfer size
    HWDATA,             // AHB write data bus
    HADDR,              // AHB address bus
    HREADY,             // AHB ready signal
    HRESP,              // AHB transfer response
    HRDATA,             // AHB read data bus
    REMAP,              // Remap control
    FLASHCSN,           // Flash chip select
    FLASHOEN,           // Flash output enable
    FLASHWEN,           // Flash write enable
    SRAMCLK,            // Clock signal for synchronous SRAM
    SRAMCSN,            // SRAM chip select
    SRAMOEN,            // SRAM output enable
    SRAMWEN,            // SRAM write enable
    SRAMBYTEN,          // SRAM byte enables
    MEMREADN,           // Combined Flash/SRAM read enable
    MEMWRITEN,          // Combined Flash/SRAM write enable
    MEMADDR,            // Flash/SRAM address bus
    MEMDATA             // Bidirectional data bus to/from memory
    );

    parameter FAMILY                 = 17;
    parameter MEMORY_ADDRESS_CONFIG_MODE     = 1;
    parameter ENABLE_FLASH_IF        = 1;
    parameter ENABLE_SRAM_IF         = 1;
    parameter SYNC_SRAM              = 1;
    parameter FLASH_TYPE             = 0;
    parameter NUM_MEMORY_CHIP        = 1;
    parameter MEM_0_DQ_SIZE          = 8;
    parameter MEM_1_DQ_SIZE          = 8;
    parameter MEM_2_DQ_SIZE          = 8;
    parameter MEM_3_DQ_SIZE          = 8;
    parameter FLASH_DQ_SIZE          = 8;
    parameter FLOW_THROUGH           = 0;
    parameter NUM_WS_FLASH_READ      = 1;
    parameter NUM_WS_FLASH_WRITE     = 1;
    parameter NUM_WS_SRAM_READ_CH0   = 1;
    parameter NUM_WS_SRAM_READ_CH1   = 1;
    parameter NUM_WS_SRAM_READ_CH2   = 1;
    parameter NUM_WS_SRAM_READ_CH3   = 1;
    parameter NUM_WS_SRAM_WRITE_CH0  = 1;
    parameter NUM_WS_SRAM_WRITE_CH1  = 1;
    parameter NUM_WS_SRAM_WRITE_CH2  = 1;
    parameter NUM_WS_SRAM_WRITE_CH3  = 1;
    parameter SHARED_RW              = 0;
    parameter MEM_0_BASEADDR_GEN     = 28'h8000000 ;
    parameter MEM_0_ENDADDR_GEN      = 28'h9FFFFFF ;
    parameter MEM_1_BASEADDR_GEN     = 28'hA000000 ;
    parameter MEM_1_ENDADDR_GEN      = 28'hBFFFFFF ;
    parameter MEM_2_BASEADDR_GEN     = 28'hC000000 ;
    parameter MEM_2_ENDADDR_GEN      = 28'hDFFFFFF ;
    parameter MEM_3_BASEADDR_GEN     = 28'hE000000 ;
    parameter MEM_3_ENDADDR_GEN      = 28'hFFFFFFF ;
    parameter SYNC_RESET             = (FAMILY == 25) ? 1 : 0;
    

    localparam  DQ_SIZE              = (MEM_0_DQ_SIZE ==32 || MEM_1_DQ_SIZE ==32 ||MEM_2_DQ_SIZE ==32 ||MEM_3_DQ_SIZE ==32 || FLASH_DQ_SIZE ==32) ? 32 : ((MEM_0_DQ_SIZE ==16 || MEM_1_DQ_SIZE ==16 ||MEM_2_DQ_SIZE ==16 ||MEM_3_DQ_SIZE ==16 || FLASH_DQ_SIZE ==16) ? 16 :8 ) ;
    localparam  DQ_SIZE_SRAM         = (MEM_0_DQ_SIZE ==32 || MEM_1_DQ_SIZE ==32 ||MEM_2_DQ_SIZE ==32 ||MEM_3_DQ_SIZE ==32) ? 32 : ((MEM_0_DQ_SIZE ==16 || MEM_1_DQ_SIZE ==16 ||MEM_2_DQ_SIZE ==16 ||MEM_3_DQ_SIZE ==16 ) ? 16 :8 ) ;

// ---------------------------------------------------------------------
// Port declarations
// ---------------------------------------------------------------------

    // AHB interface
    input                            HCLK;
    input                            HRESETN;
    input                            HSEL;
    input                            HWRITE;
    input                            HREADYIN;
    input   [1:0]                    HTRANS;
    input   [2:0]                    HSIZE;
    input   [31:0]                   HWDATA;
    input   [27:0]                   HADDR;
    output                           HREADY;
    output  [1:0]                    HRESP;
    output  [31:0]                   HRDATA;
    // Remap control
    input                            REMAP;
    // Memory interface
    output                           FLASHCSN;
    output                           FLASHOEN;
    output                           FLASHWEN;
    output                           SRAMCLK;
    output  [(NUM_MEMORY_CHIP-1):0]  SRAMCSN;
    output                           SRAMOEN;
    output                           SRAMWEN;
    output  [DQ_SIZE_SRAM/8 -1:0]    SRAMBYTEN;
    output                           MEMREADN;
    output                           MEMWRITEN;
    output  [27:0]                   MEMADDR;
    inout   [DQ_SIZE-1:0]            MEMDATA;



// ---------------------------------------------------------------------
// Constant declarations
// ---------------------------------------------------------------------
    
    localparam  MEM_0_BASEADDR_REMAP_DIS    = 28'h8000000 ;
    localparam  MEM_0_BASEADDR_REMAP_EN     = 28'h0000000 ;
    localparam  MEM_0_ENDADDR_REMAP_DIS     = 28'hFFFFFFF ;
    localparam  MEM_0_ENDADDR_REMAP_EN      = 28'h7FFFFFF ;

// ---------------------------------------------------------------------
// Constant declarations
// ---------------------------------------------------------------------

    // StateName constant definitions
    `define ST_IDLE      4'b0000
    `define ST_IDLE_1    4'b0001
    `define ST_FLASH_RD  4'b0010
    `define ST_FLASH_WR  4'b0011
    `define ST_ASRAM_RD  4'b0100
    `define ST_ASRAM_WR  4'b0101
    `define ST_WAIT      4'b0110
    `define ST_WAIT1     4'b0111
    `define ST_SSRAM_WR  4'b1000
    `define ST_SSRAM_RD1 4'b1001
    `define ST_SSRAM_RD2 4'b1010

    // Wait state counter values
    `define ZERO         5'b00000
    `define ONE          5'b00001
    `define MAX_WAIT     5'b11111

    // AHB HTRANS constant definitions
    `define TRN_IDLE     2'b00
    `define TRN_BUSY     2'b01
    `define TRN_NSEQ     2'b10
    `define TRN_SEQU     2'b11

    // AHB HRESP constant definitions
    `define RSP_OKAY     2'b00
    `define RSP_ERROR    2'b01
    `define RSP_RETRY    2'b10
    `define RSP_SPLIT    2'b11

    // AHB HREADY constant definitions
    `define H_WAIT       1'b0
    `define H_READY      1'b1

    // AHB HSIZE constant definitions
    `define SZ_BYTE      3'b000
    `define SZ_HALF      3'b001
    `define SZ_WORD      3'b010

    // SRAM byte enables encoding
    `define NONE         4'b1111
    `define WORD         4'b0000
    `define HALF1        4'b0011
    `define HALF0        4'b1100
    `define BYTE3        4'b0111
    `define BYTE2        4'b1011
    `define BYTE1        4'b1101
    `define BYTE0        4'b1110

// ---------------------------------------------------------------------
// Signal declarations
// ---------------------------------------------------------------------

    wire                           HCLK;
    wire                           HRESETN;
    wire                           HSEL;
    wire                           HWRITE;
    wire                           HREADYIN;
    wire    [1:0]                  HTRANS;
    wire    [2:0]                  HSIZE;
    wire    [31:0]                 HWDATA;
    wire    [27:0]                 HADDR;
    wire    [1:0]                  HRESP;
    wire                           HREADY;
    reg     [31:0]                 HRDATA;
    wire                           FLASHCSN;
    wire                           FLASHOEN;
    wire                           FLASHWEN;
    wire                           SRAMCLK;
    wire                           SRAMOEN;
    wire                           SRAMWEN;
    wire                           MEMREADN;
    wire                           MEMWRITEN;
    wire                           MEMDATAOEN;
    wire    [DQ_SIZE-1:0]          MEMDATA;
    wire    [DQ_SIZE-1:0]          MEMDATAIn;
    wire    [NUM_MEMORY_CHIP-1 :0] SRAMCSN;
    wire                           REMAP;
    reg     [DQ_SIZE_SRAM/8-1 :0]  SRAMBYTEN;
    reg     [31:0]                 MEMDATAOut;
    reg     [27:0]                 MEMADDR;
    reg                            SRAM_16BIT;
    reg                            SRAM_8BIT;
                                  
    reg      [3:0]                 MemCntlState;
    reg      [3:0]                 NextMemCntlState;
                                  
    reg      [4:0]                 NUM_WS_SRAM_WRITE;
    reg      [4:0]                 NUM_WS_SRAM_READ;
                                  
                                  
    reg      [4:0]                 CurrentWait;
    reg      [4:0]                 NextWait;
    reg      [4:0]                 WSCounterLoadVal;                                  
    reg                            LoadWSCounter;
    reg                            transaction_done;
    reg                            next_transaction_done;
                                  
    reg                            HselReg;
    reg                            HselFlashReg;
    reg                            HselSramReg;
                                  
    reg     [31:0]                 MEMDATAInReg;
    reg     [31:0]                 MEMDATA_rd_flash;
    reg     [31:0]                 iHRDATA;
    reg                            iHready;
    reg     [27:0]                 HaddrReg;
    reg     [1:0]                  HtransReg;
    reg                            HwriteReg;
    reg     [2:0]                  HsizeReg;
                                   
    reg                            SelHaddrReg; 
    reg                            NextSelHaddrReg;
    reg                            iMEMDATAOEN;  
    reg                            NextMEMDATAOEN;
    reg                            iFLASHCSN;  
    reg                            NextFLASHCSN;
    reg                            iFLASHWEN;      
    reg                            NextFLASHWEN;
    reg                            iFLASHOEN;   
    reg                            NextFLASHOEN;
    reg   [NUM_MEMORY_CHIP-1 : 0]  iSRAMCSN;
    reg                            NextSRAMCSN;
    wire                           iSRAMCSN_s;
    reg                            iSRAMWEN;     
    reg                            NextSRAMWEN;
    reg                            iSRAMOEN;    
    reg                            NextSRAMOEN;
    reg                            wr_follow_rd;
    reg                            wr_follow_rd_next;
    reg   [1:0]                    trans_split_count;
    reg                            trans_split_en;
    reg                            trans_split_reset;
    reg                            HoldHreadyLow;
                                   
    wire                           HselFlash;
    wire                           HselSram;
    wire                           iMEMREADN;
    wire                           iMEMWRITEN;
    wire                           HreadyNext;
    wire                           Valid;
    wire                           Busy;
    reg                            Valid_d;
    reg                            Busy_d;
    reg                            HselFlash_d;
    reg                            HWRITE_d;
    reg   [2:0]                    HSIZE_d;
    wire                           ValidReg;
    wire                           ACRegEn;
                                   
    reg                            CH0_EN_reg;
    reg                            CH1_EN_reg;
    reg                            CH2_EN_reg;
    reg                            CH3_EN_reg;
    
    reg                            pipeline_rd;
    reg                            pipeline_rd_d1;
    reg                            pipeline_rd_d2;
    reg   [1:0]                    ssram_split_trans;
    reg   [1:0]                    ssram_split_trans_next;
    reg                            ssram_split_trans_en;
    reg                            ssram_split_trans_load;
    reg                            ssram_read_buzy_next;
    reg                            ssram_read_buzy_next_d;
    reg                            ssram_read_buzy;
    // StateName is used for debug - intended to be displayed as ASCII in
    // waveform viewer.
    integer         StateName;

    wire aresetn;
    wire sresetn;
    
    assign aresetn = (SYNC_RESET == 1) ? 1'b1 : HRESETN;
    assign sresetn = (SYNC_RESET == 1) ? HRESETN : 1'b1;
    
//----------------------------------------------------------------------------------
// Main body of code
//----------------------------------------------------------------------------------

    // Bidirectional memory data bus
    assign MEMDATA      = (DQ_SIZE == 32) ? ((MEMDATAOEN == 1'b0) ? MEMDATAOut : 32'bz) : ((DQ_SIZE == 16) ? ((MEMDATAOEN == 1'b0) ? MEMDATAOut[15:0] : 16'bz) : ((MEMDATAOEN == 1'b0) ? MEMDATAOut[7:0] : 8'bz));
    assign MEMDATAIn    = MEMDATA;

    // Clock signal for synchronous SRAM is inverted HCLK
    assign SRAMCLK      = !HCLK;

    // Drive outputs to memories with internal signals
    assign MEMDATAOEN   = iMEMDATAOEN;
    assign FLASHCSN     = iFLASHCSN;
    assign FLASHWEN     = iFLASHWEN;
    assign FLASHOEN     = iFLASHOEN;
    assign SRAMCSN      = iSRAMCSN;
    assign SRAMWEN      = iSRAMWEN;
    assign SRAMOEN      = iSRAMOEN;
    assign MEMWRITEN    = iMEMWRITEN;
    assign MEMREADN     = iMEMREADN;

    // MEMWRITEN asserted if either flash or SRAM WEnN asserted
    assign iMEMWRITEN   = ( iFLASHWEN && iSRAMWEN );
    // MEMREADN  asserted if either flash or SRAM OEnN asserted
    assign iMEMREADN    = ( iFLASHOEN && iSRAMOEN );

    // When REMAP is not asserted, flash appears at 0x00000000 and SRAM at 0x08000000.
    // When REMAP is asserted,     flash appears at 0x08000000 and SRAM at 0x00000000.
    
    generate 
    if(MEMORY_ADDRESS_CONFIG_MODE ==1) begin
       assign HselFlash    = (ENABLE_FLASH_IF ==0 & ENABLE_SRAM_IF == 1 ) ? 1'b0 : ((ENABLE_FLASH_IF ==1 & ENABLE_SRAM_IF == 0 ) ? HSEL : (REMAP ? (HSEL &  HADDR[27]) : (HSEL & !HADDR[27])));
       assign HselSram     = (ENABLE_FLASH_IF ==0 & ENABLE_SRAM_IF == 1 ) ? HSEL : ((ENABLE_FLASH_IF ==1 & ENABLE_SRAM_IF == 0 ) ? 1'b0 : (REMAP ? (HSEL & !HADDR[27]) : (HSEL &  HADDR[27])));
    end 
    endgenerate

    generate 
    if(MEMORY_ADDRESS_CONFIG_MODE ==0) begin
       assign HselFlash    = REMAP ? (HSEL &  HADDR[27]) : (HSEL & !HADDR[27]);
       assign HselSram     = REMAP ? (HSEL & !HADDR[27]) : (HSEL &  HADDR[27]);
    end 
    endgenerate

    //------------------------------------------------------------------------------
    // Valid transfer detection
    //------------------------------------------------------------------------------
    // The slave must only respond to a valid transfer, so this must be detected.
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn)) begin
         HselReg      <= 1'b0;
         HselFlashReg <= 1'b0;
         HselSramReg  <= 1'b0;
      end else begin
         if (HREADYIN) begin
            HselReg      <= HSEL;
            HselFlashReg <= HselFlash;
            HselSramReg  <= HselSram;
         end
      end
   end

   // Valid AHB transfers only take place when a non-sequential or sequential
   // transfer is shown on HTRANS - an idle or busy transfer should be ignored.
   assign Valid = ((HSEL && HREADYIN) && ((HTRANS == `TRN_NSEQ) || (HTRANS == `TRN_SEQU))) ? 1'b1 : 1'b0;
   assign Busy = ((HSEL && HREADYIN && (HWRITE==1'b0)) && (HTRANS == `TRN_BUSY) ) ? 1'b1 : 1'b0;

   assign ValidReg = ((HselReg) && ((HtransReg == `TRN_NSEQ) || (HtransReg == `TRN_SEQU))) ? 1'b1 : 1'b0;

   //------------------------------------------------------------------------------
   // Address and control registers
   //------------------------------------------------------------------------------
   // Registers are used to store the address and control signals from the address
   // phase for use in the data phase of the transfer.
   // Only enabled when the HREADYIN input is HIGH and the module is addressed.
   assign ACRegEn = (HSEL && HREADYIN && HREADY);
    
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn)) begin
         HaddrReg  <= 28'b0;
         HtransReg <= 2'b00;
         HwriteReg <= 1'b0;
         HsizeReg  <= 3'b000;
      end else begin
         if (ACRegEn) begin
            HaddrReg  <= HADDR;
            HtransReg <= HTRANS;
            HwriteReg <= HWRITE;
            HsizeReg  <= HSIZE;
         end
      end
   end
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn)) begin
         Busy_d  <= 1'b0;
      end else begin
            Busy_d  <= Busy;
      end
   end

generate
   if (NUM_MEMORY_CHIP == 4) begin
      always @ ( * ) begin
         CH0_EN_reg = 1'b0 ;
         CH1_EN_reg = 1'b0 ;
         CH2_EN_reg = 1'b0 ;
         CH3_EN_reg = 1'b0 ;
         SRAM_16BIT = 1'b0;
         SRAM_8BIT  = 1'b0;
         NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH0;
         NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH0;
         if ( (HaddrReg >= MEM_0_BASEADDR_GEN) &  (HaddrReg <= MEM_0_ENDADDR_GEN) ) begin
            CH0_EN_reg =1'b1;
            NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH0;
            NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH0;
            if(MEM_0_DQ_SIZE == 32 ) begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b0;
            end else if (MEM_0_DQ_SIZE == 16 ) begin
               SRAM_16BIT = 1'b1;
               SRAM_8BIT  = 1'b0;
            end else begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b1;
            end 
         end else if ( (HaddrReg >= MEM_1_BASEADDR_GEN) &  (HaddrReg <= MEM_1_ENDADDR_GEN) ) begin
            CH1_EN_reg =1'b1;
            NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH1;
            NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH1;
            if(MEM_1_DQ_SIZE == 32 ) begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b0;
            end else if (MEM_1_DQ_SIZE == 16 ) begin
               SRAM_16BIT = 1'b1;
               SRAM_8BIT  = 1'b0;
            end else begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b1;
            end 
         end else if ( (HaddrReg >= MEM_2_BASEADDR_GEN) &  (HaddrReg <= MEM_2_ENDADDR_GEN) ) begin
            CH2_EN_reg =1'b1;
            NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH2;
            NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH2;
            if(MEM_2_DQ_SIZE == 32 ) begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b0;
            end else if (MEM_2_DQ_SIZE == 16 ) begin
               SRAM_16BIT = 1'b1;
               SRAM_8BIT  = 1'b0;
            end else begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b1;
            end 
         end else if ( (HaddrReg >= MEM_3_BASEADDR_GEN) &  (HaddrReg <= MEM_3_ENDADDR_GEN) ) begin
            CH3_EN_reg =1'b1;
            NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH3;
            NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH3;
            if(MEM_3_DQ_SIZE == 32 ) begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b0;
            end else if (MEM_3_DQ_SIZE == 16 ) begin
               SRAM_16BIT = 1'b1;
               SRAM_8BIT  = 1'b0;
            end else begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b1;
            end 
         end
      end
   end else if( NUM_MEMORY_CHIP == 3) begin
      always @ ( * ) begin
         CH0_EN_reg = 1'b0 ;
         CH1_EN_reg = 1'b0 ;
         CH2_EN_reg = 1'b0 ;
         CH3_EN_reg = 1'b0 ;
         SRAM_16BIT = 1'b0;
         SRAM_8BIT  = 1'b0;
         NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH0;
         NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH0;
         if ( (HaddrReg >= MEM_0_BASEADDR_GEN) &  (HaddrReg <= MEM_0_ENDADDR_GEN) ) begin
            CH0_EN_reg =1'b1;
            NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH0;
            NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH0;
            if(MEM_0_DQ_SIZE == 32 ) begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b0;
            end else if (MEM_0_DQ_SIZE == 16 ) begin
               SRAM_16BIT = 1'b1;
               SRAM_8BIT  = 1'b0;
            end else begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b1;
            end 
         end else if ( (HaddrReg >= MEM_1_BASEADDR_GEN) &  (HaddrReg <= MEM_1_ENDADDR_GEN) ) begin
            CH1_EN_reg =1'b1;
            NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH1;
            NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH1;
            if(MEM_1_DQ_SIZE == 32 ) begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b0;
            end else if (MEM_1_DQ_SIZE == 16 ) begin
               SRAM_16BIT = 1'b1;
               SRAM_8BIT  = 1'b0;
            end else begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b1;
            end 
         end else if ( (HaddrReg >= MEM_2_BASEADDR_GEN) &  (HaddrReg <= MEM_2_ENDADDR_GEN) ) begin
            CH2_EN_reg =1'b1;
            NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH2;
            NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH2;
            if(MEM_2_DQ_SIZE == 32 ) begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b0;
            end else if (MEM_2_DQ_SIZE == 16 ) begin
               SRAM_16BIT = 1'b1;
               SRAM_8BIT  = 1'b0;
            end else begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b1;
            end 
         end
      end
   end else if( NUM_MEMORY_CHIP == 2) begin
      always @ ( * ) begin
         CH0_EN_reg = 1'b0 ;
         CH1_EN_reg = 1'b0 ;
         CH2_EN_reg = 1'b0 ;
         CH3_EN_reg = 1'b0 ;
         SRAM_16BIT = 1'b0;
         SRAM_8BIT  = 1'b0;
         NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH0;
         NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH0;
         if ( (HaddrReg >= MEM_0_BASEADDR_GEN) &  (HaddrReg <= MEM_0_ENDADDR_GEN) ) begin
            CH0_EN_reg =1'b1;
            NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH0;
            NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH0;
            if(MEM_0_DQ_SIZE == 32 ) begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b0;
            end else if (MEM_0_DQ_SIZE == 16 ) begin
               SRAM_16BIT = 1'b1;
               SRAM_8BIT  = 1'b0;
            end else begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b1;
            end 
         end else if ( (HaddrReg >= MEM_1_BASEADDR_GEN) &  (HaddrReg <= MEM_1_ENDADDR_GEN) ) begin
            CH1_EN_reg =1'b1;
            NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH1;
            NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH1;
            if(MEM_1_DQ_SIZE == 32 ) begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b0;
            end else if (MEM_1_DQ_SIZE == 16 ) begin
               SRAM_16BIT = 1'b1;
               SRAM_8BIT  = 1'b0;
            end else begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b1;
            end 
         end
      end
   end else if( NUM_MEMORY_CHIP == 1 && MEMORY_ADDRESS_CONFIG_MODE == 1) begin
      always @ ( * ) begin
         CH0_EN_reg = 1'b0 ;
         CH1_EN_reg = 1'b0 ;
         CH2_EN_reg = 1'b0 ;
         CH3_EN_reg = 1'b0 ;
         SRAM_16BIT = 1'b0;
         SRAM_8BIT  = 1'b0;
         NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH0;
         NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH0;
         if ( (HaddrReg >= MEM_0_BASEADDR_GEN) &  (HaddrReg <= MEM_0_ENDADDR_GEN) ) begin
            CH0_EN_reg =1'b1;
            NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH0;
            NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH0;
            if(MEM_0_DQ_SIZE == 32 ) begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b0;
            end else if (MEM_0_DQ_SIZE == 16 ) begin
               SRAM_16BIT = 1'b1;
               SRAM_8BIT  = 1'b0;
            end else begin
               SRAM_16BIT = 1'b0;
               SRAM_8BIT  = 1'b1;
            end 
         end
      end
   end else if( NUM_MEMORY_CHIP == 1 && MEMORY_ADDRESS_CONFIG_MODE == 0) begin
      always @ ( * ) begin
         CH0_EN_reg = 1'b0 ;
         CH1_EN_reg = 1'b0 ;
         CH2_EN_reg = 1'b0 ;
         CH3_EN_reg = 1'b0 ;
         SRAM_16BIT = 1'b0;
         SRAM_8BIT  = 1'b0;
         NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH0;
         NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH0;
	 if(REMAP ==1'b0) begin
            if ( (HaddrReg >= MEM_0_BASEADDR_REMAP_DIS) &  (HaddrReg <= MEM_0_ENDADDR_REMAP_DIS) ) begin
               CH0_EN_reg =1'b1;
               NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH0;
               NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH0;
               if(MEM_0_DQ_SIZE == 32 ) begin
                  SRAM_16BIT = 1'b0;
                  SRAM_8BIT  = 1'b0;
               end else if (MEM_0_DQ_SIZE == 16 ) begin
                  SRAM_16BIT = 1'b1;
                  SRAM_8BIT  = 1'b0;
               end else begin
                  SRAM_16BIT = 1'b0;
                  SRAM_8BIT  = 1'b1;
               end 
            end
         end else begin
            if ( (HaddrReg >= MEM_0_BASEADDR_REMAP_EN) &  (HaddrReg <= MEM_0_ENDADDR_REMAP_EN) ) begin
               CH0_EN_reg =1'b1;
               NUM_WS_SRAM_WRITE = NUM_WS_SRAM_WRITE_CH0;
               NUM_WS_SRAM_READ  = NUM_WS_SRAM_READ_CH0;
               if(MEM_0_DQ_SIZE == 32 ) begin
                  SRAM_16BIT = 1'b0;
                  SRAM_8BIT  = 1'b0;
               end else if (MEM_0_DQ_SIZE == 16 ) begin
                  SRAM_16BIT = 1'b1;
                  SRAM_8BIT  = 1'b0;
               end else begin
                  SRAM_16BIT = 1'b0;
                  SRAM_8BIT  = 1'b1;
               end 
            end
	 end
      end
   end
endgenerate

    //------------------------------------------------------------------------------
    // Wait state counter
    //------------------------------------------------------------------------------
    // Generates count signal depending on the type of memory access taking place.
    // Counter decrements to zero.
    // Wait states are inserted when CurrentWait is not equal to ZERO.

    // Next counter value
   always @ (LoadWSCounter or WSCounterLoadVal or CurrentWait) begin
      if (LoadWSCounter)
         NextWait = WSCounterLoadVal;
      else
         if (CurrentWait == `ZERO)
            NextWait = `ZERO;
         else
            NextWait = CurrentWait - 1'b1;
   end

   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn))
         CurrentWait <= `ZERO;
      else
         CurrentWait <= NextWait;
   end

    //------------------------------------------------------------------------------
    // HREADY generation
    //------------------------------------------------------------------------------
    // HREADY is asserted when the wait state counter reaches zero.
    // HoldHreadyLow can be used to negate HREADY during the first half of a
    // word access when using 16-bit flash.
    assign HreadyNext = (NextWait == `ZERO) ? 1'b1 : 1'b0;

   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn))
         iHready <= 1'b1;
      else
         if(HoldHreadyLow )
            iHready <= 1'b0;
         else
            iHready <= HreadyNext;
   end

   assign HREADY = iHready;

    //------------------------------------------------------------------------------
    // MEMDATAOut generation
    //------------------------------------------------------------------------------
   always @ ( * ) begin
      if ( HselReg && HwriteReg ) begin
         if ( iFLASHCSN == 1'b0 ) begin    // Flash access
            if ( FLASH_DQ_SIZE == 16 ) begin
               if(wr_follow_rd_next ==1) begin
                  if (HsizeReg == `SZ_BYTE) begin
                     if(HaddrReg [1:0] ==2'b00 )begin
                        MEMDATAOut = {16'd0,MEMDATA_rd_flash[15:8],HWDATA[7:0]};
                     end else if (HaddrReg [1:0] ==2'b01) begin
                        MEMDATAOut = {16'd0,HWDATA[15:8],MEMDATA_rd_flash[7:0]};
                     end else if (HaddrReg [1:0] ==2'b10) begin
                        MEMDATAOut = {16'd0,MEMDATA_rd_flash[15:8],HWDATA[23:16]};
                     end else begin
                        MEMDATAOut = {16'd0,HWDATA[31:24],MEMDATA_rd_flash[7:0]};
                     end
	              end else begin
		             MEMDATAOut = HWDATA[31:0];
                  end
               end else begin
                  if(HsizeReg == `SZ_WORD) begin  
                     if ( trans_split_count[0] )
                        MEMDATAOut = { HWDATA[31:16], HWDATA[31:16] };
                     else
                        MEMDATAOut = { HWDATA[15:0], HWDATA[15:0] };
                  end else if(HsizeReg == `SZ_HALF) begin 
                     if(HaddrReg [1] ==1'b0 )
                        MEMDATAOut = { HWDATA[15:0], HWDATA[15:0] };
                     else
                        MEMDATAOut = { HWDATA[31:16], HWDATA[31:16] };
                  end else begin
                     if(HaddrReg [1] ==1'b0 )
                        MEMDATAOut = { HWDATA[15:0], HWDATA[15:0] };
                     else
                        MEMDATAOut = { HWDATA[31:16], HWDATA[31:16] };
                  end
               end
            end else if(FLASH_DQ_SIZE == 8) begin
               if(HsizeReg == `SZ_WORD) begin     
                  if (trans_split_count ==2'b00)
                     MEMDATAOut = { HWDATA[7:0], HWDATA[7:0], HWDATA[7:0], HWDATA[7:0] };
                  else if (trans_split_count ==2'b01)
                     MEMDATAOut = { HWDATA[15:8], HWDATA[15:8], HWDATA[15:8], HWDATA[15:8] };
                  else if (trans_split_count ==2'b10)
                     MEMDATAOut = { HWDATA[23:16], HWDATA[23:16], HWDATA[23:16], HWDATA[23:16] };
                  else //if (trans_split_count ==2'b11)
                     MEMDATAOut = { HWDATA[31:24], HWDATA[31:24], HWDATA[31:24], HWDATA[31:24] };
               end else if(HsizeReg == `SZ_HALF) begin  
                  if(HaddrReg [1] ==1'b0 )begin
                     if (trans_split_count[0] ==1'b0)
                        MEMDATAOut = { HWDATA[7:0], HWDATA[7:0], HWDATA[7:0], HWDATA[7:0] };
                     else
                        MEMDATAOut = { HWDATA[15:8], HWDATA[15:8], HWDATA[15:8], HWDATA[15:8] };
                  end else begin
                     if (trans_split_count[0] ==1'b0)
                        MEMDATAOut = { HWDATA[23:16], HWDATA[23:16], HWDATA[23:16], HWDATA[23:16]};
                     else
                        MEMDATAOut = { HWDATA[31:24], HWDATA[31:24], HWDATA[31:24], HWDATA[31:24] };
                  end
               end else begin
                  if(HaddrReg [1:0] ==2'b00 )
                     MEMDATAOut = { HWDATA[7:0], HWDATA[7:0], HWDATA[7:0], HWDATA[7:0] };
                  else if(HaddrReg [1:0] ==2'b01 )
                     MEMDATAOut = { HWDATA[15:8], HWDATA[15:8], HWDATA[15:8], HWDATA[15:8] };
                  else if(HaddrReg [1:0] ==2'b10 )
                     MEMDATAOut = { HWDATA[23:16], HWDATA[23:16], HWDATA[23:16], HWDATA[23:16]};
                  else
                     MEMDATAOut = { HWDATA[31:24], HWDATA[31:24], HWDATA[31:24], HWDATA[31:24] };
               end
            end else begin
               if(wr_follow_rd_next ==1) begin
                  if (HsizeReg == `SZ_HALF) begin
                     if(HaddrReg [1] ==1'b0 )begin
                        MEMDATAOut = {MEMDATA_rd_flash[31:16],HWDATA[15:0]};
                     end else begin
                        MEMDATAOut = {HWDATA[31:16],MEMDATA_rd_flash[15:0]};
                     end
                  end else if (HsizeReg == `SZ_BYTE) begin
                     if(HaddrReg [1:0] ==2'b00 )begin
                        MEMDATAOut = {MEMDATA_rd_flash[31:8],HWDATA[7:0]};
                     end else if (HaddrReg [1:0] ==2'b01) begin
                        MEMDATAOut = {MEMDATA_rd_flash[31:16],HWDATA[15:8],MEMDATA_rd_flash[7:0]};
                     end else if (HaddrReg [1:0] ==2'b10) begin
                        MEMDATAOut = {MEMDATA_rd_flash[31:24],HWDATA[23:16],MEMDATA_rd_flash[15:0]};
                     end else begin
                        MEMDATAOut = {HWDATA[31:24],MEMDATA_rd_flash[23:0]};
                     end
                  end else begin
                     MEMDATAOut = HWDATA[31:0];
                  end
               end else begin
                  MEMDATAOut = HWDATA[31:0];
               end
            end
         end else begin  // SRAM access
            if ( SYNC_SRAM ) begin
               if ( SRAM_16BIT ) begin
                  if(HsizeReg == `SZ_WORD) begin     
                     if (ssram_split_trans_next[0] ==1'b0)
                        MEMDATAOut = { HWDATA[31:16], HWDATA[31:16] };
                     else
                        MEMDATAOut = { HWDATA[15:0], HWDATA[15:0] };
                  end else if(HsizeReg == `SZ_HALF) begin  
                     if(HaddrReg [1] ==1'b0 )begin
                        MEMDATAOut = { HWDATA[15:0], HWDATA[15:0] };
                     end else begin
                        MEMDATAOut = { HWDATA[31:16], HWDATA[31:16] };
                     end
                  end else begin
                     if(HaddrReg [1] ==1'b0 )begin
                        MEMDATAOut = { HWDATA[15:0], HWDATA[15:0] };
                     end else begin
                        MEMDATAOut = { HWDATA[31:16], HWDATA[31:16] };
                     end
                  end
               end else if(SRAM_8BIT ==1'b1) begin
                  if(HsizeReg == `SZ_WORD) begin     
                     if (ssram_split_trans_next ==2'b11)
                        MEMDATAOut = { HWDATA[7:0], HWDATA[7:0], HWDATA[7:0], HWDATA[7:0] };
                     else if (ssram_split_trans_next ==2'b10)
                        MEMDATAOut = { HWDATA[15:8], HWDATA[15:8], HWDATA[15:8], HWDATA[15:8] };
                     else if (ssram_split_trans_next ==2'b01)
                        MEMDATAOut = { HWDATA[23:16], HWDATA[23:16], HWDATA[23:16], HWDATA[23:16] };
                     else
                        MEMDATAOut = { HWDATA[31:24], HWDATA[31:24], HWDATA[31:24], HWDATA[31:24] };
                  end else if(HsizeReg == `SZ_HALF) begin  
                     if(HaddrReg [1] ==1'b0 )begin
                        if (ssram_split_trans_next[0] ==1'b1)
                           MEMDATAOut = { HWDATA[7:0], HWDATA[7:0], HWDATA[7:0], HWDATA[7:0] };
                        else
                           MEMDATAOut = { HWDATA[15:8], HWDATA[15:8], HWDATA[15:8], HWDATA[15:8] };
                     end else begin
                        if (ssram_split_trans_next[0] ==1'b1)
                           MEMDATAOut = { HWDATA[23:16], HWDATA[23:16], HWDATA[23:16], HWDATA[23:16]};
                        else
                           MEMDATAOut = { HWDATA[31:24], HWDATA[31:24], HWDATA[31:24], HWDATA[31:24] };
                     end
                  end else begin
                     if(HaddrReg [1:0] ==2'b00 )begin
                        MEMDATAOut = { HWDATA[7:0], HWDATA[7:0], HWDATA[7:0], HWDATA[7:0] };
                     end else if(HaddrReg [1:0] ==2'b01 )begin
                        MEMDATAOut = { HWDATA[15:8], HWDATA[15:8], HWDATA[15:8], HWDATA[15:8] };
                     end else if(HaddrReg [1:0] ==2'b10 )begin
                        MEMDATAOut = { HWDATA[23:16], HWDATA[23:16], HWDATA[23:16], HWDATA[23:16]};
                     end else begin
                        MEMDATAOut = { HWDATA[31:24], HWDATA[31:24], HWDATA[31:24], HWDATA[31:24] };
                     end
                  end
               end else begin
                  MEMDATAOut = HWDATA[31:0];
               end
            end else begin
            if ( SRAM_16BIT ) begin
                  if(HsizeReg == `SZ_WORD) begin     
                     if (trans_split_count[0] ==1'b1)
                        MEMDATAOut = { HWDATA[31:16], HWDATA[31:16] };
                     else
                        MEMDATAOut = { HWDATA[15:0], HWDATA[15:0] };
                  end else if(HsizeReg == `SZ_HALF) begin  
                     if(HaddrReg [1] ==1'b0 )begin
                        MEMDATAOut = { HWDATA[15:0], HWDATA[15:0] };
                     end else begin
                        MEMDATAOut = { HWDATA[31:16], HWDATA[31:16] };
                     end
                  end else begin//if(HsizeReg == `SZ_BYTE) begin
                     if(HaddrReg [1] ==1'b0 )begin
                        MEMDATAOut = { HWDATA[15:0], HWDATA[15:0] };
                     end else begin
                        MEMDATAOut = { HWDATA[31:16], HWDATA[31:16] };
                     end
                  end
               end else if(SRAM_8BIT ==1'b1) begin
                  if(HsizeReg == `SZ_WORD) begin     
                     if (trans_split_count ==2'b00)
                        MEMDATAOut = { HWDATA[7:0], HWDATA[7:0], HWDATA[7:0], HWDATA[7:0] };
                     else if (trans_split_count ==2'b01)
                        MEMDATAOut = { HWDATA[15:8], HWDATA[15:8], HWDATA[15:8], HWDATA[15:8] };
                     else if (trans_split_count ==2'b10)
                        MEMDATAOut = { HWDATA[23:16], HWDATA[23:16], HWDATA[23:16], HWDATA[23:16] };
                     else
                        MEMDATAOut = { HWDATA[31:24], HWDATA[31:24], HWDATA[31:24], HWDATA[31:24] };
                  end else if(HsizeReg == `SZ_HALF) begin  
                     if(HaddrReg [1] ==1'b0 )begin
                        if (trans_split_count[0] ==1'b0)
                           MEMDATAOut = { HWDATA[7:0], HWDATA[7:0], HWDATA[7:0], HWDATA[7:0] };
                        else
                           MEMDATAOut = { HWDATA[15:8], HWDATA[15:8], HWDATA[15:8], HWDATA[15:8] };
                     end else begin
                        if (trans_split_count[0] ==1'b0)
                           MEMDATAOut = { HWDATA[23:16], HWDATA[23:16], HWDATA[23:16], HWDATA[23:16]};
                        else
                           MEMDATAOut = { HWDATA[31:24], HWDATA[31:24], HWDATA[31:24], HWDATA[31:24] };
                     end
                  end else begin
                     if(HaddrReg [1:0] ==2'b00 )begin
                        MEMDATAOut = { HWDATA[7:0], HWDATA[7:0], HWDATA[7:0], HWDATA[7:0] };
                     end else if(HaddrReg [1:0] ==2'b01 )begin
                        MEMDATAOut = { HWDATA[15:8], HWDATA[15:8], HWDATA[15:8], HWDATA[15:8] };
                     end else if(HaddrReg [1:0] ==2'b10 )begin
                        MEMDATAOut = { HWDATA[23:16], HWDATA[23:16], HWDATA[23:16], HWDATA[23:16]};
                     end else begin
                        MEMDATAOut = { HWDATA[31:24], HWDATA[31:24], HWDATA[31:24], HWDATA[31:24] };
                     end
                  end
               end else begin
                  MEMDATAOut = HWDATA[31:0];
               end
            end
         end
      end else begin
         MEMDATAOut = 32'd0;
      end
   end

    //------------------------------------------------------------------------------
    // StateName machine controlling memory access
    //------------------------------------------------------------------------------
   always @ (*)
   begin
      NextMemCntlState    = MemCntlState;
      NextMEMDATAOEN      = 1'b0;
      NextSelHaddrReg     = 1'b1;
      LoadWSCounter       = 1'b0;
      WSCounterLoadVal    = `ZERO;
      NextFLASHCSN        = 1'b1;
      NextFLASHWEN        = 1'b1;
      NextFLASHOEN        = 1'b1;
      NextSRAMCSN         = 1'b1;
      NextSRAMWEN         = 1'b1;
      NextSRAMOEN         = 1'b1;
      HoldHreadyLow       = 1'b0;
      trans_split_en      = 1'b0;
      trans_split_reset   = 1'b0;
      transaction_done    = 1'b0;
      wr_follow_rd        = 1'b0;
      ssram_split_trans   = 2'b00;
      ssram_read_buzy     = 1'b0;
      pipeline_rd         = 1'b0;
      ssram_split_trans_en= 1'b0;
      ssram_split_trans_load     = 1'b0;
      
      case (MemCntlState)    
         `ST_IDLE:
         begin
            StateName        = 32'h49444c; // For debug - ASCII value for "IDLE"
            NextMEMDATAOEN   = 1'b0;       // Drive memory data bus if remaining in IDLE state
            NextSelHaddrReg  = 1'b0;       // Drive memory address bus with registered address
            trans_split_reset= 1'b1;
            if (Valid) begin
               NextMemCntlState   = `ST_IDLE_1;
               HoldHreadyLow      = 1'b1;
               NextSelHaddrReg    = 1'b1;
            end else begin
               NextMemCntlState   = `ST_IDLE;
            end
         end
         `ST_IDLE_1:
         begin
            StateName       = 32'h49444c31; // For debug - ASCII value for "IDLE"
            NextMEMDATAOEN  = 1'b0;         // Drive memory data bus if remaining in IDLE state
            NextSelHaddrReg = 1'b1;         // Drive memory address bus with registered address
                                            //  to prevent unnecessary toggling of address lines
            trans_split_reset     = 1'b1;
            if ((Valid_d)) begin
               if (HselFlash_d) begin
                  NextFLASHCSN    = 1'b0;
                  NextSelHaddrReg = 1'b1;
                  if (HWRITE_d ) begin
                     if((HSIZE_d ==3'b000 && (FLASH_DQ_SIZE == 32 | FLASH_DQ_SIZE == 16)) | (HSIZE_d ==3'b001 && (FLASH_DQ_SIZE == 32 ))) begin
                        NextMemCntlState = `ST_FLASH_RD;
                        LoadWSCounter    = 1'b1;
                        WSCounterLoadVal = NUM_WS_FLASH_READ;
                        NextMEMDATAOEN   = 1'b1; 
                        wr_follow_rd     = 1'b1;
                     end else begin
                        NextMemCntlState = `ST_FLASH_WR;
                        LoadWSCounter    = 1'b1;
                        WSCounterLoadVal = NUM_WS_FLASH_WRITE;
                     end
                  end else begin
                     NextMemCntlState = `ST_FLASH_RD;
                     LoadWSCounter    = 1'b1;
                     WSCounterLoadVal = NUM_WS_FLASH_READ;
                     NextMEMDATAOEN   = 1'b1; 
                  end
               end else begin
                  if (SYNC_SRAM) begin
                     if (HWRITE_d) begin
                        NextMemCntlState = `ST_SSRAM_WR;
                        NextSRAMCSN      = 1'b0;
                        NextSRAMWEN      = 1'b0;
                        NextSelHaddrReg  = 1'b1;
                        if ( (SRAM_16BIT && (HSIZE_d == `SZ_WORD)) | (SRAM_8BIT && (HSIZE_d == `SZ_HALF))) begin
                           ssram_split_trans= 2'b01;
                           ssram_split_trans_load = 1'b1;
                           HoldHreadyLow    = 1'b1;
                        end else if ((SRAM_8BIT && (HSIZE_d == `SZ_WORD))) begin
                           ssram_split_trans= 2'b11;
                           ssram_split_trans_load = 1'b1;
                           HoldHreadyLow    = 1'b1;
                        end else begin
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `ZERO;
                           transaction_done = 1'b1;
                        end
                     end else begin
                        if (FLOW_THROUGH) begin
                           NextMemCntlState = `ST_SSRAM_RD2;
                        end else begin
                           NextMemCntlState = `ST_SSRAM_RD1;
                        end
                        if ( (SRAM_16BIT && (HSIZE_d == `SZ_WORD)) | (SRAM_8BIT && (HSIZE_d == `SZ_HALF))) begin
                           ssram_split_trans   = 2'b01;
                           ssram_split_trans_load = 1'b1;
                           NextMEMDATAOEN   = 1'b1; 
                           NextSRAMCSN      = 1'b0;
                           NextSelHaddrReg  = 1'b1;
                           HoldHreadyLow    = 1'b1;
                        end else if ((SRAM_8BIT && (HSIZE_d == `SZ_WORD))) begin
                           ssram_split_trans= 2'b11;
                           ssram_split_trans_load = 1'b1;
                           NextMEMDATAOEN   = 1'b1; 
                           NextSRAMCSN      = 1'b0;
                           NextSelHaddrReg  = 1'b1;
                           HoldHreadyLow    = 1'b1;
                        end else begin
                           NextMEMDATAOEN   = 1'b1; 
                           NextSRAMCSN      = 1'b0;
                           NextSelHaddrReg  = 1'b1;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `ONE;
                           ssram_read_buzy  = 1'b1;   
                        end
                     end
                  end else begin// asynchronous SRAM
                     if (HWRITE_d) begin
                        NextMemCntlState = `ST_ASRAM_WR;
                        NextSRAMCSN      = 1'b0;
                        NextSelHaddrReg  = 1'b1;
                        LoadWSCounter    = 1'b1;
                        WSCounterLoadVal = NUM_WS_SRAM_WRITE;
                        transaction_done = 1'b1;
                     end else begin
                        NextMemCntlState = `ST_ASRAM_RD;
                        NextMEMDATAOEN   = 1'b1; 
                        NextSRAMCSN      = 1'b0;
                        NextSelHaddrReg  = 1'b1;
                        LoadWSCounter    = 1'b1;
                        WSCounterLoadVal = NUM_WS_SRAM_READ;
                     end
                  end
               end
            end else begin
               NextMemCntlState = `ST_IDLE_1;
               wr_follow_rd     = 1'b0;
            end
         end
         `ST_FLASH_WR:
         begin
            StateName = 32'h465f5752; // For debug - ASCII value for "F_WR"
            NextFLASHCSN = 1'b0;
            NextFLASHWEN = 1'b0;
            if (CurrentWait == `ZERO) begin  // Wait state counter expired
               if (((FLASH_DQ_SIZE == 16 && (HsizeReg == `SZ_WORD)) | (FLASH_DQ_SIZE ==8 && (HsizeReg == `SZ_HALF))) && (trans_split_count[0]==1'b0) ) begin
                  HoldHreadyLow    = 1'b1;
                  trans_split_en   = 1'b1;
                  NextFLASHWEN     = 1'b1;
                  NextMemCntlState = `ST_FLASH_WR;
                  LoadWSCounter    = 1'b1;
                  WSCounterLoadVal = NUM_WS_FLASH_WRITE;
               end else if ((FLASH_DQ_SIZE ==8 && (HsizeReg == `SZ_WORD)) && (trans_split_count !=2'b11)) begin
                  HoldHreadyLow    = 1'b1;   
                  trans_split_en   = 1'b1;
                  NextFLASHWEN     = 1'b1;
                  NextMemCntlState = `ST_FLASH_WR;
                  LoadWSCounter    = 1'b1;
                  WSCounterLoadVal = NUM_WS_FLASH_WRITE;
               end else begin
                  NextFLASHCSN = 1'b1;
                  NextFLASHWEN = 1'b1;
                  if (Valid) begin
                     trans_split_reset  = 1'b1;
                     if (HselFlash) begin
                        NextFLASHCSN = 1'b0;
                        if (HWRITE) begin
                           if((HSIZE ==3'b000 && (FLASH_DQ_SIZE == 32 | FLASH_DQ_SIZE == 16)) | (HSIZE ==3'b001 && (FLASH_DQ_SIZE == 32 ))) begin
                              NextMemCntlState = `ST_FLASH_RD;
                              LoadWSCounter    = 1'b1;
                              WSCounterLoadVal = NUM_WS_FLASH_READ;
                              NextMEMDATAOEN   = 1'b1;
                              wr_follow_rd     = 1'b1;
                           end else begin
                              NextMemCntlState = `ST_FLASH_WR;
                              LoadWSCounter    = 1'b1;
                              WSCounterLoadVal = NUM_WS_FLASH_WRITE;
                           end
                        end else begin
                           NextMemCntlState = `ST_FLASH_RD;
                           NextMEMDATAOEN   = 1'b1;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = NUM_WS_FLASH_READ;
                        end
                     end else begin
                        if (SYNC_SRAM) begin
                           NextMemCntlState = `ST_WAIT;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `MAX_WAIT; // non-zero value to prevent assertion of HREADY
                        end else begin // asynchronous SRAM
                           NextMemCntlState = `ST_WAIT1;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `MAX_WAIT; // non-zero value to prevent assertion of HREADY
                        end
                     end
                  end else begin
                     NextMemCntlState = `ST_IDLE;
                  end
               end
            end else if(CurrentWait == `ONE) begin
               if (wr_follow_rd_next ==1'b1) begin
                  wr_follow_rd =1'b1;
               end
               if ((FLASH_DQ_SIZE ==8 && (HsizeReg == `SZ_WORD)) && (trans_split_count !=2'b11)) begin
                  HoldHreadyLow = 1'b1;
               end else if (((FLASH_DQ_SIZE == 16 && (HsizeReg == `SZ_WORD)) | (FLASH_DQ_SIZE ==8 && (HsizeReg == `SZ_HALF))) && (trans_split_count[0]==1'b0) ) begin
                  HoldHreadyLow = 1'b1;
               end
           end else if(wr_follow_rd_next ==1'b1) begin
              wr_follow_rd =1'b1;
           end
         end
         `ST_FLASH_RD:
         begin
            StateName = 32'h465f5244; // For debug - ASCII value for "F_RD"
            NextFLASHCSN   = 1'b0;
            NextFLASHOEN   = 1'b0;
            NextMEMDATAOEN = 1'b1;
            if (CurrentWait == `ZERO) begin   // Wait state counter expired
               if (((FLASH_DQ_SIZE == 16 && (HsizeReg == `SZ_WORD)) | (FLASH_DQ_SIZE ==8 && (HsizeReg == `SZ_HALF))) && (trans_split_count[0]==1'b0) ) begin
                  HoldHreadyLow    = 1'b1;
                  NextMemCntlState = `ST_FLASH_RD;
                  LoadWSCounter    = 1'b1;
                  WSCounterLoadVal = NUM_WS_FLASH_READ;
                  trans_split_en   = 1'b1;
               end else if ((FLASH_DQ_SIZE ==8 && (HsizeReg == `SZ_WORD)) && (trans_split_count !=2'b11)) begin
                  HoldHreadyLow    = 1'b1;
                  NextMemCntlState = `ST_FLASH_RD;
                  LoadWSCounter    = 1'b1;
                  WSCounterLoadVal = NUM_WS_FLASH_READ;
                  trans_split_en   = 1'b1;
               end else if (wr_follow_rd_next ==1'b1) begin
                  HoldHreadyLow    = 1'b1;
                  wr_follow_rd     = 1'b1;
                  NextMemCntlState = `ST_WAIT;
                  LoadWSCounter    = 1'b1;
                  WSCounterLoadVal = `MAX_WAIT;
               end else begin
                  NextFLASHCSN = 1'b1;
                  if (Valid) begin
                     trans_split_reset  = 1'b1;
                     if (HselFlash) begin
                        NextFLASHCSN = 1'b0;
                        if (HWRITE) begin
                           // If moving from flash read to flash write, go to WAIT
                           // state for one cycle to allow time for changing driver
                           // of data bus.
                           NextMemCntlState = `ST_WAIT;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `MAX_WAIT; // non-zero value to prevent assertion of HREADY
                        end else begin
                           NextMemCntlState = `ST_FLASH_RD;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = NUM_WS_FLASH_READ;
                        end
                     end else begin
                        if (SYNC_SRAM) begin
                           NextMemCntlState = `ST_WAIT;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `MAX_WAIT; // non-zero value to prevent assertion of HREADY
                        end else begin // asynchronous SRAM
                           // If moving from flash read to async SRAM read/write, go to WAIT
                           // state for one cycle to allow time for changing driver
                           // of data bus.
                           NextMemCntlState = `ST_WAIT1;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `MAX_WAIT; // non-zero value to prevent assertion of HREADY
                        end
                     end
                  end else begin
                     NextMemCntlState = `ST_IDLE;
                  end
               end
            end else if(CurrentWait == `ONE) begin
               if (wr_follow_rd_next ==1'b1) begin
                  wr_follow_rd =1'b1;
                  HoldHreadyLow = 1'b1; 
               end
               if ((FLASH_DQ_SIZE ==8 && (HsizeReg == `SZ_WORD)) && (trans_split_count !=2'b11)) begin
                  HoldHreadyLow = 1'b1;
               end else if (((FLASH_DQ_SIZE == 16 && (HsizeReg == `SZ_WORD)) | (FLASH_DQ_SIZE ==8 && (HsizeReg == `SZ_HALF))) && (trans_split_count[0]==1'b0) ) begin
                  HoldHreadyLow = 1'b1;
               end
            end else if(wr_follow_rd_next ==1'b1) begin
               wr_follow_rd =1'b1;
            end
         end
         `ST_ASRAM_WR:
         begin
            StateName = 32'h41535752; // For debug - ASCII value for "ASWR"
            NextSRAMCSN = 1'b0;
            NextSRAMWEN = 1'b0;
            transaction_done = next_transaction_done;
            if (CurrentWait == `ZERO) begin  // Wait state counter expired
               NextSRAMCSN = 1'b1;
               NextSRAMWEN = 1'b1;
               if ( ((SRAM_16BIT && (HsizeReg == `SZ_WORD)) | (SRAM_8BIT && (HsizeReg == `SZ_HALF))) && (trans_split_count[0] != 1'b1) ) begin
                  NextSRAMCSN      = 1'b0;
                  trans_split_en   = 1'b1;
                  HoldHreadyLow    = 1'b1;
                  NextMemCntlState = `ST_ASRAM_WR;
                  LoadWSCounter    = 1'b1;
                  WSCounterLoadVal = NUM_WS_SRAM_WRITE;
                  transaction_done = 1'b1;
               end else if ((SRAM_8BIT && (HsizeReg == `SZ_WORD)) && (trans_split_count !=2'b11)) begin
                  NextSRAMCSN      = 1'b0;
                  trans_split_en   = 1'b1;
                  HoldHreadyLow    = 1'b1;
                  NextMemCntlState = `ST_ASRAM_WR;
                  LoadWSCounter    = 1'b1;
                  WSCounterLoadVal = NUM_WS_SRAM_WRITE;
                  transaction_done = 1'b1;
               end else begin
                  if (Valid) begin
                     if (HselFlash) begin
                        NextFLASHCSN = 1'b0;
                        if (HWRITE) begin
                           if((HSIZE ==3'b000 && (FLASH_DQ_SIZE == 32 | FLASH_DQ_SIZE == 16)) | (HSIZE ==3'b001 && (FLASH_DQ_SIZE == 32 ))) begin
                              NextMemCntlState = `ST_FLASH_RD;
                              LoadWSCounter    = 1'b1;
                              WSCounterLoadVal = NUM_WS_FLASH_READ;
                              NextMEMDATAOEN   = 1'b1;
                              wr_follow_rd     = 1'b1;
                           end else begin
                              NextMemCntlState = `ST_FLASH_WR;
                              LoadWSCounter    = 1'b1;
                              WSCounterLoadVal = NUM_WS_FLASH_WRITE;
                             trans_split_reset = 1'b1;
                           end
                        end else begin
                           NextMemCntlState = `ST_FLASH_RD;
                           NextMEMDATAOEN   = 1'b1;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = NUM_WS_FLASH_READ;
                           trans_split_reset= 1'b1;
                        end
                     end else begin 
                        if(next_transaction_done == 1'b0) begin
                           transaction_done = 1'b1 ;
                           if (HWRITE) begin
                              NextMemCntlState = `ST_ASRAM_WR;
                              NextSRAMCSN      = 1'b0;
                              NextSRAMWEN      = 1'b1;
                              LoadWSCounter    = 1'b1;
                              WSCounterLoadVal = NUM_WS_SRAM_WRITE;
                           end else begin
                              trans_split_reset = 1'b1;
                              NextMemCntlState  = `ST_ASRAM_RD;
                              NextMEMDATAOEN    = 1'b1;
                              LoadWSCounter     = 1'b1;
                              NextSRAMCSN       = 1'b0;
                              WSCounterLoadVal  = NUM_WS_SRAM_READ;
                           end
                        end else begin
                           NextSRAMCSN      = 1'b1;
                           transaction_done = 1'b0 ;
                           NextMemCntlState = `ST_WAIT;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `MAX_WAIT;
                        end 
                     end
                  end else begin
                     NextMemCntlState = `ST_IDLE;
                     NextSRAMCSN      = 1'b1;
                  end
               end
            end else if(CurrentWait == `ONE) begin
               transaction_done = 1'b1 ;
               if ((((SRAM_16BIT && (HsizeReg == `SZ_WORD)) | (SRAM_8BIT && (HsizeReg == `SZ_HALF))) && (trans_split_count[0] != 1'b1)) | ((SRAM_8BIT && (HsizeReg == `SZ_WORD)) && (trans_split_count !=2'b11)))
                  HoldHreadyLow = 1'b1;
               else
                  HoldHreadyLow = 1'b0;
               if (wr_follow_rd_next ==1'b1)
                  wr_follow_rd =1'b1;
            end else begin
               if (wr_follow_rd_next ==1'b1)
                  wr_follow_rd =1'b1;
            end
         end
         `ST_ASRAM_RD:
         begin
            StateName       = 32'h41535244; // For debug - ASCII value for "ASRD"
            NextSRAMCSN     = 1'b0;
            NextSRAMOEN     = 1'b0;
            NextMEMDATAOEN  = 1'b1; // negate
            transaction_done= next_transaction_done;
            if (CurrentWait == `ZERO) begin   // Wait state counter expired
               if ( (SRAM_16BIT && (HsizeReg == `SZ_WORD)) | (SRAM_8BIT && (HsizeReg == `SZ_HALF)) && (trans_split_count[0] != 1'b1) ) begin
                  trans_split_en   = 1'b1;
                  HoldHreadyLow    = 1'b1;
                  NextMemCntlState = `ST_ASRAM_RD;
                  LoadWSCounter    = 1'b1;
                  transaction_done = 1'b1 ;
                  WSCounterLoadVal = NUM_WS_SRAM_READ;
               end else if ((SRAM_8BIT && (HsizeReg == `SZ_WORD)) && (trans_split_count !=2'b11)) begin
                  trans_split_en   = 1'b1;
                  HoldHreadyLow    = 1'b1;
                  NextMemCntlState = `ST_ASRAM_RD;
                  LoadWSCounter    = 1'b1;
                  WSCounterLoadVal = NUM_WS_SRAM_READ;
                  transaction_done = 1'b1;
               end else begin
                  NextSRAMCSN = 1'b1;
                  if (Valid) begin
                     trans_split_reset = 1'b1;
                     if (HselFlash) begin
                     // If moving from SRAM read to flash read/write, go to WAIT
                     // state for one cycle to allow time for changing driver
                     // of data bus.
                        NextMemCntlState = `ST_WAIT;
                        LoadWSCounter    = 1'b1;
                        WSCounterLoadVal = `MAX_WAIT; // non-zero value to prevent assertion of HREADY
                     end else begin
                        if(next_transaction_done == 0) begin
                           transaction_done = 1'b1;
                           NextSRAMCSN      = 1'b0;
                           if (HWRITE) begin
                              // If moving from SRAM read to SRAM write, go to WAIT
                              // state for one cycle to allow time for changing driver
                              // of data bus.
                              NextMemCntlState = `ST_WAIT;
                              LoadWSCounter    = 1'b1;
                              WSCounterLoadVal = `MAX_WAIT;
                           end else begin
                              NextMemCntlState = `ST_ASRAM_RD;
                              NextSelHaddrReg  = 1'b1;
                              LoadWSCounter    = 1'b1;
                              WSCounterLoadVal = NUM_WS_SRAM_READ;
                           end
                        end else begin
                           NextSRAMCSN      = 1'b1;
                           transaction_done = 1'b0 ;
                           NextMemCntlState = `ST_WAIT;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `MAX_WAIT;
                        end
                     end
                  end else begin
                     NextMemCntlState = `ST_IDLE;
                     NextSRAMCSN      = 1'b1;
                  end
               end 
            end else if(CurrentWait == `ONE) begin
               transaction_done = 1'b1 ;
               if (((SRAM_16BIT && (HsizeReg == `SZ_WORD))|(SRAM_8BIT && (HsizeReg == `SZ_HALF))&&(trans_split_count[0] != 1'b1)) | ((SRAM_8BIT && (HsizeReg == `SZ_WORD)) && (trans_split_count !=2'b11)))
                  HoldHreadyLow = 1'b1;
               else
                  HoldHreadyLow = 1'b0;
            end
         end
         `ST_SSRAM_WR:
         begin
            StateName        = 32'h53535752;            // For Debug - ASCII value for "SSWR"
            transaction_done = next_transaction_done;
            if(ssram_split_trans_next == 2'd0 ) begin
               if (Valid) begin
                  if (HselFlash) begin
                     if (SHARED_RW) begin
                        NextMemCntlState = `ST_WAIT;
                        LoadWSCounter    = 1'b1;
                        WSCounterLoadVal = `MAX_WAIT;
                     end else begin
                        NextFLASHCSN = 1'b0;
                        if (HWRITE) begin
                           if((HSIZE ==3'b000 && (FLASH_DQ_SIZE == 32 | FLASH_DQ_SIZE == 16)) | (HSIZE ==3'b001 && (FLASH_DQ_SIZE == 32 ))) begin
                              NextMemCntlState = `ST_FLASH_RD;
                              LoadWSCounter    = 1'b1;
                              WSCounterLoadVal = NUM_WS_FLASH_READ;
                              NextMEMDATAOEN   = 1'b1;
                              wr_follow_rd     = 1'b1;
                           end else begin
                              NextMemCntlState = `ST_FLASH_WR;
                              LoadWSCounter    = 1'b1;
                              WSCounterLoadVal = NUM_WS_FLASH_WRITE;
                              trans_split_reset      = 1'b1;
                           end
                        end else begin
                           NextMemCntlState = `ST_FLASH_RD;
                           NextMEMDATAOEN   = 1'b1;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = NUM_WS_FLASH_READ;
                           trans_split_reset      = 1'b1;
                        end
                     end
                  end else begin
                     if(next_transaction_done == 0) begin
                        transaction_done = 1'b1 ;
                        if (HWRITE) begin
                           NextMemCntlState = `ST_WAIT;
                           NextSRAMCSN      = 1'b1;
                           NextSRAMWEN      = 1'b0;
                           HoldHreadyLow    = 1'b1;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `ZERO;
                        end else begin
                           NextMemCntlState = `ST_WAIT;
                           NextMEMDATAOEN   = 1'b1;
                           NextSRAMCSN      = 1'b1;
                           NextSRAMWEN      = 1'b1;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `ONE;
                        end
                     end else begin
                        NextSRAMCSN      = 1'b1;
                        transaction_done = 1'b0 ;
                        NextMemCntlState = `ST_WAIT;
                        LoadWSCounter    = 1'b1;
                        WSCounterLoadVal = `MAX_WAIT;   // Non-zero value to prevent assertion of HREADY
                     end 
                  end
               end else begin
                  NextMemCntlState = `ST_IDLE;
                  NextSRAMCSN      = 1'b1;
                  NextSRAMWEN      = 1'b1;
               end
            end else begin
               NextMemCntlState = `ST_SSRAM_WR;
               NextSRAMCSN      = 1'b0;
               NextSRAMWEN      = 1'b0;
               NextSelHaddrReg  = 1'b1;
               LoadWSCounter    = 1'b1;
               WSCounterLoadVal = `ZERO;
               ssram_split_trans_en   = 1'b1;
               if(ssram_split_trans_next ==2'd1)
                  HoldHreadyLow  = 1'b0;
               else
                  HoldHreadyLow  = 1'b1;
            end
         end
         `ST_SSRAM_RD1:
         begin
            StateName = 32'h53535231; // For debug - ASCII value for "SSR1"
            NextMemCntlState = `ST_SSRAM_RD2;
            NextMEMDATAOEN   = 1'b1;
            NextSRAMCSN      = 1'b0;
            NextSelHaddrReg  = 1'b1;
            HoldHreadyLow    = 1'b1;
            ssram_read_buzy  = 1'b1;
            pipeline_rd      = 1'b1;
            NextSRAMOEN      = 1'b0;    
         end
         `ST_SSRAM_RD2:
         begin
            StateName = 32'h53535232; // For debug - ASCII value for "SSR2"
            NextMEMDATAOEN = 1'b1;
            NextSRAMOEN = 1'b0;
            transaction_done = next_transaction_done;
            if(ssram_split_trans_next == 2'd0 ) begin
               if (Valid) begin
                  if (HselFlash) begin
                     NextMemCntlState = `ST_WAIT;
                     LoadWSCounter = 1'b1;
                     WSCounterLoadVal = `MAX_WAIT;
                  end else begin
                     if(next_transaction_done == 1'b0) begin
                        transaction_done = 1'b1 ;
                        if (HWRITE) begin
                           NextMemCntlState = `ST_WAIT;
                           NextSRAMCSN      = 1'b1;
                           NextSelHaddrReg  = 1'b1;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `ZERO;
                           HoldHreadyLow    = 1'b1;
                        end else begin
                           NextMemCntlState = `ST_WAIT;
                           NextSRAMCSN      = 1'b1;
                           NextSelHaddrReg  = 1'b0;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `ZERO;
                           HoldHreadyLow    = 1'b1;
                       end
                     end else begin
                        NextSRAMCSN      = 1'b1;
                        transaction_done = 1'b0 ;
                        NextMemCntlState = `ST_WAIT;
                        LoadWSCounter    = 1'b1;
                        WSCounterLoadVal = `MAX_WAIT; // non-zero value to prevent assertion of HREADY
                     end
                  end
               end else if(ssram_read_buzy_next ==1'b1) begin
                  NextMemCntlState = `ST_SSRAM_RD2;
                  NextSRAMCSN      = 1'b0;
                  LoadWSCounter    = 1'b1;
                  WSCounterLoadVal = `ONE;
               end else if(ssram_read_buzy_next_d ==1'b1) begin
                  NextMemCntlState = `ST_SSRAM_RD2;
                  NextSRAMCSN      = 1'b0;
                  LoadWSCounter    = 1'b1;
                  if(FLOW_THROUGH == 0) begin
                     WSCounterLoadVal = `ZERO; 
                  end else begin
                     WSCounterLoadVal = `ONE; 
                  end
               end else begin
                  NextMemCntlState = `ST_IDLE;
                  NextSRAMCSN      = 1'b1;
               end
            end else begin
               if(FLOW_THROUGH == 0 && ssram_split_trans_next !=2'b00 ) begin
                  if(pipeline_rd_d1) begin
                     ssram_split_trans_en    = 1'b0;
                     HoldHreadyLow     = 1'b1;
                     NextMemCntlState  = `ST_SSRAM_RD2;
                     NextSRAMCSN       = 1'b0;
                  end else begin
                     ssram_split_trans_en    = 1'b1;
                     HoldHreadyLow     = 1'b1;
                     NextMemCntlState  = `ST_SSRAM_RD1;
                     NextSRAMCSN       = 1'b0;
                  end
               end else begin
                  ssram_split_trans_en    = 1'b0;
                  LoadWSCounter    = 1'b1;
                  WSCounterLoadVal = `ONE;
                  NextMemCntlState = `ST_WAIT;
                  NextSRAMCSN       = 1'b0;
                  ssram_read_buzy   = 1'b1;
               end
            end
         end
         `ST_WAIT1:
         begin
            StateName         = 32'h57415f31; // For debug - ASCII value for "WA_1"
            NextMemCntlState  = `ST_WAIT;
            transaction_done  = 1'b0;
            trans_split_reset = 1'b1;
         end
         `ST_WAIT:
         begin
            transaction_done = 1'b0;
            StateName        = 32'h57414954; // For debug - ASCII value for "WAIT"
            trans_split_reset= 1'b1;
            HoldHreadyLow    = 1'b0;
            if(ssram_read_buzy_next) begin
               NextMemCntlState        = `ST_SSRAM_RD2;
               HoldHreadyLow           = 1'b1;
	       NextSRAMCSN             = 1'b0;
               NextSRAMOEN             = 1'b0;
               ssram_split_trans_en    = 1'b1;
	    end else begin
               if (HselFlashReg) begin
                  NextFLASHCSN = 1'b0;
		          NextSRAMCSN  = 1'b1;
                  if (HwriteReg | wr_follow_rd_next ) begin
                     if (wr_follow_rd_next) begin
                        NextMemCntlState = `ST_FLASH_WR;
                        NextMEMDATAOEN   = 1'b0;
                        LoadWSCounter    = 1'b1;
                        WSCounterLoadVal = NUM_WS_FLASH_WRITE;
                        wr_follow_rd     = 1'b1;
                     end else if((HSIZE_d ==3'b000 && (FLASH_DQ_SIZE == 32 | FLASH_DQ_SIZE == 16)) | (HSIZE_d ==3'b001 && (FLASH_DQ_SIZE == 32 ))) begin
                        NextMemCntlState = `ST_FLASH_RD;
                        LoadWSCounter    = 1'b1;
                        WSCounterLoadVal = NUM_WS_FLASH_READ;
                        NextMEMDATAOEN   = 1'b1;
                        wr_follow_rd     = 1'b1;
                     end else begin
                        NextMemCntlState = `ST_FLASH_WR;
                        NextMEMDATAOEN   = 1'b0;
                        LoadWSCounter    = 1'b1;
                        WSCounterLoadVal = NUM_WS_FLASH_WRITE;
                     end
                  end else begin
                     NextMemCntlState = `ST_FLASH_RD;
                     NextMEMDATAOEN   = 1'b1;
                     LoadWSCounter    = 1'b1;
                     WSCounterLoadVal = NUM_WS_FLASH_READ;
                  end
               end else if (HselSramReg) begin
                  if (SYNC_SRAM) begin 
                     if (HwriteReg) begin
                        if ( (SRAM_16BIT && (HsizeReg == `SZ_WORD)) | (SRAM_8BIT && (HsizeReg == `SZ_HALF))) begin
                           ssram_split_trans= 2'b01;
                           ssram_split_trans_load = 1'b1;
                           HoldHreadyLow    = 1'b1;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `ZERO;
                        end else if ((SRAM_8BIT && (HsizeReg == `SZ_WORD))) begin
                           ssram_split_trans= 2'b11;
                           ssram_split_trans_load = 1'b1;
                           HoldHreadyLow    = 1'b1;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `ZERO;
                        end else begin
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `ZERO;
                           transaction_done = 1'b1;
                        end
                        NextMemCntlState = `ST_SSRAM_WR;
                        NextSRAMCSN      = 1'b0;
                        NextSRAMWEN      = 1'b0;
                        NextSelHaddrReg  = 1'b1;
                     end else begin
                        if (FLOW_THROUGH) begin
                           NextMemCntlState = `ST_SSRAM_RD2;
                        end else begin
                           NextMemCntlState = `ST_SSRAM_RD1;
                        end
                        if ( (SRAM_16BIT && (HsizeReg == `SZ_WORD)) | (SRAM_8BIT && (HsizeReg == `SZ_HALF))) begin
                           ssram_split_trans= 2'b01;
                           ssram_split_trans_load = 1'b1;
                           HoldHreadyLow    = 1'b1;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `ZERO;
                        end else if ((SRAM_8BIT && (HsizeReg == `SZ_WORD))) begin
                           ssram_split_trans= 2'b11;
                           ssram_split_trans_load = 1'b1;
                           HoldHreadyLow    = 1'b1;
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `ZERO;
                        end else begin
                           LoadWSCounter    = 1'b1;
                           WSCounterLoadVal = `ONE;
                           transaction_done = 1'b1;
                           NextMEMDATAOEN   = 1'b0;
                           ssram_read_buzy  = 1'b1;
                        end
                        NextMEMDATAOEN  = 1'b1;
                        NextSRAMCSN     = 1'b0;
                        NextSelHaddrReg = 1'b1;
                     end
                  end else begin
                     if (HwriteReg) begin
                        NextMemCntlState = `ST_ASRAM_WR;
                        NextMEMDATAOEN   = 1'b0;
                        LoadWSCounter    = 1'b1;
                        NextSRAMCSN      = 1'b0;
                        WSCounterLoadVal = NUM_WS_SRAM_WRITE;
                     end else begin
                        NextMemCntlState = `ST_ASRAM_RD;
                        NextMEMDATAOEN   = 1'b1;
                        LoadWSCounter    = 1'b1;
                        NextSRAMCSN      = 1'b0;
                        WSCounterLoadVal = NUM_WS_SRAM_READ;
                     end
                  end
               end else begin
                  NextMemCntlState = `ST_IDLE;
                  NextSRAMCSN      = 1'b1;
               end
            end
         end
         default:
         begin
            StateName = 32'h64656674; // For debug - ASCII value for "deft"
            NextMemCntlState = `ST_IDLE;
         end
      endcase
   end

   // Synchronous part of state machine
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn)) begin
         MemCntlState          <= `ST_IDLE;
         SelHaddrReg           <= 1'b0;
         iFLASHCSN             <= 1'b1;
         iMEMDATAOEN           <= 1'b0;    // Driving memory data bus by default
         trans_split_count     <= 2'b00;
         Valid_d               <= 1'b0;
         HselFlash_d           <= 1'b0;
         HWRITE_d              <= 1'b0;
         HSIZE_d               <= 3'b000;
         wr_follow_rd_next     <= 1'b0;
         ssram_read_buzy_next  <= 1'b0;
         ssram_read_buzy_next_d<= 1'b0;
         next_transaction_done <= 1'b0;
         ssram_split_trans_next<= 2'b00;
         pipeline_rd_d1        <= 1'b0;
         pipeline_rd_d2        <= 1'b0;
      end else begin
         MemCntlState          <= NextMemCntlState;
         SelHaddrReg           <= NextSelHaddrReg;
         iFLASHCSN             <= NextFLASHCSN;
         iMEMDATAOEN           <= NextMEMDATAOEN;
         Valid_d               <= Valid;
         HselFlash_d           <= HselFlash;
         HWRITE_d              <= HWRITE;
         HSIZE_d               <= HSIZE;
         wr_follow_rd_next     <= wr_follow_rd;
         ssram_read_buzy_next  <= ssram_read_buzy;
         ssram_read_buzy_next_d<= ssram_read_buzy_next;
         next_transaction_done <= transaction_done;
         pipeline_rd_d1        <= pipeline_rd;
         pipeline_rd_d2        <= pipeline_rd_d1;

         if(ssram_split_trans_load ) begin
            ssram_split_trans_next <= ssram_split_trans ;
         end else begin
            ssram_split_trans_next <= ssram_split_trans_next - ssram_split_trans_en;
         end

         if(trans_split_reset ==1'b1) begin
            trans_split_count    <= 2'b00;
         end else begin
            trans_split_count    <= trans_split_count  + trans_split_en;
         end
      end
   end

generate if (NUM_MEMORY_CHIP == 1)
begin
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn)) begin
         iSRAMCSN        <= 1'b1;
      end else begin
         if(CH0_EN_reg)
            iSRAMCSN[0]        <= NextSRAMCSN;
         else
            iSRAMCSN[0]        <= 1'b1;
      end
   end
end
endgenerate

generate if (NUM_MEMORY_CHIP == 2)
begin
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn)) begin
         iSRAMCSN        <= 2'b11;
      end else begin
         if(CH0_EN_reg) begin
            iSRAMCSN[0]        <= NextSRAMCSN;
            iSRAMCSN[1]        <= 1'b1;
         end else if(CH1_EN_reg) begin
            iSRAMCSN[0]        <= 1'b1;
            iSRAMCSN[1]        <= NextSRAMCSN;
         end
      end
   end
end
endgenerate

generate if (NUM_MEMORY_CHIP == 3)
begin
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn)) begin
         iSRAMCSN        <= 3'b111;
      end else begin
         if(CH0_EN_reg) begin
            iSRAMCSN[0]        <= NextSRAMCSN;
            iSRAMCSN[2:1]      <= 2'b11;
         end else if(CH1_EN_reg) begin
            iSRAMCSN[0]        <= 1'b1;
            iSRAMCSN[1]        <= NextSRAMCSN;
            iSRAMCSN[2]        <= 1'b1;
         end else if(CH2_EN_reg) begin
            iSRAMCSN[1:0]      <= 2'b11;
            iSRAMCSN[2]        <= NextSRAMCSN;
         end
      end
   end
end
endgenerate

generate if (NUM_MEMORY_CHIP == 4)
begin
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn)) begin
         iSRAMCSN        <= 4'b1111;
      end else begin
         if(CH0_EN_reg) begin
            iSRAMCSN[0]        <= NextSRAMCSN;
            iSRAMCSN[3:1]      <= 3'b111;
         end else if(CH1_EN_reg) begin
            iSRAMCSN[0]        <= 1'b1;
            iSRAMCSN[1]        <= NextSRAMCSN;
            iSRAMCSN[3:2]      <= 2'b11;
         end else if(CH2_EN_reg) begin
            iSRAMCSN[1:0]      <= 2'b11;
            iSRAMCSN[2]        <= NextSRAMCSN;
            iSRAMCSN[3]        <= 1'b1;
         end else if(CH3_EN_reg) begin
            iSRAMCSN[2:0]      <= 3'b111;
            iSRAMCSN[3]        <= NextSRAMCSN;
         end
      end
   end
end
endgenerate

    // Signals clocked with falling edge of HCLK
   always @ (negedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn)) begin
         iFLASHOEN <= 1'b1;
         iFLASHWEN <= 1'b1;
         iSRAMOEN  <= 1'b1;
      end else begin
         iFLASHOEN <= NextFLASHOEN;
         iFLASHWEN <= NextFLASHWEN;
         iSRAMOEN  <= NextSRAMOEN;
      end
   end

generate if (SYNC_SRAM) begin
   // Clock SRAM write enable with rising edge of HCLK for sync. SRAM
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn))
         iSRAMWEN  <= 1'b1;
      else
         iSRAMWEN  <= NextSRAMWEN;
   end
end
else begin
   // Clock SRAM write enable with falling edge of HCLK for async. SRAM
   always @ (negedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn))
         iSRAMWEN  <= 1'b1;
      else
         iSRAMWEN  <= NextSRAMWEN;
   end
end
endgenerate

    //------------------------------------------------------------------------------
    // Memory address mux
    //------------------------------------------------------------------------------

generate  if (SYNC_SRAM == 0) begin
   always @(*) begin
      if (!iFLASHCSN) begin // Flash access
         if (FLASH_DQ_SIZE == 16) begin
            if (FLASH_TYPE == 0) begin
               if (HsizeReg == `SZ_WORD) begin
                  if (trans_split_count[0] == 1'b0) begin
                     MEMADDR = {1'b0, HaddrReg[27:2], 1'b0};
                  end else begin
                     MEMADDR = {1'b0, HaddrReg[27:2], 1'b1};
                  end
               end else begin
                  MEMADDR = { 1'b0, HaddrReg[27:1]};
               end
            end else begin
               if (HsizeReg == `SZ_WORD) begin
                  if (trans_split_count[0] == 1'b0) begin
                     MEMADDR = {HaddrReg[27:2], 1'b0, 1'b0};
                  end else begin
                     MEMADDR = {HaddrReg[27:2], 1'b1, 1'b0};
                  end
               end else begin
                  MEMADDR = {HaddrReg[27:1],1'b0};
               end
	    end
         end else if (FLASH_DQ_SIZE == 8) begin
            if (HsizeReg == `SZ_WORD) begin
               if (trans_split_count == 2'b00)
                  MEMADDR = {HaddrReg[27:2] , 2'b00};
               else if (trans_split_count ==2'b01)
                  MEMADDR = {HaddrReg[27:2] , 2'b01};
               else if (trans_split_count ==2'b10)
                  MEMADDR = {HaddrReg[27:2] , 2'b10};
               else if (trans_split_count ==2'b11)
                  MEMADDR = {HaddrReg[27:2] , 2'b11};
            end else if(HsizeReg == `SZ_HALF) begin
               if (trans_split_count[0] ==1'b0)
                  MEMADDR = {HaddrReg[27:1] , 1'b0};
               else if (trans_split_count[0] ==1'b1)
                  MEMADDR = {HaddrReg[27:1] , 1'b1};
            end else begin 
                  MEMADDR = HaddrReg[27:0];
            end
         end else begin
             MEMADDR = {2'b00, HaddrReg[27:2]};
         end
      end else begin // SRAM access
         if (SelHaddrReg) begin
            if (SRAM_16BIT == 1'b1 ) begin
               if (HsizeReg == `SZ_WORD) begin
                  if (trans_split_count[0] ==1'b0)
                     MEMADDR = {1'b0, HaddrReg[27:2],1'b0};
                  else
                        MEMADDR = {1'b0, HaddrReg[27:2],1'b1};
               end else begin
                     MEMADDR = {1'b0, HaddrReg[27:1]};
               end
            end else if(SRAM_8BIT ==1'b1) begin
               if (HsizeReg == `SZ_WORD) begin
                  if (trans_split_count ==2'b00)
                     MEMADDR = {HaddrReg[27:2] , 2'b00};
                  else if (trans_split_count ==2'b01)
                     MEMADDR = {HaddrReg[27:2] , 2'b01};
                  else if (trans_split_count ==2'b10)
                     MEMADDR = {HaddrReg[27:2] , 2'b10};
                  else if (trans_split_count ==2'b11)
                     MEMADDR = {HaddrReg[27:2] , 2'b11};
               end else if(HsizeReg == `SZ_HALF) begin
                  if (trans_split_count[0] ==1'b0)
                     MEMADDR = {HaddrReg[27:1] , 1'b0};
                  else if (trans_split_count[0] ==1'b1)
                     MEMADDR = {HaddrReg[27:1] , 1'b1};
               end else begin //if(HsizeReg == `SZ_BYTE) begin
                  MEMADDR = HaddrReg[27:0];
               end
            end else begin
               MEMADDR = {2'b00, HaddrReg[27:2]};
            end
         end else begin
            MEMADDR = {2'b00, HADDR[27:2]};
         end
      end
   end
end
else begin
   always @(*) begin
      if (!iFLASHCSN) begin // Flash access
         if (FLASH_DQ_SIZE == 16) begin
            if (FLASH_TYPE == 0) begin
               if (HsizeReg == `SZ_WORD) begin
                  if (trans_split_count[0] == 1'b0) begin
                     MEMADDR = { 1'b0, HaddrReg[27:2], 1'b0};
                  end else begin
                     MEMADDR = { 1'b0, HaddrReg[27:2], 1'b1};
                  end
               end else begin
                  MEMADDR = { 1'b0, HaddrReg[27:1]};
               end
            end else begin
               if (HsizeReg == `SZ_WORD) begin
                  if (trans_split_count[0] == 1'b0) begin
                     MEMADDR = { HaddrReg[27:2], 1'b0,1'b0};
                  end else begin
                     MEMADDR = { HaddrReg[27:2], 1'b1,1'b0};
                  end
               end else begin
                  MEMADDR = { HaddrReg[27:1],1'b0};
               end
            end
         end else if (FLASH_DQ_SIZE == 8) begin
            if (HsizeReg == `SZ_WORD) begin
               if (trans_split_count == 2'b00)
                  MEMADDR = {HaddrReg[27:2] , 2'b00};
               else if (trans_split_count ==2'b01)
                  MEMADDR = {HaddrReg[27:2] , 2'b01};
               else if (trans_split_count ==2'b10)
                  MEMADDR = {HaddrReg[27:2] , 2'b10};
               else if (trans_split_count ==2'b11)
                  MEMADDR = {HaddrReg[27:2] , 2'b11};
            end else if(HsizeReg == `SZ_HALF) begin
               if (trans_split_count[0] ==1'b0)
                  MEMADDR = {HaddrReg[27:1] , 1'b0};
               else if (trans_split_count[0] ==1'b1)
                  MEMADDR = {HaddrReg[27:1] , 1'b1};
            end else begin 
                  MEMADDR = HaddrReg[27:0];
            end
         end else begin
             MEMADDR = {2'b00, HaddrReg[27:2]};
         end
      end else begin // SRAM access
         if (SelHaddrReg) begin
            if (SRAM_16BIT == 1'b1 ) begin
               if (HsizeReg == `SZ_WORD) begin
                  if (ssram_split_trans_next[0] ==1'b1)
                     MEMADDR = {1'b0, HaddrReg[27:2],1'b0};
                  else
                     MEMADDR = {1'b0, HaddrReg[27:2],1'b1};
               end else begin
                  MEMADDR = {1'b0, HaddrReg[27:1]};
               end
            end else if(SRAM_8BIT ==1'b1) begin
               if (HsizeReg == `SZ_WORD) begin
                  if (ssram_split_trans_next ==2'b11)
                     MEMADDR = {HaddrReg[27:2] , 2'b00};
                  else if (ssram_split_trans_next ==2'b10)
                     MEMADDR = {HaddrReg[27:2] , 2'b01};
                  else if (ssram_split_trans_next ==2'b01)
                     MEMADDR = {HaddrReg[27:2] , 2'b10};
                  else if (ssram_split_trans_next ==2'b00)
                     MEMADDR = {HaddrReg[27:2] , 2'b11};
               end else if(HsizeReg == `SZ_HALF) begin
                  if (ssram_split_trans_next[0] ==1'b1)
                     MEMADDR = {HaddrReg[27:1] , 1'b0};
                  else if (ssram_split_trans_next[0] ==1'b0)
                     MEMADDR = {HaddrReg[27:1] , 1'b1};
               end else begin
                  MEMADDR = HaddrReg[27:0];
               end
            end else begin
               MEMADDR = {2'b00, HaddrReg[27:2]};
            end
         end else begin
            MEMADDR = {2'b00, HADDR[27:2]};
         end
      end
   end

end
endgenerate


 generate
    if  (NUM_MEMORY_CHIP ==1) begin
       assign iSRAMCSN_s =iSRAMCSN;
    end
 endgenerate

 generate
    if  (NUM_MEMORY_CHIP ==2) begin
       assign iSRAMCSN_s =iSRAMCSN[1] & iSRAMCSN[0];
    end
 endgenerate

 generate
    if  (NUM_MEMORY_CHIP ==3) begin
       assign iSRAMCSN_s =iSRAMCSN[2] & iSRAMCSN[1] & iSRAMCSN[0] ;
    end
 endgenerate

 generate
    if  (NUM_MEMORY_CHIP ==4) begin
       assign iSRAMCSN_s =iSRAMCSN[3] & iSRAMCSN[2] & iSRAMCSN[1] & iSRAMCSN[0] ;
    end
 endgenerate

    //------------------------------------------------------------------------------
    // Byte enables for RAM
    //------------------------------------------------------------------------------

generate if(DQ_SIZE_SRAM ==32) begin
   always @ ( * ) begin
      if ( iSRAMCSN_s == 1'b0 ) begin
         case ( HsizeReg )
         `SZ_BYTE:
            if(SRAM_16BIT == 1'b1) begin
               case ( HaddrReg[1:0] )
               2'b00:  SRAMBYTEN = `BYTE0;
               2'b01:  SRAMBYTEN = `BYTE1;
               2'b10:  SRAMBYTEN = `BYTE0;
               2'b11:  SRAMBYTEN = `BYTE1;
               endcase
            end else if(SRAM_8BIT == 1'b1) begin
               SRAMBYTEN = `BYTE0;
            end else begin
               case ( HaddrReg[1:0] )
               2'b00:  SRAMBYTEN = `BYTE0;
               2'b01:  SRAMBYTEN = `BYTE1;
               2'b10:  SRAMBYTEN = `BYTE2;
               2'b11:  SRAMBYTEN = `BYTE3;
               endcase
            end
         `SZ_HALF:
            if(SRAM_16BIT == 1'b1) begin
               SRAMBYTEN = `HALF0;
            end else if (SRAM_8BIT ==1 ) begin
               SRAMBYTEN = `BYTE0;
            end else begin
               case ( HaddrReg[1] )
               1'b0:   SRAMBYTEN = `HALF0;
               1'b1:   SRAMBYTEN = `HALF1;
               endcase
            end
         `SZ_WORD:
            SRAMBYTEN = `WORD;
         default:
            SRAMBYTEN = `NONE;
         endcase
      end else begin
         SRAMBYTEN = `NONE;
      end
   end
end
endgenerate

generate if(DQ_SIZE_SRAM ==16) begin
   always @ ( * ) begin
      if ( iSRAMCSN_s == 1'b0 ) begin
         case ( HsizeReg )
         `SZ_BYTE:
            if(SRAM_16BIT == 1'b1) begin
               case ( HaddrReg[1:0] )
               2'b00:  SRAMBYTEN = 2'b10;
               2'b01:  SRAMBYTEN = 2'b01;
               2'b10:  SRAMBYTEN = 2'b10;
               2'b11:  SRAMBYTEN = 2'b01;
               endcase
            end else  begin //if(SRAM_8BIT == 1'b1) begin
               SRAMBYTEN = 2'b10;
            end
         `SZ_HALF:
            if(SRAM_16BIT == 1'b1) begin
               SRAMBYTEN = 2'b00;
            end else begin // if (SRAM_8BIT ==1 ) begin
               SRAMBYTEN = 2'b10;
            end
         `SZ_WORD:
            SRAMBYTEN = 2'b00;
         default:
            SRAMBYTEN = 2'b11;
         endcase
      end else begin
         SRAMBYTEN = 2'b11;
      end
   end
end
endgenerate

generate if(DQ_SIZE_SRAM ==8) begin
   always @ ( * ) begin
      if ( iSRAMCSN_s == 1'b0 ) begin
         case ( HsizeReg )
         `SZ_BYTE:
            begin
               SRAMBYTEN = 1'b0;
            end
         `SZ_HALF:
            begin 
               SRAMBYTEN = 1'b0;
            end
         `SZ_WORD:
            SRAMBYTEN = 1'b0;
         default:
            SRAMBYTEN = 1'b1;
         endcase
      end else begin
         SRAMBYTEN = 1'b1;
      end
   end
end
endgenerate

    //------------------------------------------------------------------------------
    // Output AHB read data bus generation.
    //------------------------------------------------------------------------------
    // Register lower half of MEMDATAIn to facilitate word reads when using 16-bit
    // flash.

//////////////////////////////////DQ_SIZE==8///////////////////////////////////////////
generate if(DQ_SIZE ==8 && SYNC_SRAM == 1 ) begin
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn))
         MEMDATAInReg[31:0]   <= 32'd0;
      else begin
         if(SRAM_8BIT &&  iFLASHCSN != 1'b0 ) begin
            if ( pipeline_rd_d2 == 1'b1 && FLOW_THROUGH == 0) begin
               MEMDATAInReg[31:0] <= {MEMDATAIn [7:0] ,MEMDATAInReg[31:8]};
            end else if ( CurrentWait == `ONE && (&iSRAMCSN) == 0  && FLOW_THROUGH == 1) begin
               MEMDATAInReg[31:0] <= {MEMDATAIn [7:0] ,MEMDATAInReg[31:8]};
            end
         end else if(iFLASHCSN == 1'b0) begin
            if ( CurrentWait == `ZERO ) begin
               MEMDATAInReg[31:0] <= {MEMDATAIn [7:0] ,MEMDATAInReg[31:8]};
            end
         end
      end
   end
end 
endgenerate
   
generate if (DQ_SIZE ==8 && SYNC_SRAM == 0 ) begin
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn))
         MEMDATAInReg[31:0]   <= 32'd0;
      else begin
         if ( CurrentWait == `ZERO ) begin
            MEMDATAInReg[31:0] <= {MEMDATAIn [7:0] ,MEMDATAInReg[31:8]};
         end
      end
   end
end
endgenerate

generate if(DQ_SIZE ==8 ) begin
   always @ ( * ) begin
      case ( HsizeReg )
         `SZ_BYTE: 
         begin
            if(SYNC_SRAM == 1 && iFLASHCSN == 1'b1)
               iHRDATA = { MEMDATAInReg[31:24],   MEMDATAInReg[31:24],   MEMDATAInReg[31:24],   MEMDATAInReg[31:24]   };
            else
               iHRDATA = { MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0]   };
         end
         `SZ_HALF:
         begin
            if(SYNC_SRAM == 1 && iFLASHCSN == 1'b1) begin
                  case ( HaddrReg[1] )
                  1'b0:  iHRDATA = { 16'd0,MEMDATAInReg[31:16] };
                  1'b1:  iHRDATA = { MEMDATAInReg[31:16],16'd0 };
                  endcase
            end else begin
                  case ( HaddrReg[1] )
                  1'b0:  iHRDATA = { 16'd0,MEMDATAIn[7:0] ,MEMDATAInReg[31:24] };
                  1'b1:  iHRDATA = { MEMDATAIn[7:0] ,MEMDATAInReg[31:24],16'd0 };
                  endcase
            end
         end
         `SZ_WORD:
            if(HselFlashReg ==1'b1 || SYNC_SRAM == 0 )
               iHRDATA = { MEMDATAIn[7:0] ,MEMDATAInReg[31:8] };
            else 
               iHRDATA = { MEMDATAInReg[31:0] };
         default:
            iHRDATA = {MEMDATAIn[7:0] , MEMDATAIn[7:0] , MEMDATAIn[7:0] , MEMDATAIn[7:0]};
         endcase
   end
end
endgenerate

//////////////////////////////////DQ_SIZE==16///////////////////////////////////////////

generate if(DQ_SIZE ==16 && SYNC_SRAM == 1 ) begin 
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn)) begin
         MEMDATAInReg[31:0]   <= 32'd0;
      end else if (wr_follow_rd_next ==1'b1)begin
         MEMDATAInReg[31:0]   <= 32'd0;
      end else begin
         if(SRAM_8BIT | (FLASH_DQ_SIZE == 8 &&  iFLASHCSN == 1'b0) ) begin
           if ((CurrentWait == `ONE && FLOW_THROUGH == 1 && (&iSRAMCSN) == 0 )) begin
              MEMDATAInReg[31:0] <= {MEMDATAIn [7:0] ,MEMDATAInReg[31:8]};
           end else if ((pipeline_rd_d2 == 1'b1 && FLOW_THROUGH == 0 && (&iSRAMCSN) == 0 )) begin
              MEMDATAInReg[31:0] <= {MEMDATAIn [7:0] ,MEMDATAInReg[31:8]};
           end else if ((CurrentWait == `ZERO && ( iFLASHCSN ==1'b0 ))) begin
               MEMDATAInReg[31:0] <= {MEMDATAIn [7:0] ,MEMDATAInReg[31:8]};
           end 
         end else begin
            if (FLOW_THROUGH == 1)begin
               if ((CurrentWait == `ONE && ((&iSRAMCSN) == 0 )) || (CurrentWait == `ZERO && ( iFLASHCSN ==1'b0 ))) begin
                  MEMDATAInReg <= { MEMDATAIn[15:0], MEMDATAInReg[31:16]};
               end
            end else begin
               if ((pipeline_rd_d2 == 1'b1 && ((&iSRAMCSN) == 0 )) || (CurrentWait == `ZERO && ( iFLASHCSN ==1'b0 ))) begin
                  MEMDATAInReg <= { MEMDATAIn[15:0], MEMDATAInReg[31:16]};
               end
            end
         end
      end
   end
end
endgenerate

generate if(DQ_SIZE ==16 && SYNC_SRAM == 0) begin 
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn)) begin
         MEMDATAInReg[31:0]   <= 32'd0;
      end else if (wr_follow_rd_next ==1'b1)begin
         MEMDATAInReg[31:0]   <= 32'd0;
      end else begin
         if(SRAM_8BIT | (FLASH_DQ_SIZE == 8 &&  iFLASHCSN == 1'b0) ) begin
            if ( CurrentWait == `ZERO ) begin
               MEMDATAInReg[31:0] <= {MEMDATAIn [7:0] ,MEMDATAInReg[31:8]};
            end
         end else begin
            if ( CurrentWait == `ZERO && ( iFLASHCSN ==1'b0 || (&iSRAMCSN) == 0 )) begin
               MEMDATAInReg <= { MEMDATAIn[15:0], MEMDATAInReg[31:16]};
            end
         end
      end
   end
end
endgenerate

generate if(DQ_SIZE ==16) begin
   always @ ( * ) begin
      if ( iFLASHCSN == 1'b0 && FLASH_DQ_SIZE == 16 )  begin // Reading 16-bit Flash
         case ( HsizeReg )
         `SZ_BYTE:
            case ( HaddrReg[0] )
            1'b0: iHRDATA = { MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0]   };
            1'b1: iHRDATA = { MEMDATAIn[15:8],  MEMDATAIn[15:8],  MEMDATAIn[15:8],  MEMDATAIn[15:8]  };
            endcase
         `SZ_HALF:
            iHRDATA = { MEMDATAIn[15:0],  MEMDATAIn[15:0] };
         `SZ_WORD:
            iHRDATA = { MEMDATAIn[15:0],  MEMDATAInReg[31:16] };
         default:
            iHRDATA = { MEMDATAIn[15:0],  MEMDATAIn[15:0] };
         endcase
      end else if ( iFLASHCSN == 1'b0 && FLASH_DQ_SIZE == 8 )  begin // Reading 16-bit Flash
          case ( HsizeReg )
         `SZ_BYTE:
            iHRDATA = { MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0]   };
         `SZ_HALF:
            case ( HaddrReg[1] )
               1'b0:  iHRDATA = { 16'd0,MEMDATAIn[7:0] ,MEMDATAInReg[31:24] };
               1'b1:  iHRDATA = { MEMDATAIn[7:0] ,MEMDATAInReg[31:24],16'd0 };
               endcase
         `SZ_WORD:
            iHRDATA = { MEMDATAIn[7:0] ,MEMDATAInReg[31:8] };
         default:
            iHRDATA = { MEMDATAIn[15:0],  MEMDATAIn[15:0] };
         endcase
      end else begin
         case ( HsizeReg )
         `SZ_BYTE:
            if(SRAM_8BIT ) begin
               if(SYNC_SRAM) begin
                  iHRDATA = { MEMDATAInReg[31:24],   MEMDATAInReg[31:24],   MEMDATAInReg[31:24],   MEMDATAInReg[31:24]   };
               end else begin
                  iHRDATA = { MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0]   };
               end
            end else begin
               if(SYNC_SRAM) begin
                  case ( HaddrReg[0] )
                     1'b0: iHRDATA = { MEMDATAInReg[23:16],   MEMDATAInReg[23:16],   MEMDATAInReg[23:16],   MEMDATAInReg[23:16]   };
                     1'b1: iHRDATA = { MEMDATAInReg[31:24],  MEMDATAInReg[31:24],  MEMDATAInReg[31:24],  MEMDATAInReg[31:24]  };
                  endcase
               end else begin
                  case ( HaddrReg[0] )
                     1'b0: iHRDATA = { MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0]   };
                     1'b1: iHRDATA = { MEMDATAIn[15:8],  MEMDATAIn[15:8],  MEMDATAIn[15:8],  MEMDATAIn[15:8]  };
                  endcase
               end
            end
         `SZ_HALF:
            if(SRAM_8BIT) begin
               if(SYNC_SRAM) begin
                  case ( HaddrReg[1] )
                  1'b0:  iHRDATA = { 16'd0,MEMDATAInReg[31:16] };
                  1'b1:  iHRDATA = { MEMDATAInReg[31:16],16'd0 };
                  endcase
               end else begin
                  case ( HaddrReg[1] )
                  1'b0:  iHRDATA = { 16'd0,MEMDATAIn[7:0] ,MEMDATAInReg[31:24] };
                  1'b1:  iHRDATA = { MEMDATAIn[7:0] ,MEMDATAInReg[31:24],16'd0 };
                  endcase
               end
            end else begin 
               if(SYNC_SRAM) begin
                  iHRDATA = { MEMDATAInReg[31:16] ,MEMDATAInReg[31:16] };
               end else begin 
                  iHRDATA = { MEMDATAIn[15:0] ,MEMDATAIn[15:0] };
               end
            end
         `SZ_WORD:
             if(SYNC_SRAM == 0) begin	 
                if(SRAM_8BIT)
                   iHRDATA = { MEMDATAIn[7:0] ,MEMDATAInReg[31:8] };
                else 
                   iHRDATA = { MEMDATAIn[15:0],  MEMDATAInReg[31:16] };
             end else begin
                if(SRAM_8BIT)
                   iHRDATA = { MEMDATAInReg[31:0] };
                else if (SRAM_16BIT) 
                   iHRDATA = { MEMDATAInReg[31:0] };
                else
                   iHRDATA = { MEMDATAIn[15:0],  MEMDATAInReg[31:16] };
             end
         default:
            iHRDATA = {MEMDATAIn[15:0] , MEMDATAIn[15:0]};
         endcase
      end
   end

end
endgenerate

generate if( FLASH_DQ_SIZE ==16 | FLASH_DQ_SIZE ==32 ) begin
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn))
         MEMDATA_rd_flash[31:0]   <= 32'd0;
      else begin
         if ( CurrentWait == `ZERO  & wr_follow_rd_next ) begin
            if(FLASH_DQ_SIZE ==32)
               MEMDATA_rd_flash <= MEMDATAIn;
            else
               MEMDATA_rd_flash <= { MEMDATAIn , MEMDATAIn};
         end
      end
   end
end
endgenerate

//////////////////////////////////DQ_SIZE==32///////////////////////////////////////////
generate if(DQ_SIZE ==32 && SYNC_SRAM == 1 ) begin
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn)) begin
         MEMDATAInReg[31:0]   <= 32'd0;
      end else if (wr_follow_rd_next ==1'b1)begin
         MEMDATAInReg[31:0]   <= 32'd0;
      end else begin
         if(FLASH_DQ_SIZE == 8 && (iFLASHCSN ==1'b0)) begin
           if (CurrentWait == `ZERO ) begin
               MEMDATAInReg <= { MEMDATAIn[7:0], MEMDATAInReg[31:8]};
           end
         end else if(SRAM_8BIT && ((&iSRAMCSN) == 0)) begin
           if (CurrentWait == `ONE && FLOW_THROUGH == 1 ) begin
                MEMDATAInReg[31:0] <= {MEMDATAIn [7:0] ,MEMDATAInReg[31:8]};
           end else if  (pipeline_rd_d2 == 1'b1 && FLOW_THROUGH == 0) begin
                MEMDATAInReg[31:0] <= {MEMDATAIn [7:0] ,MEMDATAInReg[31:8]};
           end 
         end else if(FLASH_DQ_SIZE == 16 &&  iFLASHCSN == 1'b0) begin
            if ( CurrentWait == `ZERO ) begin
               MEMDATAInReg <= { MEMDATAIn[15:0], MEMDATAInReg[31:16]};
            end
         end else begin
            if(SRAM_16BIT ) begin
               if(FLOW_THROUGH == 1) begin
                  if ((CurrentWait == `ONE && ((&iSRAMCSN) == 0 )) || (CurrentWait == `ZERO && ( iFLASHCSN ==1'b0 ))) begin
                     MEMDATAInReg <= { MEMDATAIn[15:0], MEMDATAInReg[31:16]};
                  end
               end else begin
                  if ((pipeline_rd_d2 ==1'b1 && ((&iSRAMCSN) == 0 )) || (CurrentWait == `ZERO && ( iFLASHCSN ==1'b0 ))) begin
                     MEMDATAInReg <= { MEMDATAIn[15:0], MEMDATAInReg[31:16]};
                  end
               end
            end else begin
               if(FLOW_THROUGH==1)begin
                  if (CurrentWait == `ONE && ((&iSRAMCSN) == 0 ))begin
                     MEMDATAInReg <= MEMDATAIn[31:0];
                  end
               end else begin
                  if (pipeline_rd_d2 == 1'b1 && ((&iSRAMCSN) == 0 ))begin
                     MEMDATAInReg <= MEMDATAIn[31:0];
                  end
               end 
            end 
         end
      end
   end
end
endgenerate


generate if(DQ_SIZE ==32 && SYNC_SRAM == 0) begin
   always @ (posedge HCLK or negedge aresetn) begin
      if ((!aresetn) || (!sresetn)) begin
         MEMDATAInReg[31:0]   <= 32'd0;
      end else if (wr_follow_rd_next ==1'b1)begin
         MEMDATAInReg[31:0]   <= 32'd0;
      end else begin
         if(SRAM_8BIT | (FLASH_DQ_SIZE == 8 &&  iFLASHCSN == 1'b0)) begin
            if ( CurrentWait == `ZERO ) begin
               MEMDATAInReg[31:0] <= {MEMDATAIn [7:0] ,MEMDATAInReg[31:8]};
            end
         end else begin
            if ( CurrentWait == `ZERO) begin
               MEMDATAInReg <= { MEMDATAIn[15:0], MEMDATAInReg[31:16]};
            end
         end
      end
   end
end
endgenerate

generate if(DQ_SIZE ==32) begin
   always @ ( * ) begin
      if ( iFLASHCSN == 1'b0 && FLASH_DQ_SIZE == 16 )  begin // Reading 16-bit Flash
         case ( HsizeReg )
         `SZ_BYTE:
            case ( HaddrReg[0] )
            1'b0: iHRDATA = { MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0]   };
            1'b1: iHRDATA = { MEMDATAIn[15:8],  MEMDATAIn[15:8],  MEMDATAIn[15:8],  MEMDATAIn[15:8]  };
            endcase
         `SZ_HALF:
            iHRDATA = { MEMDATAIn[15:0],  MEMDATAIn[15:0] };
         `SZ_WORD:
            iHRDATA = { MEMDATAIn[15:0],  MEMDATAInReg[31:16] };
         default:
            iHRDATA = { MEMDATAIn[15:0],  MEMDATAIn[15:0] };
         endcase
      end else if ( iFLASHCSN == 1'b0 && FLASH_DQ_SIZE == 8 )  begin // Reading 8-bit Flash
         case ( HsizeReg )
         `SZ_BYTE:
            iHRDATA = { MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0]   };
         `SZ_HALF:
            case ( HaddrReg[1] )
               1'b0:  iHRDATA = { 16'd0,MEMDATAIn[7:0] ,MEMDATAInReg[31:24] };
               1'b1:  iHRDATA = { MEMDATAIn[7:0] ,MEMDATAInReg[31:24],16'd0 };
            endcase
         `SZ_WORD:
            iHRDATA = { MEMDATAIn[7:0] ,MEMDATAInReg[31:8] };
         default:
            iHRDATA = { MEMDATAIn[15:0],  MEMDATAIn[15:0] };
         endcase
      end else if ( iFLASHCSN == 1'b0 && FLASH_DQ_SIZE == 32 )  begin // Reading 8-bit Flash
         case ( HsizeReg )
         `SZ_BYTE:
          case ( HaddrReg[1:0] )
               2'b00: iHRDATA = { 24'd0,   MEMDATAIn[7:0]          };
               2'b01: iHRDATA = { 16'd0,   MEMDATAIn[15:8] , 8'd0  };
               2'b10: iHRDATA = { 8'd0 ,   MEMDATAIn[23:16], 16'd0 };
               2'b11: iHRDATA = { MEMDATAIn[31:24]         , 24'd0 };
             endcase
         `SZ_HALF:
            case ( HaddrReg[1] )
               1'b0:  iHRDATA = { 16'd0,MEMDATAIn[15:0]};
               1'b1:  iHRDATA = { MEMDATAIn[31:16] ,16'd0 };
            endcase
         `SZ_WORD:
             iHRDATA = MEMDATAIn[31:0];
         default:
             iHRDATA = MEMDATAIn[31:0];
         endcase

      end else begin
         case ( HsizeReg )
         `SZ_BYTE:
            if(SRAM_8BIT) begin
               if(SYNC_SRAM) begin
                  iHRDATA = { MEMDATAInReg[31:24],   MEMDATAInReg[31:24],   MEMDATAInReg[31:24],   MEMDATAInReg[31:24]   };
               end else begin
                  iHRDATA = { MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0]   };
               end
            end else if (SRAM_16BIT)  begin
               if(SYNC_SRAM) begin
                  case ( HaddrReg[0] )
                     1'b0: iHRDATA = { MEMDATAInReg[23:16],   MEMDATAInReg[23:16],   MEMDATAInReg[23:16],   MEMDATAInReg[23:16]   };
                     1'b1: iHRDATA = { MEMDATAInReg[31:24],  MEMDATAInReg[31:24],  MEMDATAInReg[31:24],  MEMDATAInReg[31:24]  };
                  endcase
               end else begin
                  case ( HaddrReg[0] )
                     1'b0: iHRDATA = { MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0]   };
                     1'b1: iHRDATA = { MEMDATAIn[15:8],  MEMDATAIn[15:8],  MEMDATAIn[15:8],  MEMDATAIn[15:8]  };
                  endcase
               end
            end else begin
               if(SYNC_SRAM) begin
                  case ( HaddrReg[1:0] )
                     2'b00: iHRDATA = { MEMDATAInReg[7:0],   MEMDATAInReg[7:0],   MEMDATAInReg[7:0],   MEMDATAInReg[7:0]   };
                     2'b01: iHRDATA = { MEMDATAInReg[15:8],  MEMDATAInReg[15:8],  MEMDATAInReg[15:8],  MEMDATAInReg[15:8]  };
                     2'b10: iHRDATA = { MEMDATAInReg[23:16], MEMDATAInReg[23:16], MEMDATAInReg[23:16], MEMDATAInReg[23:16] };
                     2'b11: iHRDATA = { MEMDATAInReg[31:24], MEMDATAInReg[31:24], MEMDATAInReg[31:24], MEMDATAInReg[31:24] };
                  endcase
               end else begin
                  case ( HaddrReg[1:0] )
                     2'b00: iHRDATA = { MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0],   MEMDATAIn[7:0]   };
                     2'b01: iHRDATA = { MEMDATAIn[15:8],  MEMDATAIn[15:8],  MEMDATAIn[15:8],  MEMDATAIn[15:8]  };
                     2'b10: iHRDATA = { MEMDATAIn[23:16], MEMDATAIn[23:16], MEMDATAIn[23:16], MEMDATAIn[23:16] };
                     2'b11: iHRDATA = { MEMDATAIn[31:24], MEMDATAIn[31:24], MEMDATAIn[31:24], MEMDATAIn[31:24] };
                  endcase
               end
            end
         `SZ_HALF:
            if(SRAM_8BIT) begin
               if(SYNC_SRAM) begin
                  case ( HaddrReg[1] )
                  1'b0:  iHRDATA = { 16'd0,MEMDATAInReg[31:16] };
                  1'b1:  iHRDATA = { MEMDATAInReg[31:16],16'd0 };
                  endcase
               end else begin
                  case ( HaddrReg[1] )
                  1'b0:  iHRDATA = { 16'd0,MEMDATAIn[7:0] ,MEMDATAInReg[31:24] };
                  1'b1:  iHRDATA = { MEMDATAIn[7:0] ,MEMDATAInReg[31:24],16'd0 };
                  endcase
               end
            end else if (SRAM_16BIT)  begin
               if(SYNC_SRAM) begin
                  iHRDATA = { MEMDATAInReg[31:16] ,MEMDATAInReg[31:16] };
       	       end else begin
                  iHRDATA = { MEMDATAIn[15:0] ,MEMDATAIn[15:0] };
               end
            end else begin
               if(SYNC_SRAM) begin
                  case ( HaddrReg[1] )
                     1'b0:  iHRDATA = { MEMDATAInReg[15:0],  MEMDATAInReg[15:0]  };
                     1'b1:  iHRDATA = { MEMDATAInReg[31:16], MEMDATAInReg[31:16] };
                  endcase
               end else begin
                  case ( HaddrReg[1] )
                     1'b0:  iHRDATA = { MEMDATAIn[15:0],  MEMDATAIn[15:0]  };
                     1'b1:  iHRDATA = { MEMDATAIn[31:16], MEMDATAIn[31:16] };
                  endcase
               end
            end
         `SZ_WORD:
             if(SRAM_8BIT)
                if(SYNC_SRAM)   
                   iHRDATA = { MEMDATAInReg[31:0] };
                else
                   iHRDATA = { MEMDATAIn[7:0] ,MEMDATAInReg[31:8] };
             else if (SRAM_16BIT) 
                if(SYNC_SRAM)     
                   iHRDATA = { MEMDATAInReg[31:0] };
                else
                   iHRDATA = { MEMDATAIn[15:0],  MEMDATAInReg[31:16] };
             else
                if(SYNC_SRAM)     
                   iHRDATA = { MEMDATAInReg[31:0] };
                else
                   iHRDATA = MEMDATAIn[31:0];
         default:
            iHRDATA = MEMDATAIn[31:0];
         endcase
      end
   end

end
endgenerate

////////////////////////////////////////////////////////////////////////////////////
    //------------------------------------------------------------------------------
    // Read data back to AHB bus
    //------------------------------------------------------------------------------
   always @(*) begin
      if (Busy_d != 1'b1) begin
         HRDATA = iHRDATA;
      end else begin
         HRDATA = 32'b0;
      end
   end

    //------------------------------------------------------------------------------
    // Slave response
    //------------------------------------------------------------------------------
    // Output response to AHB bus is always OKAY
    assign HRESP = `RSP_OKAY;

endmodule





