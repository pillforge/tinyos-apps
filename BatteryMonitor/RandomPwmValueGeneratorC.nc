configuration RandomPwmValueGeneratorC {
  provides interface Get<uint16_t>;
}
implementation {
  components RandomC, RandomPwmValueGeneratorP;
  RandomPwmValueGeneratorP.Random -> RandomC;
  Get = RandomPwmValueGeneratorP;
}
