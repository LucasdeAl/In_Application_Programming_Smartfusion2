#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "mss_uart.h"
#include "mss_sys_services.h"
#include "mss_spi.h"
#include "winbondflash.h"
#include <stdbool.h>
#define BUFFER_SIZE 2048

//*&************************************************************
uint8_t g_page_buffer[BUFFER_SIZE];
uint32_t page_read_handler(uint8_t const ** pp_next_page);
void isp_completion_handler(uint32_t value);
static uint32_t read_page_from_flash
(
    uint8_t * g_buffer,
    uint32_t length,//2048
    uint32_t *addr_flash
);
//dummy
void dummy_isp_completion_handler(uint32_t value);
uint32_t dummy_page_read_handler(uint8_t const ** pp_next_page);
volatile uint8_t g_isp_operation_busy = 1;
uint8_t dummy_g_page_buffer[20];
//volatile uint32_t bitstream_spi_addr = 0x0000000;
/*==============================================================================
  UART selection.

  mss_uart_instance_t * const gp_my_uart = &g_mss_uart1;
 */

mss_uart_instance_t * const gp_my_uart = &g_mss_uart0;
static uint32_t g_src_image_target_address = 0;
uint32_t g_bkup = 0;
uint8_t g_mode = 0;
static uint32_t g_file_size = 0;
uint32_t addr = 0;
uint32_t addr_bitstream = 0x10000;
//***********************************************************

void delay(volatile uint32_t n)
{
    while(n)
        n--;
}

size_t
UART_Polled_Rx
(
    mss_uart_instance_t * this_uart,
    uint8_t * rx_buff,
    size_t buff_size
)
{
    size_t rx_size = 0U;


    while( rx_size < buff_size )
    {
       while ( ((this_uart->hw_reg->LSR) & 0x1) != 0U  )
       {
           rx_buff[rx_size] = this_uart->hw_reg->RBR;
           ++rx_size;
       }
    }

    return rx_size;
}
static uint32_t read_page_from_host_through_uart
(
    uint8_t * g_buffer,
    uint32_t length
);

bool write_bitstream_on_flash
(
    uint8_t * g_buffer,
    uint32_t *addr_flash
);

