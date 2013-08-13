interface AngleControl {
  
  command error_t setAngle(uint8_t val);

  event void setAngleDone(error_t);

} 
