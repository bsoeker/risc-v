#include <stdint.h>

#define SPI_WRITE (*(volatile uint32_t*)0x30000000)
#define SPI_READ (*(volatile uint32_t*)0x30000004)
#define SPI_READY (*(volatile uint32_t*)0x30000008)
#define UART_WRITE (*(volatile uint32_t*)0x20000000)
#define UART_READY (*(volatile uint32_t*)0x20000004)

void spi_write(uint32_t val) {
    while (SPI_READY == 0)
        ;

    SPI_WRITE = val;
}

int main() {
    for (volatile int i = 0; i < 2500000; i++)
        ; // Wait for W5500 active low Reset assertion for min 500 us

    // spi_write(0x000104C0); // write to GAR0 = 192
    // spi_write(0x000204A8); // write to GAR1 = 168
    // spi_write(0x00030400); // write to GAR2 = 0
    spi_write(0x00040402); // write to GAR3 = 1
    spi_write(0x00040000); // read from GAR3 = 1

    for (volatile int i = 0; i < 2500000; i++)
        ; // Wait for spi transmission to complete.
    uint8_t read_value = SPI_READ;
    UART_WRITE = 'A' + read_value;

    return 0;
}
