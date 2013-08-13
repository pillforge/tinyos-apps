#include <math.h>
module InclinometerP {
  uses {
    interface Read<uint16_t> as AccelRead;
  }
  provides {
    interface Read<float>;
  }
}
implementation {

  const float normalization = 54.0;
  command error_t Read.read(){
    return call AccelRead.read();
  }

  event void AccelRead.readDone(error_t error, uint16_t data){
    float inclination = asin(((float) data)/normalization);
    signal Read.readDone(error, inclination);
  }
}
