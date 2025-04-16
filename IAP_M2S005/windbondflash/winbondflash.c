/***************************************************************************//**
 * (c) Copyright 2009 Actel Corporation.  All rights reserved.
 * 
 *  Atmel AT25DF641 SPI flash driver implementation.
 *
 * SVN $Revision:$
 * SVN $Date:$
 */



#include "winbondflash.h"
#include "mss_spi.h"
//#include "../mss_pdma/mss_pdma.h"

#define READ_ARRAY_OPCODE   0x03 //ok
#define DEVICE_ID_READ      0x9F //ok

#define DATA_LOAD_CMD       0x02 //ok extra
#define DATA_READ_CMD       0x13 //ok extra

#define WRITE_ENABLE_CMD    0x06 //ok
#define WRITE_DISABLE_CMD   0x04 //ok
#define PROGRAM_PAGE_CMD    0x10 //ok
#define WRITE_STATUS1_OPCODE    0x01 //ok
//#define CHIP_ERASE_OPCODE   0x60
//#define ERASE_4K_BLOCK_OPCODE   0x20
//#define ERASE_32K_BLOCK_OPCODE  0x52
//#define ERASE_64K_BLOCK_OPCODE  0xD8
#define ERASE_128K_BLOCK_OPCODE 0xD8 //OK EXTRA
#define READ_STATUS         0x05 //OK


#define READY_BIT_MASK      0x01

//#define UNPROTECT_SECTOR_OPCODE     0x39 //?

#define DONT_CARE       0x00u //OK

#define NB_BYTES_PER_PAGE   128 //OK

/*******************************************************************************
 * Local functions
 */
static void wait_ready( void );

/*******************************************************************************
 *
 */
void FLASH_init( void ) //OK
{
    /*--------------------------------------------------------------------------
     * Configure SPI.
     */
    MSS_SPI_init( &g_mss_spi0 );
    
    MSS_SPI_configure_master_mode
        (
            &g_mss_spi0,
            MSS_SPI_SLAVE_0,
            MSS_SPI_MODE3,
            8,
            MSS_SPI_BLOCK_TRANSFER_FRAME_SIZE
        );

    /*--------------------------------------------------------------------------
     * Configure DMA channel used as part of this SPI Flash driver.
     */
/*
    PDMA_init();
    PDMA_configure
        (
            PDMA_CHANNEL_0,
            PDMA_TO_SPI_1,
            PDMA_LOW_PRIORITY | PDMA_BYTE_TRANSFER | PDMA_INC_SRC_ONE_BYTE,
            PDMA_DEFAULT_WRITE_ADJ
        );
*/
}

/*******************************************************************************
 *
 */
void FLASH_read_device_id //OK
(
    uint8_t * manufacturer_id,
    uint8_t * device_id
)
{
    uint8_t read_device_id_cmd = DEVICE_ID_READ;
    uint8_t read_buffer[2];
    
    MSS_SPI_set_slave_select( &g_mss_spi0, MSS_SPI_SLAVE_0 );
    
    MSS_SPI_transfer_block( &g_mss_spi0, &read_device_id_cmd, 1, read_buffer, sizeof(read_buffer) );
    MSS_SPI_clear_slave_select( &g_mss_spi0, MSS_SPI_SLAVE_0 );

    *manufacturer_id = read_buffer[0];
    *device_id = read_buffer[1];
}

/*******************************************************************************
 *
 */
void FLASH_read // OK deu certo
(
    uint32_t address,
    uint8_t * rx_buffer,
    size_t size_in_bytes
)
{
    uint8_t cmd_buffer[3];
    
    //ler PA
    cmd_buffer[0] = DATA_READ_CMD;
    cmd_buffer[1] = (uint8_t)((address >> 24) & 0xFF);
    cmd_buffer[2] = (uint8_t)((address >> 16) & 0xFF);

    MSS_SPI_set_slave_select( &g_mss_spi0, MSS_SPI_SLAVE_0 );
    wait_ready();
    MSS_SPI_transfer_block( &g_mss_spi0, cmd_buffer, 3, NULL,0); //carrega os dados no buffer da flash

    //ler a partir do CA
    cmd_buffer[0] = READ_ARRAY_OPCODE;
    cmd_buffer[1] = (uint8_t)((address >> 8) & 0xFF);
    cmd_buffer[2] = (uint8_t)(address & 0xFF);

    wait_ready();
    MSS_SPI_transfer_block( &g_mss_spi0, cmd_buffer, 3, rx_buffer, size_in_bytes ); // ler os dados do buffer da flash
    wait_ready();
    MSS_SPI_clear_slave_select( &g_mss_spi0, MSS_SPI_SLAVE_0 );
}

