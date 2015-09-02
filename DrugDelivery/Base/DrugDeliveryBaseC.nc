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
    interface Timer<TMilli>;
  }
}
implementation {

  message_t packet;
  uint8_t to_send_addr = 2;
  char serial_trig_letter = 's';

  task void sendSchedule();

  event void Boot.booted() {
    printf("Base booted: DrugDeliveryBaseC\n");
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("Base radio started. Send %c to send actuation command\n", serial_trig_letter);
      call UartStream.enableReceiveInterrupt();
      call Timer.startPeriodic(1000);
    } else {
      call RadioControl.start();
    }
  }

  event void Timer.fired() {
    printf("beat\n");
  }

  async event void UartStream.receivedByte(uint8_t byte) {
    if (byte == serial_trig_letter) {
      call UartStream.disableReceiveInterrupt();
      post sendSchedule();
      // post sendTask();
    } else
      printf("Received: %c", byte);
      printf("Send %c to send actuation command\n", serial_trig_letter);
  }

  task void sendSchedule() {
    DrugSchedulerData *dsd = (DrugSchedulerData *)
      call Packet.getPayload(&packet, sizeof(DrugSchedulerData));
    dsd->time_interval = 2; //60 * 60;
    dsd->amount = 15;
    call AMSend.send(to_send_addr, &packet, sizeof(DrugSchedulerData));
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    printf("...Done\n");
    call UartStream.enableReceiveInterrupt();
  }

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    RadioDataMsg *rdm = (RadioDataMsg *) payload;
    printf("Remaining: %d\n", rdm->remaining_drug);
    return bufPtr;
  }

  event void RadioControl.stopDone(error_t err) {}

  async event void UartStream.sendDone(uint8_t*, uint16_t, error_t) {}

  async event void UartStream.receiveDone(uint8_t* buf, uint16_t len, error_t error) {}

}
