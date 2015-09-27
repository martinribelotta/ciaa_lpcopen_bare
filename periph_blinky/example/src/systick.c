#include "board.h"

#define TICKRATE_HZ (1000)

const int LED_3 = 2;
const int LED_2 = 1;
const int LED_1 = 0;
const int LED_RED = 3;
const int LED_GREEN = 4;
const int LED_BLUE = 5;

static volatile uint32_t tick_ct = 0;

void SysTick_Handler(void) {
	tick_ct++;
}

void delay(uint32_t tk) {
	uint32_t end = tick_ct + tk;
	while(tick_ct < end)
		__WFI();
}

int main(void) {
	SystemCoreClockUpdate();
	Board_Init();
	SysTick_Config(SystemCoreClock / TICKRATE_HZ);

	while (1) {
		Board_LED_Toggle(LED_3);
		delay(100);
		Board_UARTPutSTR("Hola mundo\r\n");
	}
}
