module MotorDriverP {
  uses{
    interface Msp430Compare as TimerCompare; // used to force 8 bit mode
    interface Msp430Timer as MspTimer;
    interface Init as SubInit;
  }
  provides {
    interface Init;
  }
}
implementation {
  enum {
    PWM_CLK_SRC_ACLK = 1,
    PWM_CLK_SRC_SMCLK= 2,
    TIMER_UP_MODE = 1,
  };
  command error_t Init.init(){
    call TimerCompare.setEvent(0xff);

    call MspTimer.setMode(TIMER_UP_MODE);
    call MspTimer.setClockSource(PWM_CLK_SRC_SMCLK);
    call MspTimer.disableEvents();

    // Initialize all actuators
    call SubInit.init();

    call MspTimer.setMode(1); // Starts timer
    return SUCCESS;
  }

  async event void TimerCompare.fired(){}
  async event void MspTimer.overflow(){}
}


