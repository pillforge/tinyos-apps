#define sensor_read_t Accel_t

#include "Sense.h"

module SenseC {
  uses interface Boot;
  uses interface Timer<TMilli>;  
  uses interface Read<sensor_read_t> as AccelRead;
  provides interface Message<sensor_read_t>;
}

implementation {

  uint8_t sample_rate = sample_rate_value;

  event void Boot.booted() {
    call Timer.startPeriodic(sample_rate);
  }
  event void Timer.fired() {
    call AccelRead.read();
  }
  event void AccelRead.readDone(error_t err, sensor_read_t val) {
    signal Message.newMessage(val);    
  }

}
