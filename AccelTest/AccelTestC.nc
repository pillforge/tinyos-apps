#include "cma3000-d0x.h"

module AccelTestC {
  uses {
    interface Boot;
    interface Read<accel_t> as AccelSensor;
    interface Timer<TMilli> as TimerLED;
    interface Leds;
  }


}
implementation {

  event void Boot.booted(){
    printf("App booted %s\r\n", __TIME__);
    call TimerLED.startPeriodic(500);
    call AccelSensor.read();
  }

  event void AccelSensor.readDone(error_t result, accel_t data){
    if(result == SUCCESS){
      printf("X: %d Y:%d Z:%d\r\n", data.x, data.y, data.z);
    }
    /*call AccelSensor.read();*/
  }

  event void TimerLED.fired(){
    call Leds.led0Toggle();
    call AccelSensor.read();
  }

}