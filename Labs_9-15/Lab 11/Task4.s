//Code For Master

#include <avr/io.h>              
#include <util/delay.h>                                // delay functions

void SPI_MasterInit(void)                             // initialize SPI in master mode
{
    DDRB |= (1 << DDB3) | (1 << DDB5) | (1 << DDB2);     // MOSI, SCK, SS as outputs

    PORTB |= (1 << PORTB2);                             // set SS high (slave not selected)

    SPCR = (1 << SPE) | (1 << MSTR) | (1 << SPR0);      // enable SPI, master mode
}

void SPI_MasterTransmit(uint8_t data) 
{
    PORTB &= ~(1 << PORTB2);                            // pull SS low to select slave

    SPDR = data;                                       // load data into SPI data register

    while (!(SPSR & (1 << SPIF)));                    // wait until transmission completes

    PORTB |= (1 << PORTB2);                          // pull SS high to release slave
}

int main(void)
{
    SPI_MasterInit();

    uint8_t values[3] = {85, 170, 255};                     // values to send to slave
    uint8_t i = 0;                                         // index for values array

    while (1)
    {
        SPI_MasterTransmit(values[i]);                    // send current value

        i = (i + 1) % 3;                                 // move to next value

        _delay_ms(1000);                                // delay 1 second between transmissions
    }
}


//Code For Slave 

#include <avr/io.h>
#include <Arduino.h>             

void SPI_SlaveInit(void)                           // initialize SPI in slave mode
{
    DDRB |= (1 << DDB4);                         // set MISO as output

    SPCR = (1 << SPE);
}

uint8_t SPI_SlaveReceive(void)  
{
    while (!(SPSR & (1 << SPIF)));                  // wait until data is received

    return SPDR;                                  // return received data
}

void setup()
{
    Serial.begin(9600);                       // initialize serial communication

    SPI_SlaveInit();                         // initialize SPI slave
}

void loop()
{
    uint8_t received = SPI_SlaveReceive();               // receive data from master

    Serial.print("Received: ");                         // print label
    Serial.println(received);                          // print received value
}
