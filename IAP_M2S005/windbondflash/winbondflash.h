#include <stdint.h>
#include <stdlib.h>

void FLASH_init( void );

void FLASH_read_device_id
(
    uint8_t * manufacturer_id,
    uint8_t * device_id
);

void FLASH_read
(
    uint32_t address,
    uint8_t * rx_buffer,
    size_t size_in_bytes
);

void FLASH_global_unprotect( void );

void FLASH_erase_128k_block(uint32_t address);

void FLASH_chip_erase( void );

uint8_t FLASH_get_status( void );

void FLASH_program
(
    uint32_t address,
    uint8_t * write_buffer,
    size_t size_in_bytes
);
void program_data_load(void);
void page_data_read(void);
void read_data(uint8_t * rx_buff);

