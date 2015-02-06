#include "SenseAndSend.h"

module SenseC {
  uses interface Boot;
  uses interface Timer<TMilli>;  
  uses interface Read<Accel_t> as AccelRead;
  provides interface Message;
}

implementation {

  uint8_t sample_rate = 100;

  event void Boot.booted() {
    call Timer.startPeriodic(sample_rate);
  }
  event void Timer.fired() {
    call AccelRead.read();
  }
  event void AccelRead.readDone(error_t err, Accel_t val) {
    signal Message.newMessage(val);    
  }

}
