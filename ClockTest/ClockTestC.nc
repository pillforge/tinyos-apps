module ClockTestC {
  uses {
    interface Boot;
    interface HplMsp430GeneralIO as SmclkOut;
    interface HplMsp430GeneralIO as MclkOut;
    interface HplMsp430GeneralIO as AclkOut;

    interface Leds;
    interface Timer<TMilli> as Timer0;

  }

}
implementation {

  event void Boot.booted(){

    call SmclkOut.selectModuleFunc();
    call SmclkOut.makeOutput();

    call MclkOut.selectModuleFunc();
    call MclkOut.makeOutput();

    call AclkOut.selectModuleFunc();
    call AclkOut.makeOutput();

    call Timer0.startPeriodic(100);
  }

  event void Timer0.fired(){
    call Leds.led1Toggle();
  }

}
