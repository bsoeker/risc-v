#include <stdint.h>

#define UART_BASE 0x20000000
#define UART_TX (*(volatile uint32_t *)(UART_BASE + 0x00))
#define UART_STAT (*(volatile uint32_t *)(UART_BASE + 0x04))

char str[] __attribute__((section(".data"))) = "Hello World!";

void delay() {
  for (int i = 0; i < 1000; i++) {
  }
}

int main() {
  for (int i = 0; i < sizeof(str) / sizeof(char); i++) {
    delay();
    UART_TX = str[i];
  }
  return 0;
}
