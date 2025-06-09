module TAMPER ( 
  JTAG_ACTIVE,
  LOCK_TAMPER_DETECT,
  MESH_SHORT_ERROR,
  CLK_ERROR,
  DETECT_CATEGORY,
  DETECT_ATTEMPT,
  DETECT_FAIL,
  DIGEST_ERROR,
  POWERUP_DIGEST_ERROR,
  SC_ROM_DIGEST_ERROR,
  TAMPER_CHANGE_STROBE,
  LOCKDOWN_ALL_N,
  DISABLE_ALL_IOS_N,
  RESET_N,
  ZEROIZE_N );

/* synthesis syn_hier="hard" */ 
/* synthesis syn_black_box */ 
/* synthesis syn_noprune=1 */

output JTAG_ACTIVE;
output LOCK_TAMPER_DETECT;
output MESH_SHORT_ERROR;
output CLK_ERROR;
output [3:0] DETECT_CATEGORY;
output DETECT_ATTEMPT;
output DETECT_FAIL;
output DIGEST_ERROR;
output POWERUP_DIGEST_ERROR;
output SC_ROM_DIGEST_ERROR;
output TAMPER_CHANGE_STROBE;

input  LOCKDOWN_ALL_N;
input  DISABLE_ALL_IOS_N;
input  RESET_N;
input  ZEROIZE_N;

parameter ZEROIZE_CONFIG              = "";
parameter POWERUP_DIGEST_ERROR_CONFIG = "";
parameter CLK_ERROR_CONFIG            = 0;


endmodule

