#include "Icra2015Expt.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module Icra2015ExptBaseC {
  uses {
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Packet;
    interface Timer<TMilli>;
    interface PacketAcknowledgements as Acks;
    interface SplitControl as RadioControl;
  }


}
implementation {

  message_t packet;
  Accel_t data;
  uint8_t to_send_addr = 1;

  event void Boot.booted(){
    call RadioControl.start();
  }

  event void Timer.fired(){
  }

  task void sendTask();

  task void sendTask() {
    RadioExptCommandMsg* rcm = (RadioExptCommandMsg*)call Packet.getPayload(&packet, sizeof(RadioExptCommandMsg));
    rcm->cmd = 1;
    /*call PacketLink.setRetries(&packet, 10);*/
    call AMSend.send(to_send_addr, &packet, sizeof(RadioExptDataMsg));
  }

  event void RadioControl.startDone(error_t err){
  }
  event void RadioControl.stopDone(error_t err){}

  event message_t* Receive.receive(message_t* bufPtr, 
           void* payload, uint8_t len) {
    RadioExptDataMsg* val = (RadioExptDataMsg*) payload;
    printf("Received: X: %d, Y: %d, Z: %d\n", val->sensor_data.x, val->sensor_data.y, val->sensor_data.z);

    post sendTask();
    return bufPtr;
  }
  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
  }

}
