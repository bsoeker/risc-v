#include <stdint.h>

#define SPI_WRITE (*(volatile uint32_t*)0x30000000)
#define SPI_READ (*(volatile uint32_t*)0x30000004)
#define UART_TX (*(volatile uint32_t*)0x20000000)

void spi_write(uint32_t val) {
    SPI_WRITE = val;
    // You *must* wait until the SPI is done before continuing!
    for (volatile int i = 0; i < 80; i++)
        ; // crude delay
}

int main() {
    spi_write(0x00390001); // Addr high byte (0x0039)
    uint32_t read_value = SPI_READ;

    UART_TX = 'B' + read_value; // Should print 0x04 if W5500 is responding

    while (1)
        ;
}