int main()
{

    uint8_t rx_buff[8] ;
    bool status = true;
    uint8_t tamanho[4];

    MSS_UART_init( gp_my_uart,
            MSS_UART_57600_BAUD,
                  MSS_UART_DATA_8_BITS | MSS_UART_NO_PARITY | MSS_UART_ONE_STOP_BIT);


      MSS_SYS_init(MSS_SYS_NO_EVENT_HANDLER);

      //FLASH_init();
      //uint8_t rx_buffer[2049];
      //FLASH_read(0x20000, rx_buffer, 2049);

      /* start the handshake with the host */
      START_HANDSHAKE:
      g_isp_operation_busy = 1;
           while(!(UART_Polled_Rx ( gp_my_uart, rx_buff, 1 )))
              ;
           if(rx_buff[0] == 'h')
              MSS_UART_polled_tx( gp_my_uart, (const uint8_t * )"a", 1 );
           else
               goto START_HANDSHAKE;
           while(!(UART_Polled_Rx ( gp_my_uart, rx_buff, 1 )))
              ;
           if(rx_buff[0] == 'n')
              MSS_UART_polled_tx( gp_my_uart, (const uint8_t * )"d", 1 );
           while(!(UART_Polled_Rx (gp_my_uart, rx_buff, 1 )))
              ;
           if(rx_buff[0] == 's')
              MSS_UART_polled_tx( gp_my_uart, (const uint8_t * )"h", 1 );
           while(!(UART_Polled_Rx ( gp_my_uart, rx_buff, 1 )))
              ;
           if(rx_buff[0] == 'a')
              MSS_UART_polled_tx( gp_my_uart, (const uint8_t * )"k", 1 );
           while(!(UART_Polled_Rx ( gp_my_uart, rx_buff, 1 )))
              ;
           if(rx_buff[0] == 'e')
            {
               MSS_UART_polled_tx( gp_my_uart, (const uint8_t * )"r", 1 );
            }
           /* poll for starting Ack message from the host as an acknowledgment
                   that the host is ready to send file size */

           while(!(UART_Polled_Rx (gp_my_uart, rx_buff, 1 )));
           MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"a",1);
           /*poll for mode */
           MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"m",1);
           while(!(UART_Polled_Rx ( gp_my_uart, rx_buff, 1 )));

           g_mode  = rx_buff[0];
           /*poll for file size*/
           MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"z",1);
           while(!(UART_Polled_Rx ( gp_my_uart, rx_buff, 8 )))
                         ;
           g_file_size = atoi((const char*)rx_buff);

           MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"a",1);

           switch(g_mode){

           case '0':
               FLASH_init();
               FLASH_global_unprotect();
               FLASH_chip_erase();

               tamanho[0] = (uint8_t)(g_file_size & 0xFF);
               tamanho[1] = (uint8_t)((g_file_size >> 8) & 0xFF);
               tamanho[2] = (uint8_t)((g_file_size >> 16) & 0xFF);
               tamanho[3] = (uint8_t)((g_file_size >> 24) & 0xFF);

               FLASH_program(0, tamanho ,4);

               while((status = write_bitstream_on_flash(g_page_buffer, &addr_bitstream) == true));
               if (status == false)
               {
                   MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"q",1);
                   goto START_HANDSHAKE;
               }else
               {
                   MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"p",1);
                   goto START_HANDSHAKE;
               }
               break;

           case '1':
              //MSS_SYS_init(MSS_SYS_NO_EVENT_HANDLER);
              FLASH_init();
              //delay(80000);
              MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"c",1);
              //MSS_UART_polled_tx_string(gp_my_uart,(const uint8_t * )"\n\rSelect IAP Operation mode 1/2/3  1.Authenticate 2.Program 3.Verify\n\r");
              while(!(UART_Polled_Rx ( gp_my_uart, rx_buff, 1 )))
                  ;

              if(rx_buff[0] =='1')
              {

                  MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"m",1);
                  delay(80000);

                  //status=MSS_SYS_initiate_iap(MSS_SYS_PROG_AUTHENTICATE, bitstream_spi_addr);
                  status = MSS_SYS_start_isp(MSS_SYS_PROG_AUTHENTICATE,page_read_handler,isp_completion_handler);

                  while (g_isp_operation_busy == 1)
                  {
                      // Espera o ISP terminar
                  }

                  goto START_HANDSHAKE;



              }else if (rx_buff[0] =='2')

              {
                  MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"g",1);
                  delay(80000);

                  status = MSS_SYS_start_isp(MSS_SYS_PROG_PROGRAM,page_read_handler,isp_completion_handler);
                  while (g_isp_operation_busy == 1)
                  {
                      // Espera o ISP terminar
                  }

                  goto START_HANDSHAKE;

                  //copy_image_to_ram();
                  //remap_user_code_eSRAM_0();

              }
              else if (rx_buff[0] =='3')
              {

                  MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"k",1);
                  delay(100000);

                  status = MSS_SYS_start_isp(MSS_SYS_PROG_VERIFY,page_read_handler,isp_completion_handler);
                  while (g_isp_operation_busy == 1)
                  {
                      // Espera o ISP terminar
                  }

                  goto START_HANDSHAKE;
                  /*
                  p_addr_value_pair = g_m2s_serdes_0_config;
                  nb_of_cfg_pairs = SERDES_0_CFG_NB_OF_PAIRS;

                  for(inc = 0u; inc < nb_of_cfg_pairs; ++inc)
                  {
                      *p_addr_value_pair[inc].p_reg = p_addr_value_pair[inc].value;
                  }

                  if(status)
                  {
                      MSS_UART_polled_tx_string(gp_my_uart,(const uint8_t * )"IAP operation failed\n\r");

                  }
                  else
                  {
                      MSS_UART_polled_tx_string(gp_my_uart,(const uint8_t * )"IAP operation is successful\n\r");
                  }
                    */
              }
              else
              {
                  MSS_UART_polled_tx_string(gp_my_uart,(const uint8_t * )"Invalid option. Reset the board\n\r");
              }

              //while(1)
              //  {
              //
              //}
              break;
           }

}


void isp_completion_handler(uint32_t value)// usado so quando acaba o ISP
{
  if (value == MSS_SYS_SUCCESS)
  {

      MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"p",1);
      g_isp_operation_busy = 0;

  }
  else
  {
      MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"q",1);
      MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )&value,8);
      g_isp_operation_busy = 0;

  }
}

uint32_t page_read_handler
(
    uint8_t const ** pp_next_page
)
{
    uint32_t length;

    length = read_page_from_flash(g_page_buffer, BUFFER_SIZE,&addr);
    *pp_next_page = g_page_buffer;

    return length;
}


bool write_bitstream_on_flash
(
    uint8_t * g_buffer,
    uint32_t *addr_flash
)
{
   uint32_t length;
   uint8_t rx_buffer[BUFFER_SIZE+1];//o primeiro dado de retorno é dummy
   uint32_t remaining_bytes = g_file_size;
   bool status = true;
   while(remaining_bytes>0)
   {
       length = read_page_from_host_through_uart(g_page_buffer, BUFFER_SIZE);
       FLASH_program(*addr_flash, g_page_buffer, length);
       FLASH_read(*addr_flash, rx_buffer, length+1);
       for(int i=0;i<length;i++)
       {
           if(g_buffer[i] != rx_buffer[i+1])
           {
               //MSS_UART_polled_tx_string(gp_my_uart,(const uint8_t * )"\n\rFalha na gravacao da flash");
               MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"q",1);
               status = false;
               goto end;
           }
       }
       //MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )".",1);

       *addr_flash = *addr_flash + length;
       if((*addr_flash & 0xFFFF) > 0x7FF)
       {

           *addr_flash = *addr_flash + (1<<16);
           *addr_flash = *addr_flash & 0xFFFF07FF;
       }
       remaining_bytes = remaining_bytes - length;

   }
   //MSS_UART_polled_tx_string(gp_my_uart,(const uint8_t * )"\n\rGravacao da flash bem sucedida!!");
   end:
   return status;

}



