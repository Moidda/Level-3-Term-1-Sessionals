#ifndef F_CPU
#define F_CPU 16000000UL // 16 MHz clock speed
#endif
#define D4 eS_PORTD4
#define D5 eS_PORTD5
#define D6 eS_PORTD6
#define D7 eS_PORTD7
#define RS eS_PORTC6
#define EN eS_PORTC7


#include <stdio.h>
#include <string.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include "lcd.h" 

#define byte				unsigned char
#define COLUMN				PORTD
#define ROW					PORTC
#define ENABLE(x, i)		(x | (1<<i))
#define DISABLE(x, i)		(x & (~(1<<i)))

void floatToString(char *str, double x) {
	if(x == 0) {
		str[0] = 'g';
		str[1] = 'a';
		str[2] = 'd';
		str[3] = 'h';
		str[4] = 'a';
		str[5] = 0;
		return;
	}
	
	int y = x*100;
	int n = 0, i = 0;
	*str = 0;
	while(y) {
		*(str+i) = '0' + y%10;
		y /= 10;
		i++;
	}
	n = i;
	if(n == 0) {
		str[0] = '0';
		str[1] = 0;
		return;
	}
	for(int i = 0, j = n-1; i < j; i++, j--) {
		char temp = str[i];
		str[i] = str[j];
		str[j] = temp;
	}
	str[n] = 0;
}


int main(void)
{
	DDRD = 0xFF;
	DDRC = 0xFF;
	
	ADMUX = 0b01000100;
	ADCSRA = 0b10000010;
	
	Lcd4_Init();
	
	while(1)
    {	
		
		ADCSRA |= (1<<ADSC);
		while(ADCSRA & (1<<ADSC));
		
		int ADCout = ADCL;
		ADCout += (ADCH<<8);
		
		double voltage = (ADCout*5.0)/1024;
		
		char str[50];
		floatToString(str, voltage);
		// voltage: 
		for(int i = strlen(str); i>=0; i--)
			str[i+9] = str[i];
			
		str[0] = 'v';
		str[1] = 'o';
		str[2] = 'l';
		str[3] = 't';
		str[4] = 'a';
		str[5] = 'g';
		str[6] = 'e';
		str[7] = ':';
		str[8] = ' ';
	
		Lcd4_Clear();
		Lcd4_Set_Cursor(1,1);	
		Lcd4_Write_String(str);
		_delay_ms(500);
	}
}

