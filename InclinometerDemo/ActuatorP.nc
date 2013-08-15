module ActuatorP {
  uses{
    interface Msp430Compare as TimerCompare0; // used to force 8 bit mode
    interface Msp430Compare as TimerCompare1;
    interface Msp430Compare as TimerCompare2;
    interface Msp430TimerControl as TimerControl1;
    interface Msp430TimerControl as TimerControl2;
    interface Msp430Timer as TimerB;
    interface HplMsp430GeneralIO as OutPin1;
    interface HplMsp430GeneralIO as OutPin2;
  }
  provides {
    interface Init;
    interface Actuate<uint8_t>;
  }
}
implementation {
  enum {
    PWM_CLK_SRC_ACLK = 1,
    PWM_CLK_SRC_SMCLK= 2,
    TIMER_UP_MODE = 1,
  };
  typedef msp430_compare_control_t cc_t;
  command error_t Init.init(){
    cc_t x;
    call TimerCompare0.setEvent(0xff);

    call TimerControl1.setControlAsCompare();
    call TimerControl1.enableEvents();
    call TimerControl2.setControlAsCompare();
    call TimerControl2.enableEvents();

    call OutPin1.selectIOFunc();
    call OutPin1.makeOutput();
    call OutPin2.selectIOFunc();
    call OutPin2.makeOutput();

    call OutPin1.clr();
    call OutPin2.clr();

    // In UP mode, output is generated when the timer reaches TBxCLn and rolls from TBxCL0 to zero
    // Thus by setting TBxCL0 to 0xff, we are creating an 8 bit PWM.
    call TimerB.setMode(TIMER_UP_MODE);
    call TimerB.setClockSource(PWM_CLK_SRC_SMCLK);

    x = call TimerControl1.getControl();
    x.outmod = 7; // Enable set/reset output mode
    call TimerControl1.setControl(x);
    x = call TimerControl2.getControl();
    x.outmod = 7; // Enable set/reset output mode
    call TimerControl2.setControl(x);
    call TimerB.setMode(1); // Starts timer
    return SUCCESS;
  }

  command error_t Actuate.write(uint8_t duty, bool dir){
    // Make sure that one output is GPIO low while the other is in PWM mode
    if(dir){
      call OutPin2.selectIOFunc();
      call OutPin2.clr();

      call TimerCompare1.setEvent(duty);
      call OutPin1.selectModuleFunc();
    }else{
      call OutPin1.selectIOFunc();
      call OutPin1.clr();

      call TimerCompare2.setEvent(duty);
      call OutPin2.selectModuleFunc();
    }

    return SUCCESS;
  }

  async event void TimerCompare0.fired(){}
  async event void TimerCompare1.fired(){}
  async event void TimerCompare2.fired(){}
  async event void TimerB.overflow(){}
}

