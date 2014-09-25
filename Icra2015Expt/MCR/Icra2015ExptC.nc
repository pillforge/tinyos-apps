#define CC1101_PA CC1101_PA_PLUS_10
#include "Icra2015Expt.h"
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
    interface Timer<TMilli> as MotorTimer;
    interface PacketAcknowledgements as Acks;
    interface SplitControl as RadioControl;
    interface Actuate<uint8_t> as M0;
    interface LowPowerListening;
    interface HplMsp430GeneralIO as PwmPin;
  }


}
implementation {

  message_t packet;
  Accel_t data;
  RadioExptCommandMsg last_cmd;
  uint8_t to_send_addr = 2;

  event void Boot.booted(){
    last_cmd.sample_rate = 2000;
    last_cmd.duty_cycle = 100;
    last_cmd.motor_on_time = 100;
    call PwmPin.makeOutput();
    call PwmPin.clr();
    call LowPowerListening.setLocalWakeupInterval(250);
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
    call Timer.startPeriodic(last_cmd.sample_rate);
  }

  event void MotorTimer.fired(){
    // Stop motor
    call M0.write(0);
    // Restart radio
    call RadioControl.start();
  }

  event void RadioControl.stopDone(error_t err){
      call M0.write(last_cmd.motor_duty_cycle);
      call MotorTimer.startOneShot(last_cmd.motor_on_time);
  }

  event message_t* Receive.receive(message_t* bufPtr, 
           void* payload, uint8_t len) {
    RadioExptCommandMsg * cmd = (RadioExptCommandMsg *) payload;
    if(cmd->cmd == 1){
      last_cmd = *cmd;
      call RadioControl.stop();
      call Timer.stop();
    }
    return bufPtr;
  }
  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
  }

  event void AccelRead.readDone(error_t err, Accel_t val){
    /*printf("X: %d, Y: %d, Z: %d\n", val.x, val.y, val.z);*/
    data = val;
    post sendTask();
  }
  event void GyroRead.readDone(error_t err, Gyro_t val){
    /*printf("X: %d, Y: %d, Z: %d\n", val.x, val.y, val.z);*/
  }

}
