#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "mss_uart.h"
#include "mss_sys_services.h"
#include "mss_spi.h"
#include "winbondflash.h"
#define BUFFER_SIZE 2048

//*&************************************************************
uint8_t g_page_buffer[BUFFER_SIZE];
uint32_t page_read_handler(uint8_t const ** pp_next_page);
//void isp_completion_handler(uint32_t value);
//dummy
//void dummy_isp_completion_handler(uint32_t value);
//uint32_t dummy_page_read_handler(uint8_t const ** pp_next_page);
volatile uint8_t g_isp_operation_busy = 1;
uint8_t dummy_g_page_buffer[20];
/*==============================================================================
  UART selection.

  mss_uart_instance_t * const gp_my_uart = &g_mss_uart1;
 */

mss_uart_instance_t * const gp_my_uart = &g_mss_uart0;
static uint32_t g_src_image_target_address = 0;
uint32_t g_bkup = 0;
uint8_t g_mode = 0;
static uint32_t g_file_size = 0;
//***********************************************************

void delay(volatile uint8_t n)
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


int main()
{

    uint8_t rx_buff[8] ;

    MSS_UART_init( gp_my_uart,
            MSS_UART_57600_BAUD,
                  MSS_UART_DATA_8_BITS | MSS_UART_NO_PARITY | MSS_UART_ONE_STOP_BIT);


      MSS_SYS_init(MSS_SYS_NO_EVENT_HANDLER);

      /* start the handshake with the host */
      START_HANDSHAKE:
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
           //MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"m",1);
           //while(!(UART_Polled_Rx ( gp_my_uart, rx_buff, 1 )));

           //g_mode  = rx_buff[0];
           /*poll for file size*/
           MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"z",1);
           while(!(UART_Polled_Rx ( gp_my_uart, rx_buff, 8 )))
                         ;
           g_file_size = atoi((const char*)rx_buff);

           MSS_UART_polled_tx(gp_my_uart,(const uint8_t * )"a",1);



           while(1)
           {

           }

}


uint32_t page_read_handler
(
    uint8_t const ** pp_next_page
)
{
    uint32_t length;

    length = read_page_from_host_through_uart(g_page_buffer, BUFFER_SIZE);  // Chama a função de leitura de página
    *pp_next_page = g_page_buffer;  // Aponta pp_next_page para o buffer que contém os dados da página

    return length;  // Retorna o número de bytes lidos
}


static uint32_t read_page_from_host_through_uart
(
    uint8_t * g_buffer,
    uint32_t length
)
{
    uint32_t num_bytes,factor,temp;
    num_bytes = length;  // O número de bytes a serem lidos é dado por 'length'

    char crc;
    size_t rx_size = 0;
    uint8_t rx_buff[1];

    // Inicia a transação de leitura enviando "b" para o host
    MSS_UART_polled_tx(gp_my_uart, (const uint8_t *)"b", 1);

    // Aguarda a confirmação ("Ack") do host
    while (!(UART_Polled_Rx(gp_my_uart, rx_buff, 1)));

    // Se o host confirmou a transação, envia o endereço da memória onde os dados serão armazenados
    temp = g_src_image_target_address / 8;
    if (rx_buff[0] == 'a') {
        MSS_UART_polled_tx(gp_my_uart, (const uint8_t *)&temp, 8);
    }

    // Aguarda a confirmação do envio do endereço
    while (!(UART_Polled_Rx(gp_my_uart, rx_buff, 1)));

    // Envia o número de bytes a serem lidos (returnbytes)
    if (rx_buff[0] == 'a') {
        MSS_UART_polled_tx(gp_my_uart, (const uint8_t *)&num_bytes, 4);
    }

    // Aguarda a confirmação do número de bytes
    while (!(UART_Polled_Rx(gp_my_uart, rx_buff, 1)));

    // Se o host está pronto, começa a leitura dos dados
    if (rx_buff[0] == 'a')
        rx_size = UART_Polled_Rx(gp_my_uart, g_buffer, num_bytes);

    // Envia uma confirmação ("Ack") de que os dados foram lidos
    MSS_UART_polled_tx(gp_my_uart, (const uint8_t *)"a", 1);

    // Recebe o CRC dos dados
    while (!(UART_Polled_Rx(gp_my_uart, rx_buff, 1)));

    factor = 1;
    crc = 0;

    // Calcula o CRC para verificar a integridade dos dados
    while ((num_bytes - 1) / factor) {
        crc = crc ^ g_buffer[factor];
        factor = factor * 2;
    }

    // Compara o CRC calculado com o CRC recebido
    if (crc == (char)rx_buff[0]) {
        g_src_image_target_address += rx_size;
        g_bkup = g_bkup + rx_size;
        MSS_UART_polled_tx(gp_my_uart, (const uint8_t *)"a", 1);  // Envia "a" para confirmar o sucesso da transação
    } else {
        // Se o CRC falhar, envia "n" e tenta novamente
        MSS_UART_polled_tx(gp_my_uart, (const uint8_t *)"n", 1);
        goto CRCFAIL;
    }

    return rx_size;
}







