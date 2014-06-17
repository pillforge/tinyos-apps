module RandomPwmValueGeneratorP {
  provides interface Get<uint16_t>;
  uses interface Random;
}
implementation {
  norace uint8_t current_ctrl_period = 0;

  // These currents were picked so that they are reasonable for our ADC. They are also reasonable for the range of
  // currents experienced by an MCR. The resistor used for setting the current is 50.2 ohms
  norace uint16_t pwm_clip = 4568; // Set current to 40 ma 40*.0502/3.6 * pwm_max
  norace uint16_t pwm_min = 23; // Set to 0.2 ma
  norace uint16_t pwm_max = 0x1fff;
  norace uint16_t pwm_val = 0;



  command uint16_t Get.get(){
    /*current_ctrl_period = (current_ctrl_period+1) % 10;*/
    current_ctrl_period = (current_ctrl_period+1) % 40;
    if(current_ctrl_period == 0){
      uint16_t rand_val = call Random.rand16() % (pwm_clip - pwm_min);
      pwm_val = rand_val + pwm_min;
    }
    return pwm_val;
  }
}

