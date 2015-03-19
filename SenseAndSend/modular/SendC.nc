module SendC {
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface AMSend;
    interface Message;
    interface Packet;
  }
}

implementation {

  message_t packet;
  uint8_t to_send_addr = 1;
  Accel_t data;

  task void sendTask();

  task void sendTask() {
    SensorDataMsg* rcm = (SensorDataMsg*) call Packet.getPayload(&packet, sizeof(SensorDataMsg));
    rcm->sensor_data = data;
    call AMSend.send(to_send_addr, &packet, sizeof(SensorDataMsg));
  }

  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err){
    if (err != SUCCESS)
      call RadioControl.start();
  }

  event void Message.newMessage(Accel_t n_data) {
    data = n_data;
    post sendTask();
  }

  event void RadioControl.stopDone(error_t err) { }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) { }

}
