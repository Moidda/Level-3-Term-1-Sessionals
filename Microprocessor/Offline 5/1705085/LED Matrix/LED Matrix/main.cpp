/*
	For an LED to light up
	 - column should be high enabled
	 - row should be low enabled
*/

#define F_CPU 2000000

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#define byte				unsigned char
#define COLUMN				PORTD
#define ROW					PORTC
#define ENABLE(x, i)		(x | (1<<i))
#define DISABLE(x, i)		(x & (~(1<<i)))		

byte pattern[8][8] = {
		0, 0, 0, 0, 0, 0, 0, 0,
		0, 1, 1, 0, 0, 1, 1, 0,
		0, 1, 1, 0, 0, 1, 1, 0,
		0, 1, 1, 0, 0, 1, 1, 0,
		0, 1, 1, 0, 0, 1, 1, 0,
		0, 1, 1, 0, 0, 1, 1, 0,
		0, 1, 1, 1, 1, 1, 1, 0,
		0, 0, 1, 1, 1, 1, 0, 0,
};

volatile int rotate = 0;

ISR(INT2_vect) {
	rotate ^= 1;
}


int main(void)
{
	// This will disable JTAG in software (for PORTC to work in IO mode properly)
	// MCUCSR = (1<<JTD);
	// MCUCSR = (1<<JTD);
	
    DDRD = 0b11111111;						// make PORTD as output
	DDRC = 0b11111111;						// make PORTC as output

	GICR = (1<<INT2);						// enabling interrupt 2
	MCUCSR = DISABLE(MCUCSR, ISC2);			// making the interrupt falling edge triggered
	sei();									// enabling the interrupt subsystem globally
	
	int offset = 0;
	int itr = 50;
	
    while (1) 
    {
		for(int i = 0; i < itr; i++) {
			for(byte col = 0; col < 8; col++) {
				COLUMN = 0;
				COLUMN = ENABLE(COLUMN, col);
				
				ROW = 0b11111111;
				for(byte row = 0; row < 8; row++)
					if(pattern[row][col] == 1)
						ROW = DISABLE(ROW, (row-offset+8)%8);
				
				_delay_ms(1);
			}	
		}
	
		if(rotate) {
			offset++;
			offset %= 8;
		}
	}
}

