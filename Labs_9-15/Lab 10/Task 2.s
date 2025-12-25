//Master Code:

#define F_CPU 16000000UL                 // frequency = 16 MHz
#define BAUD 9600                       
#define UBRR_VALUE ((F_CPU/16/BAUD)-1)  

#include <avr/io.h>                      

void uart_init() {                                      // initialize UART
    UBRR0H = (uint8_t)(UBRR_VALUE >> 8);                          // set high byte of baud rate
    UBRR0L = (uint8_t)(UBRR_VALUE & 0xFF);                           // set low byte of baud rate
    UCSR0B = (1 << TXEN0) | (1 << RXEN0);                          // enable UART transmit and receive
    UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);                      // configure 8-bit data frame
}

void uart_transmit(uint8_t data) {       
    while (!(UCSR0A & (1 << UDRE0)));     // wait until transmit buffer is empty
    UDR0 = data;                          // load data into UART data register
}

uint8_t uart_receive() {                 
    while (!(UCSR0A & (1 << RXC0)));                                       // wait until data is received
    return UDR0;                                                          // return received byte
}

int main(void) {
    uart_init();                                                        // initialize UART module

    while (1) {                                                       // infinite loop
        uint8_t val = uart_receive();                                // read character from PC

        if (val == '1' || val == '2' || val == '3') {               // check valid commands
            uart_transmit(val);
        }
    }
}


//Slave Code:

#define F_CPU 16000000UL                 
#include <avr/io.h>                      

void uart_init() {                      // initialize UART (RX only)
    uint16_t ubrr = 103;                // UBRR value for 9600 baud
    UBRR0H = (uint8_t)(ubrr >> 8);       
    UBRR0L = (uint8_t)(ubrr & 0xFF);     
    UCSR0B = (1 << RXEN0);               // enable UART receiver only
    UCSR0C = (1 << UCSZ01) | (1 << UCSZ00); 
}

uint8_t uart_receive() {                
    while (!(UCSR0A & (1 << RXC0)));     
    return UDR0;                         
}

int main(void) {
    DDRD |= (1 << PD2) | (1 << PD3) | (1 << PD4);      // set PD2, PD3, PD4 as outputs (LEDs)

    uart_init();                         

    uint8_t last_val = 0;                

    while (1) {                          
        uint8_t val = uart_receive();    // receive command from master

        if (val == '1' || val == '2' || val == '3') {        // validate received command

            if (val != last_val) {                         // update only if command changed
                last_val = val;                           // save new command

                PORTD &= ~((1 << PD2) | (1 << PD3) | (1 << PD4)); // turn off all LEDs

                if (val == '1')                            // command 1 selected
                    PORTD |= (1 << PD2);                  // turn on LED on PD2
                else if (val == '2')                     // command 2 selected
                    PORTD |= (1 << PD3);                // turn on LED on PD3
                else if (val == '3')                   // command 3 selected
                    PORTD |= (1 << PD4);              // turn on LED on PD4
            }
        }
    }
}
