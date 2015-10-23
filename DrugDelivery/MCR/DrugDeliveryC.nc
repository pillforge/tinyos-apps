/*#define CC1101_PA CC1101_PA_PLUS_10*/
#include "DrugDelivery.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module DrugDeliveryC {
  uses {

    interface Boot;
    interface Timer<TMilli> as BeatTimer;
    interface Leds;

    interface SplitControl as RadioControl;
    interface Packet;
    interface AMSend;
    interface Receive;

    interface Timer<TMilli>;
    interface Timer<TMilli> as MotorTimer;
    interface Actuate<uint8_t> as M0;
    interface DrugSchedulerI;
  }
}

/*
 *  Led 0 blinks every second
 *  Led 1 blinks when it receives a message from Base
 */

implementation {

  message_t packet;
  uint8_t to_send_addr = 1;
  uint8_t status = 120;
  uint8_t data1 = 99;
  uint32_t data2 = 99999;
  uint32_t data3 = 99999;
  task void sendStatus();
  task void handleStatus();

  event void Boot.booted() {
    printf("MCR booted: DrugDeliveryC\n");
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("MCR radio started\n");
      printf("Waiting for the initial scheduling to arrive\n..sending 120 status code\n");
      call BeatTimer.startPeriodic(1000);
    } else {
      call RadioControl.start();
    }
  }

  event void BeatTimer.fired() {
    call Leds.led0Toggle();
    if (status == 120 || status <= 100) {
      post sendStatus();
    }
  }

  task void sendStatus() {
    RadioStatusMsg *rsm = (RadioStatusMsg *) call Packet.getPayload(&packet, sizeof(RadioStatusMsg));
    rsm->status = status;
    rsm->data1 = data1;
    call AMSend.send(to_send_addr, &packet, sizeof(RadioStatusMsg));
  }

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    RadioStatusMsg *rsm = (RadioStatusMsg *) payload;
    call Leds.led1Toggle();
    status = rsm->status;
    data1 = rsm->data1;
    data2 = rsm->data2;
    data3 = rsm->data3;
    printf("Status: %d\n", status);
    post handleStatus();
    return bufPtr;
  }

  task void handleStatus() {
    switch (status) {
      case 121:
        printf("Schedule receive start\n");
        status = 122;
        post sendStatus();
        break;
      case 123:
        printf("Received a schedule: #%d %d mins %s %d%\n", data1, data2, data3);
        printf("only data 3 %d\n", data3);
        post sendStatus();
        break;
      case 124:
        printf("Schedule wholly received\n");
        status = 100;
        post sendStatus();
        break;
      default:
        printf("Undefined status code: %d\n", status);
        break;
    }
  }

  

  task void sendTask();


  event void DrugSchedulerI.scheduleReceived() {
    printf("DrugDeliveryC.DrugSchedulerI.scheduleReceived\n");
    call Leds.led1Toggle();
    call Timer.stop();
    call Timer.startPeriodic(1000);
  }

  event void Timer.fired() {
    printf("Remaining drug: %d%\n", status);
    if (status <= 0) {
      call Timer.stop();
    }
    post sendTask();
  }

  task void sendTask() {
    RadioDataMsg *rdm = (RadioDataMsg *) call Packet.getPayload(&packet, sizeof(RadioDataMsg));
    rdm->status = status;
    call AMSend.send(to_send_addr, &packet, sizeof(RadioDataMsg));
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {}

  event void DrugSchedulerI.release (uint8_t amount) {
    uint8_t c_amount = amount > status ? status : amount;
    printf("DrugDeliveryC.DrugSchedulerI.release %d percent\n", amount);
    status -= c_amount;
    call M0.write(255); // value to be determined
    call MotorTimer.startOneShot(c_amount); // value to be determined
  }

  event void MotorTimer.fired() {
    call M0.write(0);
  }

  event void RadioControl.stopDone(error_t err) {}

}
