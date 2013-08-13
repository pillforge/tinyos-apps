configuration InclinometerC {
  uses {
    interface Read<uint16_t> as AccelRead;
  }
  provides {
    interface Read<float>;
  }
}
implementation {
  components InclinometerP;

  AccelRead = InclinometerP;
  Read = InclinometerP;

}
