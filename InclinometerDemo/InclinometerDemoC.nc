#include "InclinometerDemo.h"
module InclinometerDemoC {
  uses {
    interface Boot;
    interface AngleControl;
    interface SplitControl as SerialControl;
    interface SplitControl as AngleSplitControl;
    interface Read<int16_t> as AccelRead;
    interface AMSend as SerialSend;
  }


}
implementation {

  bool serialReady = FALSE;
  bool angleReached = FALSE;
  message_t msg;

  enum {
    S_IDLE,
    S_TXDATA
  } state = S_IDLE;

  event void Boot.booted(){
    call AngleSplitControl.start();
    call SerialControl.start();
  }

  event void AngleSplitControl.startDone(error_t error){
    if(error == SUCCESS){
      call AngleControl.setAngle(45);
    }
  }

  event void SerialControl.startDone(error_t error){
    if(error == SUCCESS){
      serialReady = TRUE;
    }
  }
  event void SerialControl.stopDone(error_t error){}
  event void AngleSplitControl.stopDone(error_t error){}

  event void AngleControl.setAngleDone(error_t error){
    angleReached = TRUE;
  }

  event void AccelRead.readDone(error_t error, int16_t val){
    if(serialReady){
      AccelMsg* payload;
      payload = (AccelMsg*) call SerialSend.getPayload(&msg, sizeof(AccelMsg));
      payload->x = val;
      call SerialSend.send(AM_BROADCAST_ADDR, &msg, sizeof(AccelMsg));
    }
  }

  event void SerialSend.sendDone(message_t* bufPtr,error_t error){
  }

}
