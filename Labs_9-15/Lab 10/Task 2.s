//Master Code:

#define F_CPU 16000000UL
#define BAUD 9600
#define UBRR_VALUE ((F_CPU/16/BAUD)-1)

#include <avr/io.h>

// initialize UART with 9600 baud
void uart_init() {
    UBRR0H = (uint8_t)(UBRR_VALUE >> 8);
    UBRR0L = (uint8_t)(UBRR_VALUE & 0xFF);
    UCSR0B = (1 << TXEN0) | (1 << RXEN0);   // enable TX and RX
    UCSR0C = (1 << UCSZ01) | (1 << UCSZ00); // 8-bit data
}

// send one byte via UART
void uart_transmit(uint8_t data) {
    while (!(UCSR0A & (1 << UDRE0))); // wait until buffer empty
    UDR0 = data;
}

// receive one byte via UART
uint8_t uart_receive() {
    while (!(UCSR0A & (1 << RXC0))); // wait for data
    return UDR0;
}

int main(void) {
    uart_init();

    while (1) {
        uint8_t val = uart_receive();  // read character from PC

        // only send valid commands
        if (val == '1' || val == '2' || val == '3') {
            uart_transmit(val);        // forward to slave
        }
    }
}


//Slave Code:

#define F_CPU 16000000UL
#include <avr/io.h>

// initialize UART (receive only)
void uart_init() {
    uint16_t ubrr = 103;               // value for 9600 baud
    UBRR0H = (uint8_t)(ubrr >> 8);
    UBRR0L = (uint8_t)(ubrr & 0xFF);
    UCSR0B = (1 << RXEN0);              // enable RX
    UCSR0C = (1 << UCSZ01) | (1 << UCSZ00); // 8-bit data
}

// receive one byte
uint8_t uart_receive() {
    while (!(UCSR0A & (1 << RXC0)));    // wait for data
    return UDR0;
}

int main(void) {
    // PD2, PD3, PD4 as output for LEDs
    DDRD |= (1 << PD2) | (1 << PD3) | (1 << PD4);

    uart_init();

    uint8_t last_val = 0;               // store previous command

    while (1) {
        uint8_t val = uart_receive();   // get command from master

        // accept only valid values
        if (val == '1' || val == '2' || val == '3') {

            // update LEDs only if value changed
            if (val != last_val) {
                last_val = val;

                // turn off all LEDs
                PORTD &= ~((1 << PD2) | (1 << PD3) | (1 << PD4));

                // turn on selected LED
                if (val == '1')
                    PORTD |= (1 << PD2);
                else if (val == '2')
                    PORTD |= (1 << PD3);
                else if (val == '3')
                    PORTD |= (1 << PD4);
            }
        }
        // other characters are ignored
    }
}

