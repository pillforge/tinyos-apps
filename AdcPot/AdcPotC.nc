module AdcPotC {
  uses interface Boot;
}
implementation {

  event void Boot.booted(){
    printf("App Booted.\r\n");
  }

}
