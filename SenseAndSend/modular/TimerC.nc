#include "SenseAndSend.h"

module TimerC {
  uses interface Boot;
  uses interface Timer<TMilli>;
  provides interface Message;
}

implementation {

  uint8_t sample_rate = 100;
  Accel_t data;

  event void Boot.booted() {
    call Timer.startPeriodic(sample_rate);
  }

  event void Timer.fired() {
    signal Message.newMessage(data);
  }

}
