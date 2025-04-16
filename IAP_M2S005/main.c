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
void write_enable(void)
{
    uint8_t tx_buf[1] = { 0x06};



    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);

    MSS_SPI_transfer_block(&g_mss_spi0, tx_buf, 1, NULL, 0);

    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
}
void erase_block_flash(void)
{
    uint8_t tx_buf[4] = { 0xD8, 0x00, 0x00, 0x00 };  // Comando de apagamento de bloco e endereço
    uint8_t rx_buf[4] = { 0 };

    // Habilita a escrita
    write_enable();

    // Envia o comando de apagamento de bloco
    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
    MSS_SPI_transfer_block(&g_mss_spi0, tx_buf, 4, rx_buf, 4);
    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);


}
void program_data_load(void)
{

    uint8_t tx_buf[6] = { 0x02, 0x00, 0x00, 0xaa, 0xbb, 0xcc };

    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
    MSS_SPI_transfer_block(&g_mss_spi0, tx_buf, 6, NULL, 0);
    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
}
void program_execute(void)
{

    uint8_t tx_buf[3] = { 0x10, 0x00, 0x00 };

    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
    MSS_SPI_transfer_block(&g_mss_spi0, tx_buf, 3, NULL, 0);
    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
}
void page_data_read(void)
{

    uint8_t tx_buf[3] = { 0x13, 0x00, 0x00 };

    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
    MSS_SPI_transfer_block(&g_mss_spi0, tx_buf, 3, NULL, 0);
    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
}
void read_data(uint8_t * rx_buff)
{

    uint8_t tx_buf[3] = { 0x03, 0x00, 0x00 };
    size_t size = sizeof(rx_buff);


    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
    MSS_SPI_transfer_block(&g_mss_spi0, tx_buf, 3, rx_buff, size);
    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);


}




int main()
{

    MSS_SYS_init(MSS_SYS_NO_EVENT_HANDLER);
    uint8_t data_write[BUFFER_SIZE];
    uint8_t data_read[BUFFER_SIZE];
    uint32_t addr = 0x0;

    FLASH_init();

    for(int i=0;i<BUFFER_SIZE;i++)
    {
        data_write[i] = 5;
        data_read[i] = 7;
    }

    //FLASH_init();
    FLASH_chip_erase();
    FLASH_erase_128k_block(addr);
    FLASH_program(addr, data_write, 2048);
    FLASH_read(addr, data_read, 2048);


       //test_spi_flash();
       write_enable();
       erase_block_flash();
       program_data_load();
       program_execute();
       page_data_read();
       read_data(data_read);




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


