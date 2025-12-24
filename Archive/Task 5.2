#include <avr/io.h>

#define LED1 PD6   // OC0A (Arduino D6)
#define LED2 PD5   // OC0B (Arduino D5)
#define LED3 PB3   // OC2A (Arduino D11)

int main(void)
{
    
    DDRD |= (1 << LED1) | (1 << LED2);   // PD6, PD5 as an output
    DDRB |= (1 << LED3);                 // PB3 output

    TCCR0A = (1 << COM0A1) | (1 << COM0B1) | (1 << WGM01) | (1 << WGM00);

    TCCR0B = (1 << CS01) | (1 << CS00);

  
    OCR0A = (255 * 30) / 100;   // ~30% duty on PD6
    OCR0B = (255 * 50) / 100;   // ~50% duty on PD5

    TCCR2A = (1 << COM2A1) | (1 << WGM21) | (1 << WGM20);

    TCCR2B = (1 << CS21) | (1 << CS20);

    // cycle for Timer2
    OCR2A = (255 * 80) / 100;   // ~80% duty on PB3

    // Hardware PWM runs automatically forever
    while (1) { }
}
