#include "svdpi.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
using namespace std;

int vcps_process_message(int msg_id,  long msg_time, int check){
	
	printf("Data Memory Write::MSG: %0d, TIME: %0d, CHECK: %0d\n", msg_id, msg_time, check);
	return 0;

}
