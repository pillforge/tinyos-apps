#include "cma3000-d0x.h"

module AccelTestC {
  uses {
    interface Boot;
    interface Read<accel_t> as AccelSensor;
    interface Timer<TMilli> as TimerLED;
    interface Leds;
    interface SplitControl as AccelControl;
    interface Init as AccelInit;
  }


}
implementation {

  event void Boot.booted(){
    printf("App booted %s\r\n", __TIME__);
    call TimerLED.startPeriodic(500);
    call AccelControl.start();
  }

  event void AccelControl.startDone(error_t result){
    if (result == SUCCESS){
      call AccelInit.init();
      call AccelSensor.read();
    }
  }
  event void AccelControl.stopDone(error_t result){}

  event void AccelSensor.readDone(error_t result, accel_t data){
    if(result == SUCCESS){
      /*printf("X: %d Y:%d Z:%d\r\n", data.x, data.y, data.z);*/
      printf("%d,%d,%d\r\n", data.x, data.y, data.z);
    }
    call AccelSensor.read();
  }

  event void TimerLED.fired(){
    call Leds.led0Toggle();
  }

}
