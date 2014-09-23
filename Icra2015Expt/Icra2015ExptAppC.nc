configuration Icra2015ExptAppC{
}
implementation {
  components Icra2015ExptC, MainC;

  Icra2015ExptC -> MainC.Boot;
}