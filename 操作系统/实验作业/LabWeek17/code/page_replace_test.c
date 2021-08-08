#include<stdio.h>
#include <stdlib.h>
#include <time.h>
  
int frame_num;
int refer_len;
int refer_str[100];

typedef struct node{
	int num;
	int refbit;
	int next;
	int prev;
}node;

void fifo(); // FIFO
void lrus(); // LRU Stack
void lrum(); // LRU Matrix
void scpr(); // Second Chance

// Without printf
int fifo_(); 
int lrus_(); 
int lrum_(); 
int scpr_(); 

int get_randon(int limit){ // range: (0,limit)
	int a;
	a = rand()%limit;
	return a;
}

void randon_test(int frame_num, int refer_len){
	srand((unsigned)time(NULL));
	printf("Random Test:\n");
	printf("We will have 1000 random tests to calculate average effect of each algorithm\n");
	printf("Enter the ulimt of page reference: ");
	int limit;
	scanf("%d",&limit);
	printf("Reference string of each test has %d elements, range from [0,%d)\n", refer_len, limit);
	double fifoss = 0, lrusss = 0, lrumss = 0, scprss = 0; // each algothrim swap sum.
	
	printf("+-----+------+------+------+------+\n");
	printf("| No. | FIFO | LRUS | LRUM | SCPR |\n");
	for(int i = 0; i < 1000; i++){
		for(int j = 0; j < refer_len; j++){
			refer_str[j] = get_randon(limit);
		}
		int fifot = fifo_();
		int lrust = lrus_();
		int lrumt = lrum_();
		int scprt = scpr_();
		if(i < 20){
		printf("| %03d |  %02d  |  %02d  |  %02d  |  %02d  |\n", i ,fifot, lrust, lrumt, scprt); 
		}
		if(i == 20){
		printf("| ... |  ..  |  ..  |  ..  |  ..  |\n"); 
		}
		fifoss += fifot;
		lrusss += lrust;
		lrumss += lrumt;
		scprss += scprt;
	}
	printf("+-----+------+------+------+------+\n");
	printf("| AVE |%02.3lf|%02.3lf|%02.3lf|%02.3lf|\n", fifoss/1000, lrusss/1000, lrumss/1000, scprss/1000);
	printf("+-----+------+------+------+------+\n");	
}

int main(){

	printf("\n---------Page-replacement Algorithm Simulation---------\n");
	printf("Enter the number of frame: ");
	scanf("%d", &frame_num);
	if(frame_num <= 0){
		printf("ERROR: Invalid Input\n");
		return 1;
	}
	printf("Enter the length of reference string: ");
	scanf("%d", &refer_len);
	if(refer_len <= 0 || refer_len > 100){
		printf("ERROR: Invalid Input\n");
		return 1;
	}
	
	int m;
	printf("Enter '0' to start manual test, or '1' to randon test: ");
	scanf("%d", &m);
	if(m == 1){
		randon_test(frame_num, refer_len);
		return 0;
	}
	
	printf("Enter the reference string: ");
	for(int i = 0; i < refer_len; i++){
		scanf("%d", &refer_str[i]);
	}
	for(int i = 0; i < refer_len; i++){
		if(refer_str[i] < 0){
			printf("ERROR: Invalid Input\n");
			return 1;
		}
	}
	printf("-------------------------------------------------------\n\n");
	
	printf("----------------------Choose Mode----------------------\n");
	int mode;
	printf("(1) FIFO\n");
	printf("(2) LRU (stack implementation)\n");
	printf("(3) LRU (matrix implementation)\n");
	printf("(4) Second-chance page-replacment\n");
	printf("(5) All of them sequently\n");
	printf("Choose one mode to run(1-5): ");
	scanf("%d", &mode);
	if(mode <= 0 || mode > 5){
		printf("ERROR: Invalid Input\n");
		return 1;
	}
	printf("-------------------------------------------------------\n\n");
	
	if(mode == 1){
		fifo();
	}
	else if(mode == 2){
		lrus();
	}
	else if(mode == 3){
		lrum();
	}
	else if(mode == 4){
		scpr();
	}
	else if(mode == 5){
		fifo();
		lrus();
		lrum();
		scpr();
	}
	else{
		printf("ERROR: Invalid Input\n");
		return 1;
	}
	return 0;
}

