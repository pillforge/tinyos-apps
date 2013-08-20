configuration InclinometerC {
  uses {
    interface Read<int16_t> as AccelRead;
    interface SplitControl as AccelControl;
  }
  provides {
    interface Read<float>;
    interface SplitControl;
  }
}
implementation {
  components InclinometerP;

  AccelRead = InclinometerP;
  Read = InclinometerP;
  AccelControl = InclinometerP;
  SplitControl = InclinometerP;

#ifdef INCLINOMETER_DEBUG
  components DiagMsgC;
  InclinometerP.DiagMsg -> DiagMsgC;
#endif
}
