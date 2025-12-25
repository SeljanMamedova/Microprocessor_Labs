//Master Code
#define F_CPU 16000000UL
#define BAUD 9600
#define UBRR_VALUE ((F_CPU/16/BAUD)-1)

#include <avr/io.h>

void uart_init() {
    UBRR0H = (uint8_t)(UBRR_VALUE >> 8);
    UBRR0L = (uint8_t)(UBRR_VALUE & 0xFF);
    UCSR0B = (1 << TXEN0) | (1 << RXEN0);
    UCSR0C = (1 << UCSZ01) | (1 << UCSZ00); // 8-bit data
}

void uart_transmit(uint8_t data) {
    while (!(UCSR0A & (1 << UDRE0)));
    UDR0 = data;
}

uint8_t uart_receive() {
    while (!(UCSR0A & (1 << RXC0)));
    return UDR0;
}

int main(void) {
    uart_init();

    while (1) {
        uint8_t val = uart_receive();   // read from PC terminal

        // valid inputs: 1,2,3,4
        if (val == '1' || val == '2' || val == '3' || val == '4') {
            uart_transmit(val);         // send to slave
        }
    }
}




//Slave Code

#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/eeprom.h>
#include <util/delay.h>

#define LED1 PD2
#define LED2 PD3
#define LED3 PD4

void uart_init() {
    uint16_t ubrr = 103; // 9600 baud
    UBRR0H = (uint8_t)(ubrr >> 8);
    UBRR0L = (uint8_t)(ubrr & 0xFF);
    UCSR0B = (1 << RXEN0);
    UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);
}

uint8_t uart_receive() {
    while (!(UCSR0A & (1 << RXC0)));
    return UDR0;
}

void leds_off() {
    PORTD &= ~((1 << LED1) | (1 << LED2) | (1 << LED3));
}

void led_on(uint8_t val) {
    leds_off();
    if (val == '1') PORTD |= (1 << LED1);
    else if (val == '2') PORTD |= (1 << LED2);
    else if (val == '3') PORTD |= (1 << LED3);
}

int main(void) {
    DDRD |= (1 << LED1) | (1 << LED2) | (1 << LED3); // LEDs as output
    uart_init();

    uint8_t eeprom_index = 0;
    uint8_t storing = 1;

    while (1) {
        uint8_t val = uart_receive();

        // STORE MODE
        if (storing && (val == '1' || val == '2' || val == '3')) {
            eeprom_write_byte((uint8_t*)eeprom_index, val);
            eeprom_index++;
        }

        // STOP & PLAYBACK
        else if (val == '4') {
            storing = 0;

            // playback sequence
            for (uint8_t i = 0; i < eeprom_index; i++) {
                uint8_t stored_val = eeprom_read_byte((uint8_t*)i);
                led_on(stored_val);
                _delay_ms(500);
            }

            leds_off();
            _delay_ms(500);

            // reset for new sequence
            eeprom_index = 0;
            storing = 1;
        }
    }
}
