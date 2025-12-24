#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

// 7-segment values for digits 0–9
static const uint8_t segLUT[10] = {
  0x3F, 0x06, 0x5B, 0x4F, 0x66,
  0x6D, 0x7D, 0x07, 0x7F, 0x6F
};

volatile uint8_t digit = 0;   // current digit
volatile uint8_t paused = 0;  // pause flag

// sends digit pattern to 7-seg
static inline void displayDigit(uint8_t d) {
  uint8_t p = segLUT[d];

  // a–f on PORTC
  PORTC = (PORTC & 0xC0) | (p & 0x3F);

  // g segment on PD7
  if (p & (1 << 6))
    PORTD |= (1 << PD7);
  else
    PORTD &= ~(1 << PD7);
}

// timer interrupt every 0.5s
ISR(TIMER1_COMPA_vect) {
  if (!paused) {
    digit++;
    if (digit >= 10)
      digit = 0;
    displayDigit(digit);
  }
}

// button interrupt (pause / resume)
ISR(INT0_vect) {
  _delay_ms(30);   // simple debounce

  if (!(PIND & (1 << PD2))) {
    paused ^= 1;

    if (paused) {
      // stop timer
      TCCR1B &= ~((1 << CS12) | (1 << CS11) | (1 << CS10));
    } else {
      // start timer again
      TCCR1B |= (1 << CS12);
    }
  }
}

void setup() {
  cli();

  // 7-seg outputs
  DDRC |= 0b00111111;
  DDRD |= (1 << PD7);

  displayDigit(digit);

  // button input with pull-up
  DDRD &= ~(1 << PD2);
  PORTD |= (1 << PD2);

  // INT0 on falling edge
  EICRA |= (1 << ISC01);
  EICRA &= ~(1 << ISC00);
  EIMSK |= (1 << INT0);

  // Timer1 setup (CTC mode)
  TCCR1A = 0;
  TCCR1B = 0;
  TCCR1B |= (1 << WGM12);

  // 0.5 second compare value
  OCR1A = 31249;
  TCNT1 = 0;

  TIMSK1 |= (1 << OCIE1A);
  TCCR1B |= (1 << CS12);  // prescaler 256

  sei();
}

void loop() {
  // nothing here, handled by interrupts
}
