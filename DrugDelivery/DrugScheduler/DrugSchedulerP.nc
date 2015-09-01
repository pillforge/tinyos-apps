module DrugSchedulerP {
  provides interface DrugSchedulerI;
  uses {
    interface Receive;
    interface Timer<TMilli>;
  }
} implementation {

  uint8_t remaining_drug = 100; // in percentage
  int time_interval;
  int amount;

  task void handleSchedule();

  command void DrugSchedulerI.init() {
    printf("Drug Scheduler init called\n");
  }

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    DrugSchedulerData *dsd = (DrugSchedulerData *) payload;
    time_interval = dsd->time_interval;
    amount = dsd->amount;
    printf("DrugSchedulerP.Receive.receive: every %d secods %d percent\n",
      time_interval, amount);

    call Timer.stop();  // If this is a new scheduler, stop the previous one
    post handleSchedule();
    signal DrugSchedulerI.scheduleReceived();
    return bufPtr;
  }

  task void handleSchedule() {
    call Timer.startOneShot(time_interval * 1000);
  }

  event void Timer.fired() {
    uint8_t c_amount = amount > remaining_drug ? remaining_drug : amount;
    if (remaining_drug > 0) {
      remaining_drug -= c_amount;
      signal DrugSchedulerI.release(c_amount);
      post handleSchedule();
    } else {
      printf("DrugSchedulerP.Timer.fired: No more remaining drug\n");
    }
  }

}
