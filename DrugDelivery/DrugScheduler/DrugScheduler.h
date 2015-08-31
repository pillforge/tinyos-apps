#ifndef DRUGSCHEDULER_H
#define DRUGSCHEDULER_H

enum {
  AM_RADIODRUGSCHEDULERMSG = 13
};

typedef nx_struct DrugSchedulerData {
  nx_uint32_t time_interval; // in seconds
  nx_uint8_t amount; // in percentage
} DrugSchedulerData;

#endif
