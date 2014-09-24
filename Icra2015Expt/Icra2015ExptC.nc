#include "Lsm330dlc.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module Icra2015ExptC {
  uses {
    interface Boot;
    interface Read<Accel_t> as AccelRead;
    interface Read<Gyro_t> as GyroRead;
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
  uint8_t to_send_addr = 2;

  event void Boot.booted(){
    call RadioControl.start();
  }

  event void Timer.fired(){
    call AccelRead.read();
  }

  task void sendTask();

  task void sendTask() {
    RadioExptDataMsg* rcm = (RadioExptDataMsg*)call Packet.getPayload(&packet, sizeof(RadioExptDataMsg));
    rcm->sensor_data = data;
    /*call PacketLink.setRetries(&packet, 10);*/
    call AMSend.send(to_send_addr, &packet, sizeof(RadioExptDataMsg));
  }

  event void RadioControl.startDone(error_t err){
    call Timer.startPeriodic(100);
  }
  event void RadioControl.stopDone(error_t err){}

  event message_t* Receive.receive(message_t* bufPtr, 
           void* payload, uint8_t len) {
    return bufPtr;
  }
  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
  }

  event void AccelRead.readDone(error_t err, Accel_t val){
    printf("X: %d, Y: %d, Z: %d\n", val.x, val.y, val.z);
    data = val;
    post sendTask();
  }
  event void GyroRead.readDone(error_t err, Gyro_t val){
    printf("X: %d, Y: %d, Z: %d\n", val.x, val.y, val.z);
  }

}
