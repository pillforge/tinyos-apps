/*#define CC1101_PA CC1101_PA_PLUS_10*/
#include "DrugDelivery.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module DrugDeliveryC {
  uses {
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Packet;
    interface Timer<TMilli>;
    interface Timer<TMilli> as MotorTimer;
    interface PacketAcknowledgements as Acks;
    interface SplitControl as RadioControl;
    interface Actuate<uint8_t> as M0;
    /*interface LowPowerListening;*/
    interface HplMsp430GeneralIO as Boost_EN;
  }


}
implementation {

  message_t packet;
  uint8_t to_send_addr = 1;

  event void Boot.booted(){
    call M0.write(20);
    call Boost_EN.makeOutput();
    call Boost_EN.set();
    call RadioControl.start();
    /*call LowPowerListening.setLocalWakeupInterval(250);*/
    call Timer.startPeriodic(1000);
    printf("MCR Booted\n");
  }


  task void sendTask();

  event void Timer.fired(){
    printf("Alive\n");
    post sendTask();
  }

  task void sendTask() {
    RadioDataMsg* rcm = (RadioDataMsg*)call Packet.getPayload(&packet, sizeof(RadioDataMsg));
    memcpy(rcm->msg,"Alive",6);
    call AMSend.send(to_send_addr, &packet, sizeof(RadioDataMsg));
  }

  event void RadioControl.startDone(error_t err){
    if(err != SUCCESS)
      call RadioControl.start();
  }

  event void MotorTimer.fired(){
    // Stop motor
    call M0.write(0);
  }

  event void RadioControl.stopDone(error_t err){
  }

  event message_t* Receive.receive(message_t* bufPtr, 
           void* payload, uint8_t len) {
    RadioCommandMsg * cmd = (RadioCommandMsg *) payload;
    printf("cmd:%d duty:%d on:%d\n", cmd->cmd, cmd->motor_duty_cycle, cmd->motor_on_time);
    if(cmd->cmd == 1){
      call M0.write(cmd->motor_duty_cycle);
      call MotorTimer.startOneShot(cmd->motor_on_time);
    }
    return bufPtr;
  }
  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
  }


}
