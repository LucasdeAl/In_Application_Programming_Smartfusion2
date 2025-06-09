// **********************************************************************/
// Microsemi Corporation Proprietary and Confidential
// Copyright 2012, Microsemi Corp
// TRI (x3675), April 18, 2012 (original version)
// **********************************************************************/
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
// **********************************************************************/
//
// Description: LED logic for 1HZ
// **********************************************************************/
// History:
//
// TRI	(x3675), 18April2012	: Initial version.      
//
// *********************************************************************/

module led_blink (
    input clk,
    input resetN,
	
    output [3:0] o_LED
);

// Parameters
	/* NONE */

// internal wires
wire int_clk_1hz;
wire int_clk_sub_1hz; // Assumption is that fabric is running at 1MHz

// internal registers
reg [28:0] reg_counter;
reg [3:0] ring_counter;
reg [3:0] john_counter;

// assignments
assign int_clk_1hz = reg_counter[18];
assign int_clk_sub_1hz = reg_counter[20];
//assign o_LED = ~ring_counter;
assign o_LED = ~john_counter;


/* Counter to count till 1Hz on a 1MHz clock */
always @ (posedge clk, negedge resetN)
begin
	if (!resetN) begin
            reg_counter <= 'd0;
	end else begin
            reg_counter <= reg_counter + 1'b1;
	end
end // end always

/* Shift register for LED outputs */
always @ (posedge int_clk_1hz, negedge resetN)
begin
	if (!resetN) begin
           ring_counter <= 1;	// At power-up, all LEDs are ON
	end else begin
		ring_counter <= {ring_counter[2:0],ring_counter[3]};
	end
end // end always

always @ (posedge int_clk_sub_1hz, negedge resetN)
begin
	if (!resetN) begin
           john_counter <= 1;	// At power-up, all LEDs are ON
	end else begin
		john_counter <= {john_counter[2:0],~john_counter[3]};
	end
end // end always


endmodule


