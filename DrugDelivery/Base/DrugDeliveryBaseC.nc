/*#define CC1101_PA CC1101_PA_PLUS_0*/
#include "DrugDelivery.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module DrugDeliveryBaseC {
  uses {

    interface Boot;
    interface Timer<TMilli> as BeatTimer;
    interface Leds;

    interface SplitControl as RadioControl;
    interface Packet;
    interface AMSend;
    interface Receive;


    interface SplitControl as SAMControl;
    interface Receive as SAMReceive;
    interface AMSend as SAMSend;
    interface Packet as SAMPacket;

  }
}

/*
 *  Led 0 blinks every second
 *  Led 1 blinks when it receives a message from MCR
 */

implementation {

  message_t packet;
  uint8_t to_send_addr = 2;
  uint8_t status = 255;
  uint8_t data1 = 99;
  uint32_t data2 = 99999;
  uint32_t data3 = 99999;
  uint8_t sending_schedule = 0;

  uint8_t size_schedule_data = 0;
  uint32_t schedule_data[][2] = {
    {60, 20},
    {60, 20},
    {180, 60}
  };

  task void handleStatus();
  task void sendStatus();

  event void Boot.booted() {
    printf("Base booted: DrugDeliveryBaseC\n");
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("Base radio started.\n");
      call BeatTimer.startPeriodic(1000);
    } else {
      call RadioControl.start();
    }
  }

  event void BeatTimer.fired() {
    call Leds.led0Toggle();
  }

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    RadioStatusMsg *rsm = (RadioStatusMsg *) payload;
    call Leds.led1Toggle();
    status = rsm->status;
    data1 = rsm->data1;
    data2 = rsm->data2;
    data3 = rsm->data3;
    printf("Status: %d, data1: %d\n", status, data1);
    post handleStatus();
    return bufPtr;
  }

  task void handleStatus() {
    switch (status) {
      case 120:
        printf("Communication is initiatied\n");
        if(!sending_schedule) {
          status = 121;
          size_schedule_data = sizeof(schedule_data)/sizeof(schedule_data[0]);
          data1 = size_schedule_data;
          post sendStatus();
        }
        break;
      case 122:
        printf("Starting sending the schedule\n");
        if (size_schedule_data > 0) {
          status = 123;
          data1 = 0;
          data2 = schedule_data[0][0];
          data3 = schedule_data[0][1];
          post sendStatus();
        }
        break;
      case 123:
        printf("Acknowledgment received\n");
        if (data1 >= size_schedule_data-1) {
          status = 124;
        } else {
          data1++;
          data2 = schedule_data[data1][0];
          data3 = schedule_data[data1][1];
        }
        post sendStatus();
        break;
      default:
        printf("Undefined status code: %d\n", status);
        break;
    }
  }

  task void sendStatus() {
    RadioStatusMsg *rsm = (RadioStatusMsg *) call Packet.getPayload(&packet, sizeof(RadioStatusMsg));
    rsm->status = status;
    rsm->data1 = data1;
    rsm->data2 = data2;
    rsm->data3 = data3;
    call AMSend.send(to_send_addr, &packet, sizeof(RadioStatusMsg));
  }

  
  message_t s_packet;
  

  uint8_t remaining_drug = 100;
  uint32_t time_interval; // in seconds
  uint8_t amount; // in percentage


  uint8_t schedule_index = 0;
  uint8_t is_schedule_sent = 0;

  task void sendSchedule2();
  task void sendRemainingValue();
  void sendAllSchedule();


  event void SAMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("SerialActiveMessage started.\n");
      sendAllSchedule();
    } else {
      call SAMControl.start();
    }
  }


  void sendAllSchedule() {
    
    printf("Start sending the schedule: %d\n", size_schedule_data);
    post sendSchedule2();
  }

  task void sendSchedule2() {
    DrugSchedulerData *dsd = (DrugSchedulerData *)
      call Packet.getPayload(&packet, sizeof(DrugSchedulerData));
    printf("Sending %d/%d of schedule data.\n", schedule_index, size_schedule_data);
    dsd->time_interval = schedule_data[schedule_index][0];
    dsd->amount = schedule_data[schedule_index][1];
    schedule_index++;
    if (schedule_index == size_schedule_data) {
      is_schedule_sent = 1;
    }
    call AMSend.send(to_send_addr, &packet, sizeof(DrugSchedulerData));
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
    // post sendSchedule2();
    return bufPtr;
  }

  event void SAMSend.sendDone(message_t* bufPtr, error_t error) {}

  event void SAMControl.stopDone(error_t err) {}

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {}

  event void RadioControl.stopDone(error_t err) {}

}
