interface HplCma3000d0x {
  /**
   * All registers are 8 bits.
   */
  command  uint8_t readRegister(uint8_t addr);
  command  uint8_t writeRegister(uint8_t addr, uint8_t data);
  async event void fired();
}
