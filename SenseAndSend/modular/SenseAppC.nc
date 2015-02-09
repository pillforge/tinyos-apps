configuration SenseAppC {
  
}

implementation {

  components SenseC;
  components Lsm330dlcC;
  SenseC.AccelRead -> Lsm330dlcC.AccelRead;

}
