
module TimerTestC {
  uses {
    interface Boot;
    interface Timer<TMilli> as Timer;
    interface Leds;
    interface HplMsp430GeneralIO as DebugPin;
  }


}
implementation {

  event void Boot.booted(){
    call Timer.startPeriodic(100);
  }

  event void Timer.fired(){
    call Leds.set(call Leds.get() ^ 7);
    call DebugPin.toggle();
  }

}
