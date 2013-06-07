
module GpioTestC {
  uses {
    interface Boot;
    interface Leds;
    interface HplMsp430GeneralIO as SensePin0; // Must all be on the same port
    interface HplMsp430GeneralIO as SensePin1;
    interface HplMsp430GeneralIO as SensePin2;

    interface HplMsp430GeneralIO as OutPin0; 
    interface HplMsp430GeneralIO as OutPin1;
    interface HplMsp430GeneralIO as OutPin2;
    interface Timer<TMilli>;
  }


}
implementation {

  event void Boot.booted(){
    call SensePin0.makeInput();
    call SensePin1.makeInput();
    call SensePin2.makeInput();
    call OutPin0.makeOutput();
    call OutPin1.makeOutput();
    call OutPin2.makeOutput();
    call OutPin0.set();
    call OutPin1.set();
    call OutPin2.set();
    call Timer.startPeriodic(500);
  }

  event void Timer.fired(){
    // Assuming the SensePins are on the lowest 3 bits
    uint8_t val0 = call SensePin0.getRaw();
    uint8_t val1 = call SensePin1.getRaw();
    uint8_t val2 = call SensePin2.getRaw();
    call Leds.set(val0 | val1 | val2);
    printf("Val: %d %d %d\r\n", val0, val1, val2);
  }

}
