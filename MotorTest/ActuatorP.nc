generic module ActuatorP (){
  uses{
    interface Msp430Compare as TimerCompare;
    interface Msp430TimerControl as TimerControl;
    interface HplMsp430GeneralIO as OutPin;
  }
  provides {
    interface Init;
    interface Actuate<uint8_t>;
  }
}
implementation {
  typedef msp430_compare_control_t cc_t;
  command error_t Init.init(){
    cc_t x;
    call TimerControl.setControlAsCompare();
    call TimerControl.enableEvents();

    call OutPin.selectModuleFunc();
    /*call OutPin.makeOutput();*/

    /*call OutPin.clr();*/

    x = call TimerControl.getControl();
    x.outmod = 7; // Enable set/reset output mode
    call TimerControl.setControl(x);
    return SUCCESS;
  }

  command error_t Actuate.write(uint8_t duty){
    call TimerCompare.setEvent(duty);
    return SUCCESS;
  }

  async event void TimerCompare.fired(){}
}

