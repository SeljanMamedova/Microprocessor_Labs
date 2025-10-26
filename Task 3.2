void setup() {
  Serial.begin(9600);

  uint8_t sum;
  asm volatile (
    "ldi r16, 1     \n\t"   // counter = 1
    "ldi r17, 0     \n\t"   // sum = 0
    "ldi r18, 10    \n\t"   // limit = 10
  "loop1:            \n\t"
    "add r17, r16   \n\t"   // sum += counter
    "inc r16        \n\t"   // counter++
    "cp r16, r18    \n\t"   // compare counter and limit
    "brne loop1     \n\t"   // repeat if not equal
    "add r17, r16   \n\t"   // add final 10
    "mov %0, r17    \n\t"   // move result into C variable
    : "=r" (sum)            // output
    :                       // no inputs
    : "r16","r17","r18"     // clobbered registers
  );

  Serial.print("Sum = ");
  Serial.println(sum);  // should print 55
}

void loop() {
}
