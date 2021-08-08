#include<stdio.h>
#include<math.h>
#include<stdlib.h>
#include<time.h>
  
int fcfs(int* request, int len);
int sstf(int* request, int len);

int scan(int* request, int len, int dir);
int c_scan(int* request, int len, int dir);

int look(int* request, int len, int dir);
int c_look(int* request, int len, int dir);

int get_random(int limit){
	int a;
	a = rand()%limit;
	return a;
}

void random_test(int times){
	srand((unsigned)time(NULL));

	int len = 10;
	int dir = 0;
	int req[len];
	
	int fcfs_n = 0;
	int sstf_n = 0;
	int scan_n = 0;
	int c_scan_n = 0;
	int look_n = 0;
	int c_look_n = 0;
	
	for(int i = 0; i < times; i++){
	
		for(int i = 0; i < 10; i++){
			req[i] = get_random(200);
		}
		
		dir = get_random(2);
		fcfs_n += fcfs(req, len);
		sstf_n += sstf(req, len);
		scan_n += scan(req, len, dir);
		c_scan_n += c_scan(req, len, dir);
		look_n += look(req, len, dir);
		c_look_n += c_look(req, len, dir);
	}
	
	printf("+--------------------------+\n");
	printf("|Average res of random test|\n");
	printf("+--------+--------+--------+\n");
	printf("|  FCFS  |  SSTF  |  SCAN  |\n");
	printf("|  %4d  |  %4d  |  %4d  |\n", fcfs_n/times, sstf_n/times, scan_n/times);
	printf("+--------+--------+--------+\n");
	printf("| C-SCAN |  LOOK  | C-LOOK |\n");
	printf("|  %4d  |  %4d  |  %4d  |\n", c_scan_n/times, look_n/times, c_look_n/times);
	printf("+--------+--------+--------+\n");
	
}

int main(int argc, char* argvs[]){
	
	if(argc == 2){
		int times;
		printf("Enter the test times of random test: ");
		scanf("%d", &times);
		if(times <= 0){
			printf("Invalid Input");
			return 1;
		}
		random_test(times);
		printf("%d Random Test, Each test has 10 random request and random direction\n", times);
		return 0;
	}
	
	int len;
	printf("Enter the length of cylinder request: ");
	scanf("%d",&len);
	if(len <= 0){
		printf("Invalid Input");
		return 1;
	}
	
	len += 1;
	int req[len];
	
	printf("Enter the initial position of disk head: ");
	scanf("%d",&req[0]);
	if(req[0] < 0 || req[0] > 199){
		printf("Invalid Input");
		return 1;
	}
		
	int dir;
	printf("Enter the direction of disk head(out: 0 or in: 1): ");
	scanf("%d",&dir);
	if(dir != 0 && dir != 1){
		printf("Invalid Input");
		return 1;
	}
		
	printf("Enter the cylinder request string(from 0 to 199): ");
	for(int i = 1; i < len; i++){
		scanf("%d",&req[i]);
		if(req[i] < 0 || req[i] > 199){
			printf("Invalid Input");
			return 1;
		}
	}	
	
	int fcfs_n = fcfs(req, len);
	int sstf_n = sstf(req, len);
	
	int scan_n = scan(req, len, dir);
	int c_scan_n = c_scan(req, len, dir);
	
	int look_n = look(req, len, dir);
	int c_look_n = c_look(req, len, dir);
	
	printf("+--------------------------+\n");
	printf("|Total cyclinder-num moved |\n");
	printf("+--------+--------+--------+\n");
	printf("|  FCFS  |  SSTF  |  SCAN  |\n");
	printf("|  %4d  |  %4d  |  %4d  |\n", fcfs_n, sstf_n, scan_n);
	printf("+--------+--------+--------+\n");
	printf("| C-SCAN |  LOOK  | C-LOOK |\n");
	printf("|  %4d  |  %4d  |  %4d  |\n", c_scan_n, look_n, c_look_n);
	printf("+--------+--------+--------+\n");
	
	return 0;
}

int fcfs(int* request, int len){
	int sum = 0;
	printf("[  FCFS  ] ");
	for(int i = 0; i < len; i++){
		printf("%3d ", request[i]);
		if(i > 0){
			sum += fabs(request[i] - request[i-1]);
		}
	}
	printf("\n");
	return sum;
}
int sstf(int* request, int len){
	int sum = 0;
	int used_n = 0;
	int used[len];
	for(int i = 0; i < len; i++){
		used[i] = 0;
	}
	printf("[  SSTF  ] ");
	int now = 0;
	int now_pos = request[now];
	used[now] = 1;
	used_n++;
	printf("%3d ", now_pos);
	
	while(used_n < len){
		int min = 99999, next = -1;
		for(int i = 0; i < len; i++){
			if(used[i] == 0 && fabs(request[i] - now_pos) < min){
				min = fabs(request[i] - now_pos);
				next = i;
			}
		}
		sum += fabs(request[next] - now_pos);
		now = next;
		now_pos = request[now];
		used[now] = 1;
		used_n++;
		printf("%3d ", now_pos);
	}
	printf("\n");
	return sum;
}

