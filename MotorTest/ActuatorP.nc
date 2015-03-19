generic module ActuatorP (){
  uses{
    interface Msp430Compare as TimerCompare;
    interface Msp430TimerControl as TimerControl;
    interface HplMsp430GeneralIO as OutPin;
    interface Init as OutPinInit;
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
    // Generating interrupts slows down the entire system and interferes with some systems such as Uart
    // We can simply disable it since it's not needed
    call TimerControl.disableEvents();

    call OutPinInit.init();

    call OutPin.selectModuleFunc();

    x = call TimerControl.getControl();
    x.outmod = 7; // Enable set/reset output mode
    call TimerControl.setControl(x);
    return SUCCESS;
  }

  command error_t Actuate.write(uint8_t duty){
    call TimerCompare.setEvent(duty);
    return SUCCESS;
  }

  /**
   * By default, the ouptut pin is initialized as output and set as low. This can be changed by providing an overriding
   * command
   */
  default command error_t OutPinInit.init(){
    call OutPin.makeOutput();
    call OutPin.clr();
    return SUCCESS;
  }

  async event void TimerCompare.fired(){}
}

