generic module lis331dlh_P() {
  provides {
    interface Read<accel_t> as Accel;
    interface Msp430UsciConfigure;
    interface SplitControl;
    interface Init;
  }
  uses {
    interface BusyWait<TMicro, uint16_t>;
    interface SpiByte;
    interface Resource;
    interface HplMsp430GeneralIO as AccelCS;
  //  interface Timer<TMilli> as Timer0;
}
implementation {
  const msp430_usci_config_t msp430_usci_spi_accel_config = {
    /* Inactive high MSB-first 8-bit 3-pin master driven by SMCLK */
    /*ctl0 : UCCKPL | UCMSB | UCMST | UCSYNC,*/
    ctl0 : UCCKPH | UCMSB | UCMST | UCSYNC,
    ctl1 : UCSSEL__SMCLK,
    br0  : 16,      /* 32x Prescale, 1*2^19 (512 KiHz) */
    br1  : 0,
    mctl : 0,
    i2coa: 0
  };

  bool deviceReady = FALSE;
  accel_t reading;
  bool dataReady = FALSE;

  command error_t SplitControl.start(){
    deviceReady = FALSE;
    call Resource.request();
    return SUCCESS;
  }

  command error_t Init.init(){
    call AccelCS.makeOutput();
    call AccelCS.set();
    return SUCCESS;
  }

  uint8_t readRegister(uint8_t addr){
    uint8_t val;
    call AccelCS.clr();
    call SpiByte.write((addr));
    val = call SpiByte.write(0);
    call AccelCS.set();
    return val;
  }
    uint8_t writeRegister(uint8_t addr, uint8_t data){
    uint8_t val;
    call AccelCS.clr();
    call SpiByte.write(addr);
    val = call SpiByte.write(data);
    call AccelCS.set();
    return val;
  }

  event void Resource.granted(){
    uint8_t status;
    
    do {  
    status = readRegister(LIS331DLH_WHO_I_AM);
    }
    while(status != 0x032);

    // Loop until the ctrl register is set to what we want
    writeRegister(LIS331DLH_CTRL1,LIS331DLH_CTRL1_SET);
    call BusyWait.wait(30000);

   // call Timer0.startPeriodic(20)
    deviceReady = TRUE;
    signal SplitControl.startDone(SUCCESS);
  }

  task void readAccel_task(){
    atomic{
      if(dataReady){
        reading.x = (reading.x + readRegister(LIS331DLH_AXh))<<8 + readregister(LIS331DLH_AXl) ;
        reading.y = (reading.y + readRegister(LIS331DLH_AYh))<<8 + readregister(LIS331DLH_AYl) ;
        reading.z = (reading.z + readRegister(LIS331DLH_AZh))<<8 + readregister(LIS331DLH_AZl) ;
        signal Accel.readDone(SUCCESS, reading);
        dataReady = FALSE;
        reading.x =0;
        reading.y =0;
        reading.z =0;
      }
    }
  }


  async command const msp430_usci_config_t* Msp430UsciConfigure.getConfiguration() {
      return &msp430_usci_spi_accel_config;
  }

 // event void  Timer.fired(){
 //   dataReady = TRUE;
 //   post readAccel_task(); 
 //}

}
