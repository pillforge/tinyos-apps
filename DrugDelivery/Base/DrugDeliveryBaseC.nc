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
  uint8_t sending_schedule = 0;

  uint8_t size_schedule_data = 0;
  uint32_t schedule_data[][2] = {
    {60, 20},
    {60, 20},
    {180, 60}
  };

  task void handleStatus();
  task void send121();
  void sendSchedule();

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
    printf("Status: %d\n", status);
    post handleStatus();
    return bufPtr;
  }

  task void handleStatus() {
    switch (status) {
      case 120:
        sendSchedule();
        break;
      case 122:
        printf("Starting sending the schedule\n");
        break;
      case 123:
        printf("Acknowledgment received\n");
        break;
      default:
        printf("Undefined status code: %d\n", status);
        break;
    }
  }

  void sendSchedule() {
    if (!sending_schedule) {
      sending_schedule = 1;
      printf("Sending 121\n");
      post send121();
    }
  }

  task void send121() {
    RadioStatusMsg *rsm = (RadioStatusMsg *) call Packet.getPayload(&packet, sizeof(RadioStatusMsg));
    size_schedule_data = sizeof(schedule_data)/sizeof(schedule_data[0]);
    rsm->status = 121;
    rsm->data1 = size_schedule_data;
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