int scan(int* request, int len, int dir){
	int sum = 0;
	int ini;
	int ini_pos = request[0];
	int temp[len];
	printf("[  SCAN  ] ");
	for(int i = 0; i < len; i++){
		temp[i] = request[i];
	}
	for(int i = 0; i < len; i++){
		for(int j = 0; j < len; j++){
			if(temp[i] < temp[j]){
				int t = temp[i];
				temp[i] = temp[j];
				temp[j] = t;
			}
		}
	}
	for(int i = 0; i < len; i++){ 
		if(temp[i] == ini_pos){
			ini = i;
			break;
		}
	}
	
	if(dir == 0){
		sum += temp[ini];
		sum += temp[len-1];
		for(int i = ini; i >= 0; i--){
			printf("%3d ",temp[i]);
		}
		if(temp[0] != 0){
			printf("  0 ");
		}
		for(int i = ini+1; i < len; i++){
			printf("%3d ",temp[i]);
		}
	}
	else{
		sum += (199 - temp[ini]);
		sum += (199 - temp[0]);
		for(int i = ini; i < len; i++){
			printf("%3d ",temp[i]);
		}
		if(temp[len - 1] != 0){
			printf("199 ");
		}
		for(int i = ini - 1; i >= 0; i--){
			printf("%3d ",temp[i]);
		}
	}
	printf("\n");
	return sum;
}
int c_scan(int* request, int len, int dir){
	int sum = 0;
	int ini;
	int ini_pos = request[0];
	int temp[len];
	printf("[ C-SCAN ] ");
	for(int i = 0; i < len; i++){
		temp[i] = request[i];
	}
	for(int i = 0; i < len; i++){
		for(int j = 0; j < len; j++){
			if(temp[i] < temp[j]){
				int t = temp[i];
				temp[i] = temp[j];
				temp[j] = t;
			}
		}
	}
	for(int i = 0; i < len; i++){ 
		if(temp[i] == ini_pos){
			ini = i;
			break;
		}
	}
	
	if(dir == 0){
		sum += temp[ini];
		sum += 199;
		if(ini != len - 1){
			sum += (199 - temp[ini + 1]);
		}

		for(int i = ini; i >= 0; i--){
			printf("%3d ",temp[i]);
		}
		if(temp[0] != 0){
			printf("  0 ");
		}
		if(temp[len-1] != 199){
			printf("199 ");
		}
		for(int i = len-1; i > ini; i--){
			printf("%3d ",temp[i]);
		}
	}
	else{
		sum += (199 - temp[ini]);
		sum += 199;
		if(ini != 0){
			sum += temp[ini-1];
		}
		
		for(int i = ini; i < len; i++){
			printf("%3d ",temp[i]);
		}
		if(temp[len-1] != 199){
			printf("199 ");
		}
		if(temp[0] != 0){
			printf("  0 ");
		}
		for(int i = 0; i < ini; i++){
			printf("%3d ",temp[i]);
		}
	}
	printf("\n");
	return sum;
}

int look(int* request, int len, int dir){
	int sum = 0;
	int ini;
	int ini_pos = request[0];
	int temp[len];
	printf("[  LOOK  ] ");
	for(int i = 0; i < len; i++){
		temp[i] = request[i];
	}
	for(int i = 0; i < len; i++){
		for(int j = 0; j < len; j++){
			if(temp[i] < temp[j]){
				int t = temp[i];
				temp[i] = temp[j];
				temp[j] = t;
			}
		}
	}
	for(int i = 0; i < len; i++){ 
		if(temp[i] == ini_pos){
			ini = i;
			break;
		}
	}
	
	if(dir == 0){
		sum += temp[ini] - temp[0];
		sum += temp[len-1] - temp[0];
		for(int i = ini; i >= 0; i--){
			printf("%3d ",temp[i]);
		}
		for(int i = ini+1; i < len; i++){
			printf("%3d ",temp[i]);
		}
	}
	else{
		sum += (temp[len-1] - temp[ini]);
		sum += (temp[len-1] - temp[0]);
		for(int i = ini; i < len; i++){
			printf("%3d ",temp[i]);
		}
		for(int i = ini - 1; i >= 0; i--){
			printf("%3d ",temp[i]);
		}
	}
	printf("\n");
	return sum;
}

int c_look(int* request, int len, int dir){
	int sum = 0;
	int ini;
	int ini_pos = request[0];
	int temp[len];
	printf("[ C-LOOK ] ");
	for(int i = 0; i < len; i++){
		temp[i] = request[i];
	}
	for(int i = 0; i < len; i++){
		for(int j = 0; j < len; j++){
			if(temp[i] < temp[j]){
				int t = temp[i];
				temp[i] = temp[j];
				temp[j] = t;
			}
		}
	}
	for(int i = 0; i < len; i++){ 
		if(temp[i] == ini_pos){
			ini = i;
			break;
		}
	}
	
	if(dir == 0){
		sum += (temp[ini] - temp[0]);
		sum += (temp[len-1] - temp[0]);
		if(ini != len - 1){
			sum += (temp[len-1] - temp[ini+1]);
		}
		
		for(int i = ini; i >= 0; i--){
			printf("%3d ",temp[i]);
		}
		for(int i = len-1; i > ini; i--){
			printf("%3d ",temp[i]);
		}
	}
	else{
		sum += (temp[len-1] - temp[ini]);
		sum += (temp[len-1] - temp[0]);
		if(ini != 0){
			sum += (temp[ini-1] - temp[0]);
		}
		
		for(int i = ini; i < len; i++){
			printf("%3d ",temp[i]);
		}
		for(int i = 0; i < ini; i++){
			printf("%3d ",temp[i]);
		}
	}
	printf("\n");
	return sum;
}

