#include <stdint.h>

#define SPI_WRITE (*(volatile uint32_t*)0x30000000)
#define SPI_READ (*(volatile uint32_t*)0x30000004)
#define SPI_READY (*(volatile uint32_t*)0x30000008)
#define UART_WRITE (*(volatile uint32_t*)0x20000000)
#define UART_READY (*(volatile uint32_t*)0x20000004)

void spi_write(uint32_t val) { SPI_WRITE = val; }

int main() {
    for (volatile int i = 0; i < 2500000; i++)
        ; // Wait for W5500 active low Reset assertion for min 500 us

    while ((SPI_READY & 0x1) == 0)
        ;
    spi_write(0x00390000);
    for (volatile int i = 0; i < 2500000; i++)
        ;
    uint8_t read_value = SPI_READ;
    while ((UART_READY & 0x1) == 0)
        ;
    UART_WRITE = 'A' + read_value;

    return 0;
}
