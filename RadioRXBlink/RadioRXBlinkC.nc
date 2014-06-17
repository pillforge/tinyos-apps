#define CC1101_PA CC1101_PA_MINUS_30
module RadioRXBlinkC {
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface Receive;
    interface Timer<TMilli>;
    interface Timer<TMilli> as WatchdogTimer;
    interface Leds;
    interface LowPowerListening;
    interface HplMsp430GeneralIO as DebugPin;
    interface HplMsp430GeneralIO as DebugPin2;
  }


}
implementation {

  enum { 
    RX_PERIOD = 200,
    BUFFER_TIME = 2*RX_PERIOD, // 2.4 Kbps
  };

  event void Boot.booted(){
    call RadioControl.start();
    call DebugPin.makeOutput();
    call DebugPin.clr();
    call DebugPin2.makeOutput();
    call DebugPin2.clr();
  }

  event void RadioControl.startDone(error_t err){
    call Leds.led0On();
    /*call Leds.led1On();*/
    call WatchdogTimer.startOneShot(BUFFER_TIME);
    call LowPowerListening.setLocalWakeupInterval(1000);
  }
  event void RadioControl.stopDone(error_t err){}

  event message_t* Receive.receive(message_t *bufPtr, void *payload, uint8_t len){
    call Leds.led1On();
    call Timer.startOneShot(5);
    call WatchdogTimer.stop();
    call WatchdogTimer.startOneShot(BUFFER_TIME);
    return bufPtr;
  }

  event void Timer.fired(){
    call Leds.led1Off();
  }

  event void WatchdogTimer.fired() {
    call WatchdogTimer.stop();
    call WatchdogTimer.startOneShot(BUFFER_TIME);
    /*call DebugPin.set();*/
    /*call DebugPin.clr();*/
  }
}