static uint32_t read_page_from_flash
(
    uint8_t * g_buffer,
    uint32_t length,//2048
    uint32_t *addr_flash
)
{

       uint8_t tam[5];
       uint32_t num_bytes = length;
       uint32_t bytes_read = 0;
       uint32_t addr_corrigido;
       uint8_t buffer_interno[BUFFER_SIZE+1];

    if(*addr_flash == 0)
    {
        FLASH_read(*addr_flash, tam,5);
        g_file_size = ((tam[4]<<24)|(tam[3]<<16)|(tam[2]<<8)|tam[1]);

    }

    addr_corrigido = (((*addr_flash) & 0xffff0000)>>5)|((*addr_flash) & 0x7ff);

    if(addr_corrigido + length > g_file_size )
    {
        num_bytes = g_file_size - addr_corrigido;
    }
    if(addr_corrigido>= g_file_size)
    {
        return 0;
    }


    FLASH_read(*addr_flash + addr_bitstream, buffer_interno, num_bytes+1);

    for(int i=0;i<BUFFER_SIZE;i++)
        g_buffer[i] = buffer_interno[i+1];


    *addr_flash = *addr_flash + num_bytes;
     if((*addr_flash & 0xFFFF) > 0x7FF)
     {
         *addr_flash = *addr_flash + (1<<16);
         *addr_flash = *addr_flash & 0xFFFF07FF;
     }

     bytes_read = num_bytes;
     MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )".",1);
     return bytes_read;
}

static uint32_t read_page_from_host_through_uart
(
    uint8_t * g_buffer,
    uint32_t length
)
{
    uint32_t num_bytes,factor,temp;

    num_bytes = length;
    char crc;
    size_t rx_size = 0;
    uint8_t rx_buff[1];
    //Write Ack "b" to indicate beginning of the transaction from the target
        if(g_bkup != g_src_image_target_address)
        {
            if(g_src_image_target_address == 0)
                g_src_image_target_address = g_bkup;
        }
        if(g_src_image_target_address + length > g_file_size )
       {
            num_bytes = g_file_size - g_src_image_target_address;
       }
        if(g_src_image_target_address>= g_file_size)
        {
            return 0;
        }
        CRCFAIL:
           MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"b",1);
           //poll for Ack message from the host as an acknowledgment that the host is ready for receiving the transaction
           while(!(UART_Polled_Rx ( gp_my_uart, rx_buff, 1 )))
            ;
           //transmit the address to the host
           temp = g_src_image_target_address/8;
           if(rx_buff[0]== 'a')
           MSS_UART_polled_tx( gp_my_uart,(const uint8_t * )&temp, 8 );
           //poll for Ack message from the host as an acknowledgment that the host received the address
           while(!(UART_Polled_Rx ( gp_my_uart, rx_buff, 1 )))
            ;
           //transmit the returnbytes to the host
           if(rx_buff[0]== 'a')
           MSS_UART_polled_tx( gp_my_uart,(const uint8_t * )&num_bytes, 4 );

           //poll for Ack message from the host as an acknowledgment that the host received the returnbytes
           while(!(UART_Polled_Rx ( gp_my_uart, rx_buff, 1 )))
            ;

           //read the data from the host for the request number of bytes
           if(rx_buff[0]== 'a')
               rx_size = UART_Polled_Rx(gp_my_uart, g_buffer, num_bytes);

           //send Ack message to indicate one transaction is done
           MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"a",1);
           //Recive 1-byte CRC for data of size num_bytes
           while(!(UART_Polled_Rx ( gp_my_uart, rx_buff, 1 )))
                        ;
           factor = 1;
           crc = 0;
           while((num_bytes-1)/factor)
           {
              crc = crc^g_buffer[factor];
              factor = factor*2;
           }
           if(crc == (char)rx_buff[0])
           {
               g_src_image_target_address += rx_size;
               g_bkup = g_bkup + rx_size;
               MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"a",1);
           }
           else
           {
               MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"n",1);
               goto CRCFAIL;
           }

      return rx_size;
}





/* function called by COMM_BLK for input data bit stream*/
uint32_t dummy_page_read_handler
(
    uint8_t const ** pp_next_page
)
{
    uint32_t length;
    int i = 0;

    for(i = 0;i<20;i++ )
    {
        dummy_g_page_buffer[i] = '1';
    }
    length = 20;
    *pp_next_page = dummy_g_page_buffer;

    return length;
}
/*==============================================================================
  ISP function to get status after completion of ISP operation.
 */

void dummy_isp_completion_handler
(
    uint32_t value
)
{

    g_isp_operation_busy = 0;

}

