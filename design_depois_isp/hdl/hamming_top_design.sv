`include "hamming_encoder.sv"
`include "hamming_decoder.sv"

module hamming_top_design(input logic [15:0] data_in_left,
                          output logic [15:0] data_out_left,
                          input logic [15:0] data_in_right,
                          output logic [15:0] data_out_right,
                          input logic sel);
  
 
  logic [15:0] decoder_output;
  logic [15:0] encoder_output;

  
  logic [3:0] parity;
  logic [3:0] final_verify_bit;
  
  hamming_encoder codificador(.data_in(data_in_left),.encoded_data(encoder_output),.parity_bits(parity));
  hamming_decoder decodificador (.encoded_data(data_in_right), .decoded_data(decoder_output),.verify_bit(final_verify_bit));
  
  assign data_out_right = sel ? encoder_output : data_in_left;
  assign data_out_left = sel ? decoder_output : data_in_right;
  
  
 
  
    
  
endmodule