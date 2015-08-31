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
    interface UartStream;
    interface PacketAcknowledgements as Acks;
    interface SplitControl as RadioControl;
  }
}
implementation {

  message_t packet;
  uint8_t to_send_addr = 2;
  char serial_trig_letter = 's';

  task void sendSchedule();
  task void sendTask();

  event void Boot.booted() {
    printf("Base booted: DrugDeliveryBaseC\n");
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("Base radio started. Send %c to send actuation command\n", serial_trig_letter);
      call UartStream.enableReceiveInterrupt();
    } else {
      call RadioControl.start();
    }
  }

  async event void UartStream.receivedByte(uint8_t byte) {
    if (byte == serial_trig_letter) {
      call UartStream.disableReceiveInterrupt();
      post sendSchedule();
      // post sendTask();
    } else
      printf("Send %c to send actuation command\n", serial_trig_letter);
  }

  task void sendSchedule() {
    DrugSchedulerData *dsd = (DrugSchedulerData *)
      call Packet.getPayload(&packet, sizeof(DrugSchedulerData));
    dsd->time_interval = 2; //60 * 60;
    dsd->amount = 10;
    call AMSend.send(to_send_addr, &packet, sizeof(DrugSchedulerData));
  }

  task void sendTask() {
    RadioCommandMsg* rcm = (RadioCommandMsg*)call Packet.getPayload(&packet, sizeof(RadioCommandMsg));
    printf("Sending actuation command...");
    rcm->cmd = 1;
    rcm->motor_duty_cycle = 100; // percent
    rcm->motor_on_time = 100; // in ms
    rcm->sample_rate = 5000; // in s
    call AMSend.send(to_send_addr, &packet, sizeof(RadioCommandMsg));
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    printf("...Done\n");
    call UartStream.enableReceiveInterrupt();
  }

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    RadioDataMsg* val = (RadioDataMsg*) payload;
    printf("Received: %s\n", (char *)val->msg);
    return bufPtr;
  }

  event void RadioControl.stopDone(error_t err) {
  }

  async event void UartStream.sendDone(uint8_t*, uint16_t, error_t) {
  }

  async event void UartStream.receiveDone(uint8_t* buf, uint16_t len, error_t error) {
  }

}
