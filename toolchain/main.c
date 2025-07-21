#include <stdint.h>
int main() {
  // Your bare-metal code
  *((volatile uint32_t *)0x20000000) = 'H';
  return 1;
}
