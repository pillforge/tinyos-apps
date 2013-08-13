configuration ActuatorC {
  provides interface Actuate;
}
implementation {

  components ActuatorP;
  Actuate = ActuatorP;
}
