#include<stdio.h>
const int INF = 9999;

typedef struct Ele{ 
    int visited; // 并查集：0未访问，1已标记，2不再访问 
    int distance; // 根节点到此节点的距离
    int parents; // 父亲节点，为空时用-1表示
}Ele;

Ele Chart[6];

void initChart(int T){
    // Init Chart，T 表示最短路径树的根节点序号
    for(int i = 0; i < 6; i++){
        Chart[i].visited = 0;
        Chart[i].distance = INF;
        Chart[i].parents = -1;
    }
    Chart[T].visited = 1;
    Chart[T].distance = 0;
}

void printChart(int num){
    printf("From node %d to other\n",num+1);
    printf("node | distance | parents\n");
    for(int i = 0; i < 6; i++){
        printf("C%-3d | %8d | %7d\n",i+1,Chart[i].distance,Chart[i].parents+1);
    }
    printf("\n");
}

int main(){ 
    //Data 城市距离数组 – 邻接矩阵
    int C[6][6] = {{  0, 50,INF, 40, 25, 10},
                   { 50,  0, 15, 20,INF, 25},
                   {INF, 15,  0, 10, 20,INF},
                   { 40, 20, 10,  0, 10, 25},
                   { 25,INF, 20, 10,  0, 55},
                   { 10, 25,INF, 25, 55,  0}};
    int V[6] = { 0, 1, 2, 3, 4, 5};

    for(int T = 0; T < 6 ;T++){
        initChart(T);
        while(1){
            int now = -1, min = INF;
            for(int i = 0; i < 6; i++){
                if(Chart[i].visited == 1){
                    if(Chart[i].distance < min){
                        min = Chart[i].distance;
                        now = i;
                    }
                }
            }
            if(now == -1){
                break;
            }
            for(int i = 0; i < 6; i++){
                if(Chart[i].distance > C[now][i] + Chart[now].distance){
                    Chart[i].distance = C[now][i] + Chart[now].distance;
                    Chart[i].parents = now;
                    Chart[i].visited = 1;
                }
            }
            Chart[now].visited = 2; 
        }
        printChart(T);
    }
    return 0;
}