void fifo(){
	printf("---------------------FIFO PageSwap---------------------\n");
	int frames[frame_num];
	int oldest_ptr = 0;
	int used_frame_num = 0;
	int swap_times = 0;
	int temp = -1, hit;	
	for(int i = 0; i < frame_num; i++){
		frames[i] = -1;
	}
	for(int i = 0; i < refer_len; i++){
		int req = refer_str[i];
		int j = 0;
		for(j = 0; j < used_frame_num; j++){
			if(req == frames[j]){
				break;
			}
		}
		if(j == used_frame_num){
			hit = 0;
			if(used_frame_num < frame_num){
				used_frame_num++;
			}
			frames[oldest_ptr] = req;
			temp = oldest_ptr;
			oldest_ptr++;
			if(oldest_ptr == frame_num){
				oldest_ptr = 0;
			}
			swap_times++;
		}
		else{
			hit = 1;
		}		
		printf("No.%02d Request for Page %02d\n", i+1, req);
		printf("+-------+--------+----------------------------+\n");
		printf("| Frame | PageID | Info                       |\n");
		for(int k = 0; k < frame_num; k++){
			if(frames[k] == -1){
				printf("|   %d   |        | ", k);
			}
			else{
				printf("|   %d   |   %02d   | ", k, frames[k]);
			} 
			if(!hit && k == temp){
				printf("Page %02d Misses! Replace in |\n", req);
			}
			else if(hit && frames[k] == req){
				printf("Page %02d Hits!              |\n", req);
			}
			else{
				printf("                           |\n");
			}	
		}
		printf("+-------+--------+----------------------------+\n");
	}
	printf("\nFIFO algorithm finished, with %d swap times\n", swap_times);
	printf("-------------------------------------------------------\n\n");
}

void lrus(){
	printf("-----------Least-Recent-Used PageSwap (Stack)----------\n");
	struct node frames[frame_num];
	int head, tail, len, fen; 
	head = tail = -1;
	len = fen = 0;
	int swap_times = 0;
	int res_mode = 0;
	
	for(int i = 0; i < refer_len; i++){
		int req = refer_str[i];
		int temp = head;
		printf("No.%02d Request for Page %02d\n", i+1, req);
		while(temp != -1){
			if(frames[temp].num == req){
				res_mode =  1;
				if(len != 1 && temp != head){
					int p = frames[temp].prev;
					int n = frames[temp].next;
					frames[p].next = n;
					if(n != -1){
						frames[n].prev = p;
					}
					if(tail == temp){
						tail = p;
					}
					frames[temp].next = head;
					frames[temp].prev = -1;
					frames[head].prev = temp;
					head = temp;
				}
				break;
			}
			else{
				temp = frames[temp].next;
			}
		}
		if(temp == -1){
			swap_times++;
			if(len < frame_num){
				res_mode = 2;
				int now = fen;
				if(len == 0){
					head = now;
					tail = now;
					frames[now].num = req;
					frames[now].prev = -1;
					frames[now].next = -1;
				}
				else{
					frames[now].num = req;
					frames[now].prev = -1;
					frames[now].next = head;
					frames[head].prev = now;
					head = now;
				}
				fen++;
				len++;
			}
			else{	
				res_mode = 3;		
				if(tail == head){
					frames[head].num = req;
				}
				else{	
					int t = tail;
					int p = frames[t].prev;
					frames[p].next = -1;
					frames[t].prev = -1;
					frames[t].next = head;
					frames[t].num = req;
					frames[head].prev = t;
					head = t;
					tail = p;
				}
			}
		}
		
		printf("+-------+--------+-------------------------------------+\n");
		printf("| Frame | PageID | Info                                |\n");
		int k = head;
		while(k != -1){
			if(frames[k].num == -1){
				printf("|   %d   |        | ", k);
			}
			else{
				printf("|   %d   |   %02d   | ", k, frames[k].num);
			} 
			
			if(frames[k].num == req){
				if(res_mode == 1){
				printf("Page %02d Hits!                       |\n", req);	
				}
				else if(res_mode == 2){
					printf("Page %02d Misses! Fill Empty Frame    |\n", req);	
				}
				else if(res_mode == 3){
					printf("Page %02d Misses! Swap with LRU Frame |\n", req);
				}
			}
			else{
				printf("                                    |\n");
			}	

			k = frames[k].next;
		}
		printf("+-------+--------+-------------------------------------+\n");
	
		/*
		int k = head, count = 0;;
		printf("| Frame Stack: ");
		while(k != -1){
			count++;
			printf("%02d",frames[k].num);
			k = frames[k].next;
			if(k != -1){
				printf(" -> ");
			}
		}
		printf("\n");
		
		if(res_mode == 1){
			printf("| Page %02d Hits!\n", req);	
		}
		else if(res_mode == 2){
			printf("| Page %02d Misses! Fill Empty Frame\n", req);	
		}
		else if(res_mode == 3)
			printf("| Page %02d Misses! Swap with LRU Frame\n", req);{
		}
		*/
		printf("\n");
	}
		
	printf("LRU(Stack) algorithm finished, with %d swap times\n", swap_times);
	printf("-------------------------------------------------------\n\n");
}

