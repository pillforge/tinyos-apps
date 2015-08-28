module DrugSchedulerP {
  provides interface DrugSchedulerI;
  uses interface Receive;
} implementation {
  command void DrugSchedulerI.init() {
    printf("Drug Scheduler init called\n");
  }
  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    printf("Drug Scheduler receive\n");
    return bufPtr;
  }
}
