//Code For Master

// SPI MASTER – ATmega328P (Arduino Uno)

#include <avr/io.h>
#include <util/delay.h>

// ----------------------------------------------------
// Initialize SPI in Master mode
// ----------------------------------------------------
void SPI_MasterInit(void)
{
    // Set MOSI (PB3), SCK (PB5), SS (PB2) as OUTPUT
    DDRB |= (1 << DDB3) | (1 << DDB5) | (1 << DDB2);

    // Set SS HIGH (slave not selected)
    PORTB |= (1 << PORTB2);

    // Enable SPI
    // MSTR = 1 → Master mode
    // SPR0 = 1 → Clock = fosc / 16
    SPCR = (1 << SPE) | (1 << MSTR) | (1 << SPR0);
}

// ----------------------------------------------------
// Transmit one byte via SPI
// ----------------------------------------------------
void SPI_MasterTransmit(uint8_t data)
{
    // Pull SS LOW → select slave
    PORTB &= ~(1 << PORTB2);

    // Load data into SPI data register
    // Transmission starts automatically
    SPDR = data;

    // Wait until transmission is complete
    // SPIF flag becomes 1 when done
    while (!(SPSR & (1 << SPIF)));

    // Pull SS HIGH → release slave
    PORTB |= (1 << PORTB2);
}

// ----------------------------------------------------
// Main program
// ----------------------------------------------------
int main(void)
{
    // Initialize SPI as master
    SPI_MasterInit();

    // Array of values to send to slave
    uint8_t values[3] = {85, 170, 255};
    uint8_t i = 0;

    while (1)
    {
        // Send current value via SPI
        SPI_MasterTransmit(values[i]);

        // Move to next value (0 → 1 → 2 → 0)
        i = (i + 1) % 3;

        // Wait 1 second between transmissions
        _delay_ms(1000);
    }
}


//Code For Slave 

// SPI SLAVE – ATmega328P (Arduino Uno)

#include <avr/io.h>
#include <Arduino.h>

// ----------------------------------------------------
// Initialize SPI in Slave mode
// ----------------------------------------------------
void SPI_SlaveInit(void)
{
    // Set MISO (PB4) as OUTPUT
    // Slave sends data to master through MISO
    DDRB |= (1 << DDB4);

    // Enable SPI (Slave mode by default)
    SPCR = (1 << SPE);
}

// ----------------------------------------------------
// Receive one byte via SPI
// ----------------------------------------------------
uint8_t SPI_SlaveReceive(void)
{
    // Wait until SPI reception is complete
    // SPIF flag is set when data is received
    while (!(SPSR & (1 << SPIF)));

    // Read received data from SPI Data Register
    return SPDR;
}

// ----------------------------------------------------
// Arduino setup function
// ----------------------------------------------------
void setup()
{
    // Initialize serial communication for monitoring
    Serial.begin(9600);

    // Initialize SPI as slave
    SPI_SlaveInit();
}

// ----------------------------------------------------
// Main loop
// ----------------------------------------------------
void loop()
{
    // Receive data sent by SPI master
    uint8_t received = SPI_SlaveReceive();

    // Print received data to Serial Monitor
    Serial.print("Received: ");
    Serial.println(received);
}

