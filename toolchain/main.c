#include <stdint.h>

#define UART_BASE 0x20000000
#define UART_TX (*(volatile uint32_t *)(UART_BASE + 0x00))
#define UART_STAT (*(volatile uint32_t *)(UART_BASE + 0x04))

char str[] __attribute__((section(".data"))) = "Hello";

void delay() {
  for (int i = 0; i < 1000000; i++) {
  }
}

int main() {
  UART_TX = str[0];
  return 0;
}