void lrum(){
	printf("----------Least-Recent-Used PageSwap (Matrix)----------\n");
	int swap_times = 0;
	int res_mode = 0;
	int frames[frame_num];
	int frame_size = 0;
	for(int i = 0; i < frame_num; i++){
		frames[i] = -1;
	}
	
	int max = 1;
	for(int i = 0; i < refer_len; i++){
		if(max < refer_str[i]){
			max = refer_str[i];
		}
	}
	max++;
	
	int matrix[max][max];
	for(int i = 0; i < max; i++){
		for(int j = 0; j < max; j++){
			matrix[i][j] = 0;
		}
	}
	
	for(int i = 0; i < refer_len; i++){
		int req = refer_str[i];
		int j,k;
		printf("No.%02d Request for Page %02d\n", i+1, req);
		res_mode = 0;
		
		for(j = 0; j < frame_size; j++){
			if(frames[j] == req){
				res_mode = 1;
				for(k = 0; k < max; k++){
					matrix[req][k] = 1;
				} 
				for(k = 0; k < max; k++){
					matrix[k][req] = 0;
				}
				break;
			}
		}
		
		if(j == frame_size){
			swap_times++;
			if(frame_size < frame_num){
				frames[frame_size] = req;
				frame_size++;
				for(j = 0; j < max; j++){
					matrix[req][j] = 1;
				} 
				for(j = 0; j < max; j++){
					matrix[j][req] = 0;
				}
				res_mode = 2;
			}
			else{
				int min_rsum = 99999, min_row, temp;
				for(j = 0; j < max; j++){
					temp = 0;
					for(k = 0; k < max; k++){
						temp += matrix[j][k];
					}
					int inframe = 0;
					for(k = 0; k < frame_num; k++){
						if(j == frames[k]){
							inframe = 1;
						}
					}
					if(min_rsum > temp && inframe){
						min_rsum = temp;
						min_row = j;
					}
				}
				for(j = 0; j < frame_num; j++){
					if(frames[j] == min_row){
						res_mode = 3;
						frames[j] = req;
						break;
					}
				}
				for(k =  0; k < max; k++){
					matrix[req][k] = 1;
				} 
				for(k = 0; k < max; k++){
					matrix[k][req] = 0;
				}
			}
		}	
		printf("+ Matrix ");	
		for(j = 4; j < max; j++){
			printf("--");
		}
		if(max >= 4){
			printf("-+\n");
		}
		
		for(j = 0; j < max; j++){
			printf("| ");
			for(k = 0; k< max; k++){
				printf("%d ", matrix[j][k]);
			}
			printf("|\n");
		}
		printf("+-------+--------+-------------------------------------+\n");
		printf("| Frame | PageID | Info                                |\n");
		for(k = 0; k < frame_num; k++){
			if(frames[k] == -1){
				printf("|   %d   |        | ", k);
			}
			else{
				printf("|   %d   |   %02d   | ", k, frames[k]);
			} 
			
			if(frames[k] == req){
				if(res_mode == 1){
				printf("Page %02d Hits!                       |\n", req);	
				}
				else if(res_mode == 2){
					printf("Page %02d Misses! Fill Empty Frame    |\n", req);	
				}
				else if(res_mode == 3){
					printf("Page %02d Misses! Swap with LRU Frame |\n", req);
				}
			}
			else{
				printf("                                    |\n");
			}
		}
		printf("+-------+--------+-------------------------------------+\n");
		printf("\n");
	}
	printf("LRU(Matrix) algorithm finished, with %d swap times\n", swap_times);
	printf("-------------------------------------------------------\n\n");
}

