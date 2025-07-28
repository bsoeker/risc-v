#include <stdint.h>

#define SPI_TX (*(volatile uint32_t*)0x30000000)
#define SPI_RX_READ (*(volatile uint32_t*)0x30000004)
#define SPI_RX_READY (*(volatile uint32_t*)0x30000008)
#define UART_TX (*(volatile uint32_t*)0x20000000)
#define UART_READY (*(volatile uint32_t*)0x20000004)

void delay() {
    for (volatile int i = 0; i < 2500; i++)
        ;
}
__attribute__((noinline)) void spi_write(volatile uint32_t val) {
    while ((SPI_RX_READY & 0x1) == 0)
        ;

    SPI_TX = (uint32_t)val;
    delay();
}

void set_gateway() {
    spi_write(0x000104C0); // write to GAR0 = 192
    spi_write(0x000204A8); // write to GAR1 = 168
    spi_write(0x00030400); // write to GAR2 = 0
    spi_write(0x00040401); // write to GAR3 = 1
}

void set_subnet_mask() {
    spi_write(0x000504FF); // SUBR0 = 255
    spi_write(0x000604FF); // SUBR1 = 255
    spi_write(0x000704FF); // SUBR2 = 255
    spi_write(0x00080400); // SUBR3 = 0
}

void set_mac() {
    spi_write(0x000904DE);
    spi_write(0x000A04AD);
    spi_write(0x000B04BE);
    spi_write(0x000C04EF);
    spi_write(0x000D04CA);
    spi_write(0x000E04FE);
}
void set_source_ip() {
    spi_write(0x000F04C0); // 192
    spi_write(0x001004A8); // 168
    spi_write(0x00110400); // 0
    spi_write(0x00120402); // 2
}
int main() {

    for (volatile int i = 0; i < 2500000; i++)
        ; // Wait for W5500 active low Reset assertion for min 500 us

    set_gateway();
    set_subnet_mask();
    set_mac();
    set_source_ip();

    for (volatile int i = 0; i < 2500000; i++)
        ;

    spi_write(0x00390000); // read

    return 0;
}
