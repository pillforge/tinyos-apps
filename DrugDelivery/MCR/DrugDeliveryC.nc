/*#define CC1101_PA CC1101_PA_PLUS_10*/
#include "DrugDelivery.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module DrugDeliveryC {
  uses {
    interface Boot;
    interface AMSend;
    interface Packet;
    interface Timer<TMilli>;
    interface Timer<TMilli> as MotorTimer;
    interface PacketAcknowledgements as Acks;
    interface SplitControl as RadioControl;
    interface Actuate<uint8_t> as M0;
    interface DrugSchedulerI;
  }
}
implementation {

  message_t packet;
  uint8_t to_send_addr = 1;
  uint8_t remaining_drug = 100; // in percentage

  task void sendTask();

  event void Boot.booted() {
    printf("MCR booted: DrugDeliveryC\n");
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("MCR radio started\n");
      printf("Waiting for the initial scheduling to arrive\n");
    } else {
      call RadioControl.start();
    }
  }

  event void DrugSchedulerI.scheduleReceived() {
    printf("DrugDeliveryC.DrugSchedulerI.scheduleReceived\n");
    call Timer.stop();
    call Timer.startPeriodic(1000);
  }

  event void Timer.fired() {
    printf("Remaining drug: %d%\n", remaining_drug);
    if (remaining_drug <= 0) {
      call Timer.stop();
    }
    post sendTask();
  }

  task void sendTask() {
    RadioDataMsg *rdm = (RadioDataMsg *) call Packet.getPayload(&packet, sizeof(RadioDataMsg));
    rdm->remaining_drug = remaining_drug;
    call AMSend.send(to_send_addr, &packet, sizeof(RadioDataMsg));
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {}

  event void DrugSchedulerI.release (uint8_t amount) {
    printf("DrugDeliveryC.DrugSchedulerI.release %d percent\n", amount);
    remaining_drug -= amount;
    call M0.write(255); // value to be determined
    call MotorTimer.startOneShot(amount); // value to be determined
  }

  event void MotorTimer.fired() {
    call M0.write(0);
  }

  event void RadioControl.stopDone(error_t err) {}

}
