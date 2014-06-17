module ConstantPwmValueGeneratorP {
  provides interface Get<uint16_t>;
}
implementation {
  const uint16_t const_pwm_100ua =  ((uint32_t)0.1*0x1fff*0.0502)/3.6;
  const uint16_t const_pwm_5ma =  ((uint32_t)5*0x1fff*0.0502)/3.6;
  const uint16_t const_pwm_10ma = ((uint32_t)10*0x1fff*0.0502)/3.6;
  const uint16_t const_pwm_20ma = ((uint32_t)20*0x1fff*0.0502)/3.6;
  const uint16_t const_pwm_30ma = ((uint32_t)30*0x1fff*0.0502)/3.6;
  const uint16_t const_pwm_40ma = ((uint32_t)40*0x1fff*0.0502)/3.6;

  command uint16_t Get.get(){
    /*return const_pwm_100ua;*/
    return const_pwm_40ma;
  }
}

