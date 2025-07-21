#include <stdint.h>

#define UART_BASE 0x20000000
#define UART_TX (*(volatile uint32_t *)(UART_BASE + 0x00))
#define UART_STAT (*(volatile uint32_t *)(UART_BASE + 0x04))

int main() {
  uint32_t status_bit = UART_STAT & 0x1; // read tx_ready bit
  char probe_char = 'A' + status_bit;    // 'A' if 0, 'B' if 1
  UART_TX = probe_char;                  // send it out
  return 0;
}
