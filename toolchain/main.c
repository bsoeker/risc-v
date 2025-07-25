#include <stdint.h>

#define SPI_WRITE (*(volatile uint32_t*)0x30000000)
#define SPI_READ (*(volatile uint32_t*)0x30000004)
#define UART_TX (*(volatile uint32_t*)0x20000000)

void spi_write(uint32_t val) {
    SPI_WRITE = val;
    // You *must* wait until the SPI is done before continuing!
    for (volatile int i = 0; i < 1000; i++)
        ; // crude delay
}

int main() {
    for (volatile int i = 0; i < 25000000; i++) {
        ; // ~1 second delay at 25 MHz
    }

    spi_write(0x00390001);

    return 0;
}