void scpr(){
	printf("------------Second Chance PageSwap (Matrix)------------\n");
	int swap_times = 0;
	int res_mode = 0;

	int i,j,k;
	
	struct node cirqueue[frame_num];
	int clock = 0;
	for(i = 0; i < frame_num; i++){
		cirqueue[i].num = -1;
		cirqueue[i].refbit = 0;
	}
	
	for(i = 0; i < refer_len; i++){
		int req = refer_str[i];
		printf("No.%02d Request for Page %02d\n", i+1, req);
		res_mode = 0;
		
		for(j = 0; j < frame_num; j++){
			if(cirqueue[j].num == req){
				cirqueue[j].refbit = 1;
				res_mode = 1;
				break;
			} 
		}
		if(j == frame_num){
			swap_times++;
			do{
				if(cirqueue[clock].refbit == 0){
					if(cirqueue[clock].num == -1){
						res_mode = 2;
					}
					else{
						res_mode = 3;
					}
					cirqueue[clock].num = req;
					cirqueue[clock].refbit = 1;
					clock++;
					if(clock == frame_num){
						clock = 0;
					}
					break;
				}
				else{
					cirqueue[clock].refbit = 0;
					clock++;
					if(clock == frame_num){
						clock = 0;
					}
				}
			}while(1);
		}
		
		printf("+-------+--------+-----+--------------------------------------+\n");
		printf("| Frame | PageID | Use | Info                                 |\n");
		for(k = 0; k < frame_num; k++){
			if(cirqueue[k].num == -1){
				printf("|   %d   |        |     | ", k);
			}
			else{
				printf("|   %d   |   %02d   |  %d  | ", k, cirqueue[k].num, cirqueue[k].refbit);
			} 
			
			if(cirqueue[k].num == req){
				if(res_mode == 1){
				printf("Page %02d Hits!                        |\n", req);	
				}
				else if(res_mode == 2){
					printf("Page %02d Misses! Fill Empty Frame     |\n", req);	
				}
				else if(res_mode == 3){
					printf("Page %02d Misses! Swap into this Frame |\n", req);
				}
			}
			else{
				printf("                                     |\n");
			}
		}
		printf("+-------+--------+-----+--------------------------------------+\n");
		printf("\n");
	}
	printf("Second-chance algorithm finished, with %d swap times\n", swap_times);
	printf("-------------------------------------------------------\n\n");
}

int fifo_(){
	int frames[frame_num];
	int oldest_ptr = 0;
	int used_frame_num = 0;
	int swap_times = 0;
	int temp = -1, hit;	
	for(int i = 0; i < frame_num; i++){
		frames[i] = -1;
	}
	for(int i = 0; i < refer_len; i++){
		int req = refer_str[i];
		int j = 0;
		for(j = 0; j < used_frame_num; j++){
			if(req == frames[j]){
				break;
			}
		}
		if(j == used_frame_num){
			hit = 0;
			if(used_frame_num < frame_num){
				used_frame_num++;
			}
			frames[oldest_ptr] = req;
			temp = oldest_ptr;
			oldest_ptr++;
			if(oldest_ptr == frame_num){
				oldest_ptr = 0;
			}
			swap_times++;
		}
		else{
			hit = 1;
		}	
	}	
	return swap_times;
}

