/*
 * main.c
 *
 * Copyright 2012 Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 *
 */


#include <stdio.h>
#include <stdint.h>


typedef volatile int32_t * pdata_32;

// DDR2
#define DDR2_BASE_ADDR 0xC0000000
#define DDR2_DATA(ADDR_OFFSET) *((pdata_32) (DDR2_BASE_ADDR + (ADDR_OFFSET)))
#define DDR2_DATA_32(ADDR_OFFSET) *((pdata_32) (DDR2_BASE_ADDR + (ADDR_OFFSET) * 4))

// Registers
#define REG_BASE_ADDR 0x77C00000
#define REG_DATA_32(ADDR_OFFSET) *((pdata_32) (REG_BASE_ADDR + (ADDR_OFFSET) * 4))

// Naming conventions:
#define addr_0     REG_DATA_32(0)
#define addr_1     REG_DATA_32(1)
#define addr_2     REG_DATA_32(2)
#define addr_3     REG_DATA_32(3)
#define go_flag    REG_DATA_32(4)
#define ready_flag REG_DATA_32(5)

// We need this header to avoid compiling errors...
void xil_printf(const char *, ...);


int main(void)
{
	int i;

	ready_flag = 0;

	// Write data in the DDR2 external RAM
	xil_printf("Writing data to external DDR2...:\n");
	for (i = 0; i < 16; i++) {
		DDR2_DATA_32(i) = -i;
		DDR2_DATA_32(i+100) = i;
	}

	// Verify data integrity
	xil_printf("Verifying data integrity...\n");
	for (i = 0; i < 16; i++) {
		if (DDR2_DATA_32(i) != -i) xil_printf("Unexpected data! %X => %d\n", &DDR2_DATA_32(i), DDR2_DATA_32(i));
		if (DDR2_DATA_32(i+100) != i) xil_printf("Unexpected data! %X => %d\n", &DDR2_DATA_32(i+100), DDR2_DATA_32(i+100));
	}

	// Write more data at different DDR2 RAM positions
	DDR2_DATA(100) = 6;
	DDR2_DATA(200) = 9;
	DDR2_DATA(300) = 12;

	// Pass those positions and the position 0 as address parameters
	addr_0 = &DDR2_DATA(0);
	addr_1 = &DDR2_DATA(100);
	addr_2 = &DDR2_DATA(200);
	addr_3 = &DDR2_DATA(300);

	// Launch threads
	xil_printf("Launching threads...\n");
	go_flag = 1, go_flag = 0;
	while (!ready_flag);
	xil_printf("Threads have finished!\n");

	// Display DDR2 data once the threads have finished
	xil_printf("DDR2 data after the threads have finished:\n");
	for (i = 0; i < 16; i++) xil_printf("%X => %d\n", &DDR2_DATA_32(i), DDR2_DATA_32(i));
	for (i = 0; i < 16; i++) xil_printf("%X => %d\n", &DDR2_DATA_32(i+100), DDR2_DATA_32(i+100));

	return 0;
}
