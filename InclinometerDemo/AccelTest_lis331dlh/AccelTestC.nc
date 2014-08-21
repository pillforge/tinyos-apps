#include "cma3000-d0x.h"
#include <math.h>

module AccelTestC {
  uses {
    interface Boot;
    interface Read<accel_t> as AccelSensor;
    interface Timer<TMilli> as TimerLED;
    interface Leds;
    interface SplitControl as AccelControl;
    interface AMSend as SerialSend;
    interface SplitControl as SerialControl;
  }


}
implementation {

  message_t msg;
  bool uartReady = FALSE;
  bool accelReady = FALSE;
  const uint8_t normalization = 54;

  event void Boot.booted(){
    /*printf("App booted %s\r\n", __TIME__);*/
    call AccelControl.start();
    call SerialControl.start();
  }

  event void AccelControl.startDone(error_t result){
    if (result == SUCCESS){
      accelReady = TRUE;
      call TimerLED.startPeriodic(50);
    }
  }
  event void SerialControl.startDone(error_t result){
    if(result == SUCCESS)
      uartReady = TRUE;
  }
  event void AccelControl.stopDone(error_t result){}
  event void SerialControl.stopDone(error_t result){}

  event void AccelSensor.readDone(error_t result, accel_t data){
    accel_msg* payload;

    if(result == SUCCESS && uartReady){
      payload = (accel_msg *)call SerialSend.getPayload(&msg, sizeof(accel_msg));
      payload->accel = data;
      payload->angle.x = asin(((float)data.x)/normalization);
      payload->angle.y = asin(((float)data.y)/normalization);
      payload->angle.z = asin(((float)data.z)/normalization);
      uartReady = FALSE;
      call Leds.led2On();
      call SerialSend.send(AM_BROADCAST_ADDR, &msg, sizeof(accel_msg));
    }
  }
  event void SerialSend.sendDone(message_t* bufPtr, error_t result){
    if(bufPtr == &msg){
      uartReady = TRUE;
      call Leds.led2Off();
    }
  }

  event void TimerLED.fired(){
    if(accelReady){
      call AccelSensor.read();
      call Leds.led0Toggle();
    }     
      
  }

}
