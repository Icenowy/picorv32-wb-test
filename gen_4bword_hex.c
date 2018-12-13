#include <stdio.h>
#include <stdint.h>

int main(int argc, char **argv)
{
	printf("@00000000\n");
	uint32_t content;
	while (fread(&content, 1, sizeof(uint32_t), stdin) == sizeof(uint32_t)) {
		printf("%08x\n", (unsigned int)content);
	}
}
