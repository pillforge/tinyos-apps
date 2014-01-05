module RadioRXBlinkC {
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface Receive;
    interface Timer<TMilli>;
    interface Leds;
  }


}
implementation {

  event void Boot.booted(){
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err){
    call Leds.led0On();
    call Leds.led1On();
  }
  event void RadioControl.stopDone(error_t err){}

  event message_t* Receive.receive(message_t *bufPtr, void *payload, uint8_t len){
    call Leds.led1On();
    call Timer.startOneShot(50);
    return bufPtr;
  }

  event void Timer.fired(){
    call Leds.led1Off();
  }

}
