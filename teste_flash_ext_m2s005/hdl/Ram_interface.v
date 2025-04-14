///////////////////////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//-- Title      : Two-Port  Large SRAM Interface
//-------------------------------------------------------------------------------
//-- File       : Ram_interface.v
//-- Author     : Corporate Applications Engineering
//-- Company    : Microsemi Corporation
//-- Device     : SmartFusion2
//-- Standard   : Verilog
//-------------------------------------------------------------------------------
//-- Description:  This FSM Logic performs  writes and reads  to  the  Two-Port  Large SRAM 
//-------------------------------------------------------------------------------
//-- Revisions  : V1.0
/////////////////////////////////////////////////////////////////////////////////////////////////// 
//`timescale <time_units> / <precision>

module Ram_intferface( 
        // Global Signals
        input CLK,
        input RESETn,

    //Active Low reset for the Tamper Macro
    output reg o_reset_n,

		
	// TPSRAM Interface
	output reg [5:0] o_TPSRAM_WADDR_sv,
	output reg [5:0] o_TPSRAM_RADDR_sv,
	output reg [7:0] o_TPSRAM_WD,
	output reg o_TPSRAM_WEN,
	output reg o_TPSRAM_REN,
	input [7:0] i_TPSRAM_RD_sv




);


/* TPSRAM WR and RD bk fsm */
parameter [2:0] ST_TPSRAM_INIT		= 0,
        ST_TPSRAM_DELAY     = 1,
		ST_TPSRAM_WR		= 2,
		ST_TPSRAM_IDLE		= 3,
		ST_TPSRAM_RDBK		= 4,
		ST_TPSRAM_RES_UPDATE	= 5
		;

reg [5:0] next_addr;
reg [7:0] next_data;
reg [7:0] expected_data;
reg [2:0] state_tpsram_access;
reg [15:0] counter;

reg tpsram_test_complete;
reg tpsram_pass;
wire flag_1ms;

//1ms Flag
assign flag_1ms = (counter == 16'h61A8) ? 1 : 0;
always @ (posedge CLK, negedge RESETn)
begin
    if(!RESETn) begin
	state_tpsram_access <= ST_TPSRAM_INIT;
	o_TPSRAM_REN <= 0;
	o_TPSRAM_WEN <= 0;
	o_TPSRAM_WD <= 0;
	o_TPSRAM_RADDR_sv <= 0;
	o_TPSRAM_WADDR_sv <= 0;

	next_addr <= 0;
	next_data <= 0;
	expected_data <= 0;
	
	tpsram_test_complete <= 1'b1;
	tpsram_pass <= 1'b1;
    o_reset_n            <= 1'b1;
    counter      <= 16'h0;
    end else begin
	case (state_tpsram_access)
	    ST_TPSRAM_INIT: begin
//		state_tpsram_access <= ST_TPSRAM_WR;
        state_tpsram_access <= ST_TPSRAM_DELAY;
		o_TPSRAM_REN <= 0;
		o_TPSRAM_WEN <= 0;
		o_TPSRAM_WD <= 0;
		o_TPSRAM_RADDR_sv <= 0;
		o_TPSRAM_WADDR_sv <= 0;
        o_reset_n            <= 1'b1;
		next_addr <= 0;
		next_data <= 0;
		expected_data <= 0;
	
		tpsram_test_complete <= 1'b1;
		tpsram_pass <= 1'b1;
	    end

	    ST_TPSRAM_DELAY: begin
        counter <= counter + 1'b1 ;
 		if(flag_1ms) begin
           state_tpsram_access <= ST_TPSRAM_WR;
		end     
	    end
	    ST_TPSRAM_WR: begin
        counter <= 16'h0;
		o_TPSRAM_WEN <= 1'b1;
		o_TPSRAM_WADDR_sv <= next_addr;
		o_TPSRAM_WD <= next_data;
		if(next_addr == 6'h3) begin
		    o_TPSRAM_WEN <= 1'b0;
		    next_addr <= 0;
		    state_tpsram_access <= ST_TPSRAM_IDLE;
		    o_TPSRAM_REN <= 1'b1;
		    o_TPSRAM_RADDR_sv <= 0;
		    expected_data <= 0;
		end else begin
		    next_addr <= next_addr + 1'b1;
		    next_data <= next_data + 1'b1;
		end
	    end
	    ST_TPSRAM_IDLE: begin
		state_tpsram_access <= ST_TPSRAM_RDBK;
		    next_addr <= next_addr + 1'b1;
		    o_TPSRAM_RADDR_sv <= next_addr + 1'b1;
	
	    end
	    ST_TPSRAM_RDBK: begin
		if(i_TPSRAM_RD_sv != expected_data) begin
		    tpsram_test_complete <= 1'b0;
		    tpsram_pass <= 1'b1;
            o_reset_n            <= 1'b0;
		    state_tpsram_access <= ST_TPSRAM_RES_UPDATE;
		end else begin
		    expected_data <= expected_data + 1'b1;
		end
		if(next_addr == 6'h3) begin
		    next_addr <= 0;
		    o_TPSRAM_REN <= 0;
		    tpsram_test_complete <= 1'b0;
		    tpsram_pass <= 1'b0;
		    state_tpsram_access <= ST_TPSRAM_RES_UPDATE;
		end else begin
		    next_addr <= next_addr + 1'b1;
		    o_TPSRAM_REN <= 1'b1;
		    o_TPSRAM_RADDR_sv <= next_addr + 1'b1;
		end
	    end
	    ST_TPSRAM_RES_UPDATE: begin
        state_tpsram_access <= ST_TPSRAM_RES_UPDATE;
	    end
	    default: begin
            o_reset_n            <= 1'b1;
	    end
	endcase
    end
end

endmodule