/*******************************************************************************
 *
 */
void FLASH_global_unprotect( void ) //ok
{
    uint8_t cmd_buffer[3];
    /* Send Write Enable command */
    cmd_buffer[0] = WRITE_ENABLE_CMD;

    MSS_SPI_set_slave_select( &g_mss_spi0, MSS_SPI_SLAVE_0 );
    wait_ready();
    MSS_SPI_transfer_block( &g_mss_spi0, cmd_buffer, 1, 0, 0 );
    
    /* Send Chip Erase command */
    cmd_buffer[0] = WRITE_STATUS1_OPCODE;
    cmd_buffer[1] = 0xA0;
    cmd_buffer[2] = 0;
    
    wait_ready();
    MSS_SPI_transfer_block( &g_mss_spi0, cmd_buffer, 3, 0, 0 );
    wait_ready();
    MSS_SPI_clear_slave_select( &g_mss_spi0, MSS_SPI_SLAVE_0 );
}

/*******************************************************************************
 *
 */
void FLASH_chip_erase(void) // ok testar
{
    uint8_t cmd_buffer[4];  // Comando de 1 byte + 2 bytes de endereço de bloco

    // Enviar o comando Write Enable
    cmd_buffer[0] = WRITE_ENABLE_CMD;
    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
    wait_ready();
    MSS_SPI_transfer_block(&g_mss_spi0, cmd_buffer, 1, NULL, 0);

    // Iterar sobre todos os 1.024 blocos de 128KB e apagá-los
    for (uint16_t block_address = 0; block_address < 1024; block_address++)
    {
        // Configurar o comando de apagamento de bloco (128KB)
        cmd_buffer[0] = ERASE_128K_BLOCK_OPCODE;
        cmd_buffer[1] = (block_address >> 8) & 0xFF;  // Endereço de bloco mais significativo (1 byte)
        cmd_buffer[2] = block_address & 0xFF;         // Endereço de bloco menos significativo (1 byte)

        // Enviar o comando de apagamento para o bloco de 128KB
        MSS_SPI_transfer_block(&g_mss_spi0, cmd_buffer, sizeof(cmd_buffer), NULL, 0);

        // Aguardar a conclusão da operação de apagamento
        wait_ready();
    }

    // Após terminar, desmarcar o slave
    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
}



/*******************************************************************************
 *
 */



void FLASH_erase_128k_block(uint32_t address)
{
    uint8_t cmd_buffer[4];  // 1 byte para comando, 2 bytes para Page Address e 1 byte de controle

    // Extraindo os 16 bits mais significativos para o Page Address
    uint16_t page_address = (address >> 16) & 0xFFFF;  // 16 bits MSB

    // Enviar o comando Write Enable para permitir apagamento
    cmd_buffer[0] = WRITE_ENABLE_CMD;
    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
    wait_ready();
    MSS_SPI_transfer_block(&g_mss_spi0, cmd_buffer, 1, NULL, 0);

    // Enviar o comando para apagar o bloco de 128KB, utilizando apenas o Page Address
    cmd_buffer[0] = ERASE_128K_BLOCK_OPCODE;
    cmd_buffer[1] = (page_address >> 8) & 0xFF;  // Byte mais significativo do Page Address
    cmd_buffer[2] = page_address & 0xFF;         // Byte menos significativo do Page Address

    // Enviar o comando de apagamento do bloco de 128KB
    MSS_SPI_transfer_block(&g_mss_spi0, cmd_buffer, sizeof(cmd_buffer), NULL, 0);

    // Aguardar a conclusão da operação de apagamento
    wait_ready();

    // Após terminar, desmarcar o slave
    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
}


/*******************************************************************************
 *
 */
void write_cmd_data
(
    mss_spi_instance_t * this_spi,
    const uint8_t * cmd_buffer,
    uint16_t cmd_byte_size,
    uint8_t * data_buffer,
    uint16_t data_byte_size
)
{
#if 0
    uint32_t transfer_size;

    transfer_size = cmd_byte_size + data_byte_size;

    MSS_SPI_disable( this_spi );
    MSS_SPI_set_transfer_byte_count( this_spi, transfer_size );

    PDMA_start
        (
            PDMA_CHANNEL_0,         /* channel_id */
            (uint32_t)cmd_buffer,   /* src_addr */
            PDMA_SPI0_TX_REGISTER,  /* dest_addr */
            cmd_byte_size           /* transfer_count */
        );

    PDMA_load_next_buffer
        (
            PDMA_CHANNEL_0,         /* channel_id */
            (uint32_t)data_buffer,  /* src_addr */
            PDMA_SPI0_TX_REGISTER,  /* dest_addr */
            data_byte_size          /* transfer_count */
        );

    MSS_SPI_enable( this_spi );
#else

    uint8_t tx_buffer[516];
    uint16_t transfer_size;
    uint16_t idx = 0;

    transfer_size = cmd_byte_size + data_byte_size;

    for(idx = 0; idx < cmd_byte_size; ++idx)
    {
        tx_buffer[idx] = cmd_buffer[idx];
    }

    for(idx = 0; idx < data_byte_size; ++idx)
    {
        tx_buffer[cmd_byte_size + idx] = data_buffer[idx];
    }

    MSS_SPI_transfer_block( &g_mss_spi0, tx_buffer, transfer_size, 0, 0 );

#endif
    while ( !MSS_SPI_tx_done(this_spi) )
    {
        ;
    }
}

        
/*******************************************************************************
 *
 */
