#include <avr/io.h>         
#include <avr/interrupt.h>  // AVR interrupt handling
#include <util/delay.h>     

static const uint8_t segLUT[10] = { // 7-segment lookup table for digits 0–9
  0x3F,  // 0 → segments a b c d e f ON
  0x06,  // 1
  0x5B,  // 2
  0x4F,  // 3
  0x66,  // 4
  0x6D,  // 5
  0x7D,  // 6
  0x07,  // 7
  0x7F,  // 8
  0x6F   // 9
};

volatile uint8_t digit = 0;   // current digit displayed on 7-segment
volatile uint8_t paused = 0;  // pause/resume flag

static inline void displayDigit(uint8_t d) { // function to display digit on 7-segment
  uint8_t p = segLUT[d];      // get segment pattern from lookup table

   PORTC = (PORTC & 0xC0) | (p & 0x3F); // send segments a–f to PC0–PC5

  if (p & (1 << 6))           // check segment g bit
    PORTD |= (1 << PD7);      // turn ON segment g
  else
    PORTD &= ~(1 << PD7);     // turn OFF segment g
}

ISR(TIMER1_COMPA_vect) {      // Timer1 Compare Match A interrupt
  if (!paused) {              // count only if not paused
    digit++;                  // increment digit
    if (digit >= 10)          // wrap after 9
      digit = 0;
    displayDigit(digit);      // update 7-segment display
  }
}

ISR(INT0_vect) {              // External interrupt INT0 (button on PD2)
  _delay_ms(30);              // delay

  if (!(PIND & (1 << PD2))) { // check if button is still pressed (active LOW)
    paused ^= 1;              // toggle pause state

    if (paused) {             // if paused
      TCCR1B &= ~((1 << CS12) | (1 << CS11) | (1 << CS10)); // stop Timer1
    } else {                  // if resumed
      TCCR1B |= (1 << CS12);  // restart Timer1 with prescaler 256
    }
  }
}

void setup() {
  cli();                      // disable global interrupts

  DDRC |= 0b00111111;         // set PC0–PC5 as outputs (segments a–f)
  DDRD |= (1 << PD7);         // set PD7 as output (segment g)

  displayDigit(digit);        // show initial digit (0)

  DDRD &= ~(1 << PD2);        // set PD2 as input (button)
  PORTD |= (1 << PD2);        // enable pull-up resistor on PD2

  EICRA |= (1 << ISC01);      // INT0 triggers on falling edge
  EICRA &= ~(1 << ISC00);
  EIMSK |= (1 << INT0);       // enable INT0 interrupt

  TCCR1A = 0;                 // clear Timer1 control register A
  TCCR1B = 0;                 // clear Timer1 control register B
  TCCR1B |= (1 << WGM12);     // enable CTC mode

  OCR1A = 31249;              // compare value for 0.5 s (16 MHz / 256)
  TCNT1 = 0;                  // reset Timer1 counter

  TIMSK1 |= (1 << OCIE1A);    // enable Timer1 compare match interrupt
  TCCR1B |= (1 << CS12);      // start Timer1 with prescaler 256

  sei();                      // enable global interrupts
}

void loop() {
  // main loop empty — all logic handled by interrupts
}
