#include "Send.h"

module SendC {
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface AMSend;
    interface Message<send_t>;
    interface Packet;
  }
}

implementation {

  message_t packet;
  uint8_t to_send_addr = to_send_addr_value;
  send_t data;

  task void sendTask();

  task void sendTask() {
    SendDataMsg* rcm = (SendDataMsg*) call Packet.getPayload(&packet, sizeof(SendDataMsg));
    rcm->sensor_data = data;
    call AMSend.send(to_send_addr, &packet, sizeof(SendDataMsg));
  }

  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err){
    if (err != SUCCESS)
      call RadioControl.start();
  }

  event void Message.newMessage(send_t n_data) {
    data = n_data;
    post sendTask();
  }

  event void RadioControl.stopDone(error_t err) { }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) { }

}
