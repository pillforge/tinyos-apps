#include "Inclinometer.h"
#include <math.h>
module InclinometerP {
  uses {
    interface Read<int16_t> as AccelRead;
    interface SplitControl as AccelControl;
  }
  provides {
    interface Read<float>;
    interface SplitControl;
  }
}
implementation {

  command error_t SplitControl.start(){
    return call AccelControl.start();
  }
  command error_t SplitControl.stop(){
    return call AccelControl.stop();
  }

  event void AccelControl.startDone(error_t error){
    signal SplitControl.startDone(error);
  }
  event void AccelControl.stopDone(error_t error){
    signal SplitControl.stopDone(error);
  }

  command error_t Read.read(){
    return call AccelRead.read();
  }

  event void AccelRead.readDone(error_t error, int16_t data){
    float inclination;
    // clip accelerometer data to +1g,-1g.
    if(data > NORMALIZATION)
      data = NORMALIZATION;
    else if (data < -NORMALIZATION)
      data = -NORMALIZATION;

    inclination = asin(((float) data)/NORMALIZATION) * 180.0/M_PI;
    signal Read.readDone(error, inclination);
  }
}
