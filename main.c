#define UART0_ADDR		(0x01c28000)

#define UART0_RBR_THR_DLL	(UART0_ADDR + 0x0)
#define UART0_DLH_IER		(UART0_ADDR + 0x4)
#define UART0_IIR_FCR		(UART0_ADDR + 0x8)
#define UART0_LCR		(UART0_ADDR + 0xc)
#define UART0_LSR		(UART0_ADDR + 0x14)

#define CLK_24M_BAUD_115200	(0xd)
#define LCR_8N1			(0x3)

#define DLL_DEFAULT		CLK_24M_BAUD_115200
#define LCR_DEFAULT		LCR_8N1

#define REG(a) (*(volatile unsigned int *)(a))

void uart_putchar(char c)
{
	while (!(REG(UART0_LSR) & (1 << 6)));
	REG(UART0_RBR_THR_DLL) = c;
}

int main()
{
	(*(volatile unsigned int *)UART0_LCR) = 0x80;
	(*(volatile unsigned int *)UART0_DLH_IER) = 0x0;
	(*(volatile unsigned int *)UART0_RBR_THR_DLL) = DLL_DEFAULT;
	(*(volatile unsigned int *)UART0_LCR) = LCR_DEFAULT;

	while(1) {
		uart_putchar('H');
		uart_putchar('e');
		uart_putchar('l');
		uart_putchar('l');
		uart_putchar('o');
		uart_putchar(' ');
		uart_putchar('W');
		uart_putchar('o');
		uart_putchar('r');
		uart_putchar('l');
		uart_putchar('d');
		uart_putchar('!');
		uart_putchar('\r');
		uart_putchar('\n');
	}
}
