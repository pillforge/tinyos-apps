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
    interface SplitControl as RadioControl;

    interface SplitControl as SAMControl;
    interface Receive as SAMReceive;
    interface AMSend as SAMSend;
    interface Packet as SAMPacket;

    interface Timer<TMilli>;
    interface Leds;
  }
}

/*
 *  Led 2 blinks every second
 *  Led 1 blinks when it receives a message from MCR
 *  Led 0 blinks when it receives a message from PC app (serial)
 */

implementation {

  message_t packet;
  message_t s_packet;
  uint8_t to_send_addr = 2;

  uint8_t remaining_drug = 100;
  uint32_t time_interval; // in seconds
  uint8_t amount; // in percentage

  task void sendSchedule();
  task void sendRemainingValue();

  event void Boot.booted() {
    printf("Base booted: DrugDeliveryBaseC\n");
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("Base radio started.\n");
      call SAMControl.start();
    } else {
      call RadioControl.start();
    }
  }

  event void SAMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("SerialActiveMessage started.\n");
      call Timer.startPeriodic(1000);
    } else {
      call SAMControl.start();
    }
  }

  event void Timer.fired() {
    printf("Beat\n");
    call Leds.led2Toggle();
  }

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    RadioDataMsg *rdm = (RadioDataMsg *) payload;
    call Leds.led1Toggle();
    remaining_drug = rdm->remaining_drug;
    printf("Remaining: %d\n", remaining_drug);
    post sendRemainingValue();
    return bufPtr;
  }

  task void sendRemainingValue() {
    DrugSchedulerData *dd = (DrugSchedulerData *)
      call SAMPacket.getPayload(&s_packet, sizeof(DrugSchedulerData));
    dd->amount = remaining_drug;
    call SAMSend.send(AM_BROADCAST_ADDR, &s_packet, sizeof(DrugSchedulerData));
  }

  event message_t* SAMReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    DrugSchedulerData *dd = (DrugSchedulerData *) payload;
    call Leds.led0Toggle();
    time_interval = dd->time_interval; // in seconds
    amount = dd->amount; // in percentage
    post sendSchedule();
    return bufPtr;
  }

  task void sendSchedule() {
    DrugSchedulerData *dsd = (DrugSchedulerData *)
      call Packet.getPayload(&packet, sizeof(DrugSchedulerData));
    dsd->time_interval = time_interval;
    dsd->amount = amount;
    call AMSend.send(to_send_addr, &packet, sizeof(DrugSchedulerData));
  }

  event void SAMSend.sendDone(message_t* bufPtr, error_t error) {}

  event void SAMControl.stopDone(error_t err) {}

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {}

  event void RadioControl.stopDone(error_t err) {}

}
