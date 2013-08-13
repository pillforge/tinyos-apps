enum {
    ACCEL_MSG_ID = 6,
};

#define MAX_BUFFER_SIZE 256

typedef nx_struct AccelMsg{
    nx_uint16_t x;
}AccelMsg;
