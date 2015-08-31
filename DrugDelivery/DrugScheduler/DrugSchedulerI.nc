#include "DrugScheduler.h"
interface DrugSchedulerI {
  event void scheduleReceived();
  command void init();
  event void release();
}