int lrus_(){
	struct node frames[frame_num];
	int head, tail, len, fen; 
	head = tail = -1;
	len = fen = 0;
	int swap_times = 0;
	int res_mode = 0;
	
	for(int i = 0; i < refer_len; i++){
		int req = refer_str[i];
		int temp = head;
		
		while(temp != -1){
			if(frames[temp].num == req){
				res_mode =  1;
				if(len != 1 && temp != head){
					int p = frames[temp].prev;
					int n = frames[temp].next;
					frames[p].next = n;
					if(n != -1){
						frames[n].prev = p;
					}
					if(tail == temp){
						tail = p;
					}
					frames[temp].next = head;
					frames[temp].prev = -1;
					frames[head].prev = temp;
					head = temp;
				}
				break;
			}
			else{
				temp = frames[temp].next;
			}
		}
		if(temp == -1){
			swap_times++;
			if(len < frame_num){
				res_mode = 2;
				int now = fen;
				if(len == 0){
					head = now;
					tail = now;
					frames[now].num = req;
					frames[now].prev = -1;
					frames[now].next = -1;
				}
				else{
					frames[now].num = req;
					frames[now].prev = -1;
					frames[now].next = head;
					frames[head].prev = now;
					head = now;
				}
				fen++;
				len++;
			}
			else{	
				res_mode = 3;		
				if(tail == head){
					frames[head].num = req;
				}
				else{	
					int t = tail;
					int p = frames[t].prev;
					frames[p].next = -1;
					frames[t].prev = -1;
					frames[t].next = head;
					frames[t].num = req;
					frames[head].prev = t;
					head = t;
					tail = p;
				}
			}
		}
	}
	return swap_times;
}

int lrum_(){
	int swap_times = 0;
	int res_mode = 0;
	int frames[frame_num];
	int frame_size = 0;
	for(int i = 0; i < frame_num; i++){
		frames[i] = -1;
	}
	
	int max = 1;
	for(int i = 0; i < refer_len; i++){
		if(max < refer_str[i]){
			max = refer_str[i];
		}
	}
	max++;
	
	int matrix[max][max];
	for(int i = 0; i < max; i++){
		for(int j = 0; j < max; j++){
			matrix[i][j] = 0;
		}
	}
	
	for(int i = 0; i < refer_len; i++){
		int req = refer_str[i];
		int j,k;
		res_mode = 0;
		
		for(j = 0; j < frame_size; j++){
			if(frames[j] == req){
				res_mode = 1;
				for(k = 0; k < max; k++){
					matrix[req][k] = 1;
				} 
				for(k = 0; k < max; k++){
					matrix[k][req] = 0;
				}
				break;
			}
		}
		
		if(j == frame_size){
			swap_times++;
			if(frame_size < frame_num){
				frames[frame_size] = req;
				frame_size++;
				for(j = 0; j < max; j++){
					matrix[req][j] = 1;
				} 
				for(j = 0; j < max; j++){
					matrix[j][req] = 0;
				}
				res_mode = 2;
			}
			else{
				int min_rsum = 99999, min_row, temp;
				for(j = 0; j < max; j++){
					temp = 0;
					for(k = 0; k < max; k++){
						temp += matrix[j][k];
					}
					int inframe = 0;
					for(k = 0; k < frame_num; k++){
						if(j == frames[k]){
							inframe = 1;
						}
					}
					if(min_rsum > temp && inframe){
						min_rsum = temp;
						min_row = j;
					}
				}
				for(j = 0; j < frame_num; j++){
					if(frames[j] == min_row){
						res_mode = 3;
						frames[j] = req;
						break;
					}
				}
				for(k =  0; k < max; k++){
					matrix[req][k] = 1;
				} 
				for(k = 0; k < max; k++){
					matrix[k][req] = 0;
				}
			}
		}	
	}
	return swap_times;
}

int scpr_(){
	int swap_times = 0;
	int res_mode = 0;

	int i,j,k;
	
	struct node cirqueue[frame_num];
	int clock = 0;
	for(i = 0; i < frame_num; i++){
		cirqueue[i].num = -1;
		cirqueue[i].refbit = 0;
	}
	
	for(i = 0; i < refer_len; i++){
		int req = refer_str[i];
		
		res_mode = 0;
		
		for(j = 0; j < frame_num; j++){
			if(cirqueue[j].num == req){
				cirqueue[j].refbit = 1;
				res_mode = 1;
				break;
			} 
		}
		if(j == frame_num){
			swap_times++;
			do{
				if(cirqueue[clock].refbit == 0){
					if(cirqueue[clock].num == -1){
						res_mode = 2;
					}
					else{
						res_mode = 3;
					}
					cirqueue[clock].num = req;
					cirqueue[clock].refbit = 1;
					clock++;
					if(clock == frame_num){
						clock = 0;
					}
					break;
				}
				else{
					cirqueue[clock].refbit = 0;
					clock++;
					if(clock == frame_num){
						clock = 0;
					}
				}
			}while(1);
		}
	}
	return swap_times;
}
