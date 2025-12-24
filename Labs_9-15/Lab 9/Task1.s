#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

// 7-segment lookup table
// bit0 = a, bit1 = b, ..., bit6 = g
// Values correspond to digits 0–9 for display
static const uint8_t segLUT[10] = {
  0x3F, // 0 -> a b c d e f ON
  0x06, // 1
  0x5B, // 2
  0x4F, // 3
  0x66, // 4
  0x6D, // 5
  0x7D, // 6
  0x07, // 7
  0x7F, // 8
  0x6F  // 9
};

// current digit to be shown on 7-seg
volatile uint8_t digit = 0;

// flag to pause / resume counting
volatile uint8_t paused = 0;

// Function to display a digit on the 7-segment

static inline void displayDigit(uint8_t d) {
  uint8_t p = segLUT[d];   // get segment pattern for digit

  // for common anode display, segments must be inverted
  // p = ~p;

  // send segments 
  PORTC = (PORTC & 0xC0) | (p & 0x3F);

  // send segment g (bit6) to PD7
  if (p & (1 << 6))
    PORTD |= (1 << PD7);    // turn ON segment g
  else
    PORTD &= ~(1 << PD7);   // turn OFF segment g
}


// Timer1 Compare Match A Interrupt
// Triggered every 0.5 seconds

ISR(TIMER1_COMPA_vect) {
  if (!paused) {            // only count if not paused
    digit++;                // increase digit
    if (digit >= 10)        // wrap around after 9
      digit = 0;
    displayDigit(digit);    // update display
  }
}

// External Interrupt INT0 (D2 button)
// Used to pause / resume counting

ISR(INT0_vect) {
  _delay_ms(30);            // simple debounce delay

  // check if button is still pressed (active LOW)
  if (!(PIND & (1 << PD2))) {
    paused ^= 1;            // toggle pause flag

    // stop timer when paused, restart when resumed
    if (paused) {
      // stop Timer1 clock (freeze counter)
      TCCR1B &= ~((1 << CS12) | (1 << CS11) | (1 << CS10));
    } else {
      // restart Timer1 with prescaler 256
      TCCR1B |= (1 << CS12);
    }
  }
}

void setup() {
  cli();   // disable global interrupts

  // configure PC0..PC5 as output 
  DDRC |= 0b00111111;

  // configure PD7 as output (segment g)
  DDRD |= (1 << PD7);

  
  displayDigit(digit);

  // configure button pin PD2 as input
  DDRD &= ~(1 << PD2);

  // enable internal pull-up resistor on PD2
  PORTD |= (1 << PD2);

  // configure INT0 to trigger on falling edge
  EICRA |= (1 << ISC01);
  EICRA &= ~(1 << ISC00);

  // enable external interrupt INT0
  EIMSK |= (1 << INT0);

  
  TCCR1A = 0;
  TCCR1B = 0;

  // CTC mode (clear timer on compare match)
  TCCR1B |= (1 << WGM12);

  
  // F_CPU = 16 MHz, prescaler = 256
  OCR1A = 31249;


  TCNT1 = 0;

  // enable Timer1 compare match A interrupt
  TIMSK1 |= (1 << OCIE1A);

  // start Timer1 with prescaler 256
  TCCR1B |= (1 << CS12);

  sei();   // enable global interrupts
}

// Main loop (empty because interrupts handle everything)

void loop() {
  
}
