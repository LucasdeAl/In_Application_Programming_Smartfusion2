#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "mss_uart.h"
#include "mss_sys_services.h"
#include "mss_spi.h"
//#include"flash_w25n01g.h"


mss_uart_instance_t * const gp_my_uart = &g_mss_uart0;

size_t
UART_Polled_Rx(mss_uart_instance_t * this_uart,uint8_t * rx_buff, size_t buff_size);

void Read_Status_Register(void)
{
    uint8_t tx_buf[2] = { 0x0F, 0x00};
    uint8_t rx_buf[8] = { 0 };



    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);

    MSS_SPI_transfer_block(&g_mss_spi0, tx_buf, 2, rx_buf, 8);

    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
}

void test_spi_flash(void)
{
    uint8_t tx_buf[1] = { 0x9F};
    uint8_t rx_buf[4] = { 0 };



    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);

    MSS_SPI_transfer_block(&g_mss_spi0, tx_buf, 1, rx_buf, 4);

    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);


}
void erase_block_flash(void)
{
    // Comando 0xD8 seguido de 3 bytes de endereço – para o bloco iniciado em 0x000000.
    uint8_t tx_buf[4] = { 0xD8, 0x00, 0x00, 0x00 };
    uint8_t rx_buf[4] = { 0 };

    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
    MSS_SPI_transfer_block(&g_mss_spi0, tx_buf, 4, rx_buf, 4);
    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
}


void write_enable(void)
{
    uint8_t tx_buf[1] = { 0x06};



    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);

    MSS_SPI_transfer_block(&g_mss_spi0, tx_buf, 1, NULL, 0);

    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
}

void program_data_load(void)
{
    // Neste exemplo, 6 bytes: comando, 2 bytes de endereço e 3 bytes de dados.
    uint8_t tx_buf[6] = { 0x02, 0x00, 0x00, 0xAB, 0xCD, 0xEF };

    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
    MSS_SPI_transfer_block(&g_mss_spi0, tx_buf, 6, NULL, 0);
    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
}

void program_execute(void)
{
    // 0x10 seguido por 2 bytes de endereço (0x00, 0x00)
    uint8_t tx_buf[3] = { 0x10, 0x00, 0x00 };

    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
    MSS_SPI_transfer_block(&g_mss_spi0, tx_buf, 3, NULL, 0);
    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
}

void page_data_read(void)
{
    // 0x13 seguido de 2 bytes de endereço (0x00, 0x00)
    uint8_t tx_buf[3] = { 0x13, 0x00, 0x00 };

    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
    MSS_SPI_transfer_block(&g_mss_spi0, tx_buf, 3, NULL, 0);
    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
}


void read_data(void)
{
    // 0x03 seguido de 2 bytes de endereço (0x00, 0x00)
    uint8_t tx_buf[3] = { 0x03, 0x00, 0x00 };
    // Defina um buffer de leitura com tamanho adequado – aqui, exemplo com 6 bytes (poderá incluir dummy bytes)
    uint8_t rx_buff[6] = {0};

    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
    MSS_SPI_transfer_block(&g_mss_spi0, tx_buf, 3, rx_buff, 6);
    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);

    // rx_buff deverá conter os dados lidos a partir do buffer interno da flash.
}




int main()
{
    uint8_t rx_buff[8];
    uint8_t tx_data[4] = {0xAB, 0xCD, 0, 0};
    uint8_t rx_data[2] = {0x00, 0x00};


    MSS_SPI_init(&g_mss_spi0);
    MSS_SYS_init(MSS_SYS_NO_EVENT_HANDLER);


       MSS_SPI_configure_master_mode(
           &g_mss_spi0,
           MSS_SPI_SLAVE_0,
           MSS_SPI_MODE3,
           128u,
           8
       );

       Read_Status_Register();
       //test_spi_flash();
       write_enable();
       erase_block_flash();
       program_data_load();
       program_execute();
       page_data_read();
       read_data();




/*
    MSS_UART_init( gp_my_uart,
                MSS_UART_57600_BAUD,
                      MSS_UART_DATA_8_BITS | MSS_UART_NO_PARITY | MSS_UART_ONE_STOP_BIT);

*/


    while(1)
    {


    }


    return 0;
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


