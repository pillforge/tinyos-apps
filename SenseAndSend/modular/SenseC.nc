#include "SenseAndSend.h"

module SenseC {
  uses interface Read<Accel_t> as AccelRead;
  provides interface Message;
  uses interface Message as MessageReceive;
}

implementation {

  event void AccelRead.readDone(error_t err, Accel_t val) {
    signal Message.newMessage(val);    
  }
  event void MessageReceive.newMessage(Accel_t data) {
    call AccelRead.read();
  }

}
