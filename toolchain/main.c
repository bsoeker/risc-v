#include <stdint.h>

#define SPI_WRITE (*(volatile uint32_t*)0x30000000)
#define SPI_READ (*(volatile uint32_t*)0x30000004)
#define UART_TX (*(volatile uint32_t*)0x20000000)

void spi_write(uint8_t val) {
    SPI_WRITE = val;
    // You *must* wait until the SPI is done before continuing!
    for (volatile int i = 0; i < 10; i++)
        ; // crude delay
}

uint8_t spi_exchange(uint8_t val) {
    SPI_WRITE = val;
    for (volatile int i = 0; i < 10; i++)
        ; // crude delay
    return (uint8_t)SPI_READ;
}

int main() {
    spi_write(0x00);                  // Addr high byte (0x0039)
    spi_write(0x39);                  // Addr low byte
    spi_write(0x00);                  // Read control byte
    uint8_t ver = spi_exchange(0x00); // Dummy write, receive version byte

    UART_TX = 'A' + ver; // Should print 0x04 if W5500 is responding

    while (1)
        ;
}
