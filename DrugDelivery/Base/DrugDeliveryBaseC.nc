/*#define CC1101_PA CC1101_PA_PLUS_0*/
#include "DrugDelivery.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module DrugDeliveryBaseC {
  uses {
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Packet;
    interface Timer<TMilli>;
    interface PacketAcknowledgements as Acks;
    interface SplitControl as RadioControl;
    interface HplMsp430GeneralIO as ScopeTrigger;
  }


}
implementation {

  message_t packet;
  Accel_t data;
  uint8_t to_send_addr = 2;

  event void Boot.booted(){
    printf("Booted\n");
    call ScopeTrigger.makeOutput();
    call ScopeTrigger.clr();
    call RadioControl.start();
  }

  task void sendTask();

  event void Timer.fired(){
    post sendTask();
  }


  task void sendTask() {
    RadioCommandMsg* rcm = (RadioCommandMsg*)call Packet.getPayload(&packet, sizeof(RadioCommandMsg));
    /*call ScopeTrigger.clr();*/
    /*call ScopeTrigger.set();*/
    rcm->cmd = 1;
    rcm->motor_duty_cycle = 50; // percent
    rcm->motor_on_time = 500; // in ms
    rcm->sample_rate = 2000; // in s
    /*rcm->cmd = 2;*/
    /*call PacketLink.setRetries(&packet, 10);*/
    call AMSend.send(to_send_addr, &packet, sizeof(RadioDataMsg));
  }

  event void RadioControl.startDone(error_t err){
    printf("Radio started\n");
    call Timer.startPeriodic(1000);
  }
  event void RadioControl.stopDone(error_t err){}

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    RadioDataMsg* val = (RadioDataMsg*) payload;
    call ScopeTrigger.set();
    /*printf("Received: X: %d, Y: %d, Z: %d\n", val->sensor_data.x, val->sensor_data.y, val->sensor_data.z);*/
    printf("Received: %s\n", (char *)val->msg);

    /*post sendTask();*/
    return bufPtr;
  }
  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    call ScopeTrigger.clr();
  }

}