void FLASH_program
(
    uint32_t address,
    uint8_t * write_buffer,
    size_t size_in_bytes
)
{
    uint8_t cmd_buffer[3];
    
    uint32_t in_buffer_idx;
    uint32_t nb_bytes_to_write;
    uint32_t target_addr;
    uint8_t tx_buff[2051];// cmd + 2048 bytes

    MSS_SPI_set_slave_select( &g_mss_spi0, MSS_SPI_SLAVE_0 );
    
    /* Send Write Enable command */
    cmd_buffer[0] = WRITE_ENABLE_CMD;
    wait_ready();
    MSS_SPI_transfer_block( &g_mss_spi0, cmd_buffer, 1, 0, 0 );
    
    //desabilitando qualquer proteção de escrita(a ser verificado)
    cmd_buffer[0] = WRITE_STATUS1_OPCODE;
    cmd_buffer[1] = 0xA0;
    cmd_buffer[2] = 0;

    wait_ready();
    MSS_SPI_transfer_block( &g_mss_spi0, cmd_buffer, sizeof(cmd_buffer), 0, 0 );

    /* Send Write Enable command */
    cmd_buffer[0] = WRITE_ENABLE_CMD;
    wait_ready();
    MSS_SPI_transfer_block( &g_mss_spi0, cmd_buffer, 1, 0, 0 );
    
    /*  */
    in_buffer_idx = 0;
    nb_bytes_to_write = size_in_bytes;
    target_addr = address;
    

    /* carrega a página no buffer da flash*/
    cmd_buffer[0] = DATA_LOAD_CMD;
    cmd_buffer[1] = (target_addr << 16) & 0xff;
    cmd_buffer[2] = (target_addr) & 0xff;
    

    for(in_buffer_idx = 0;in_buffer_idx<sizeof(cmd_buffer);in_buffer_idx++)
    {
        tx_buff[in_buffer_idx] = cmd_buffer[in_buffer_idx];
    }

    for(int i = 0;i<size_in_bytes;i++)
    {
        tx_buff[in_buffer_idx + i] = write_buffer[i];
    }

    MSS_SPI_transfer_block( &g_mss_spi0, tx_buff, (sizeof(cmd_buffer) + nb_bytes_to_write), 0, 0 );

    /* Programa a página */
    cmd_buffer[0] = PROGRAM_PAGE_CMD;
    cmd_buffer[1] = (target_addr << 24) & 0xff;
    cmd_buffer[2] = (target_addr << 16) & 0xff;

    wait_ready();
    MSS_SPI_transfer_block( &g_mss_spi0, cmd_buffer, 3, 0, 0 );
    
    /* Send Write Disable command. */
    cmd_buffer[0] = WRITE_DISABLE_CMD;

    wait_ready();

    MSS_SPI_transfer_block( &g_mss_spi0, cmd_buffer, 1, 0, 0 );
    MSS_SPI_clear_slave_select( &g_mss_spi0, MSS_SPI_SLAVE_0 );
}

/*******************************************************************************
 *
 */
uint8_t FLASH_get_status( void )
{
    uint8_t status;
    uint8_t command = READ_STATUS;
    
    MSS_SPI_transfer_block( &g_mss_spi0, &command, sizeof(uint8_t), &status, sizeof(status) );
    
    return status;
}

/*******************************************************************************
 *
 */
static void wait_ready( void )
{
    uint8_t ready_bit;
    uint8_t command[2] = {0x0F, 0xC0};

     do {
          MSS_SPI_set_slave_select( &g_mss_spi0, MSS_SPI_SLAVE_0 );
          MSS_SPI_transfer_block( &g_mss_spi0, command, sizeof(command), &ready_bit, sizeof(ready_bit) );
          //MSS_SPI_clear_slave_select( &g_mss_spi0, MSS_SPI_SLAVE_0 );
          ready_bit = ready_bit & 0x01;
     } while( ready_bit == 1 );

}

