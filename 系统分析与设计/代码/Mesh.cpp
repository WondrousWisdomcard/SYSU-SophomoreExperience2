#include "Mesh.h"
#include <string.h>
Mesh::Mesh(){
	this->empty = true;
	this->node = std::vector<coordinate_3d>();
	this->adj = std::vector<std::vector<int>>();
	this->face = std::vector<face_attr>();
	this->cell = std::vector<cell_attr>();
}

Mesh::~Mesh(){
	;
}

Mesh* Mesh::load_mesh_vtk(const char* pathname){
	Mesh *new_mesh=new Mesh();
    FILE *fp;
    if ( (fp = fopen(pathname,"r")) == NULL) { /*opne grid file*/
        printf("can't open file new_mesh.dat\n");
        exit(-1);
    }
	 if (fscanf(fp,"%d %d %d\n",&new_mesh->nnode,&new_mesh->ncell,&new_mesh->dimension) != 3) {
        printf("error reading from new_grid.dat\n"); exit(-1);
    }

	real x,y,z;
	for (int i=0; i<new_mesh->nnode; i++) {  
		coordinate_3d temp;
		if(new_mesh->dimension==3){
        	if (fscanf(fp,"%lf %lf %lf\n",&x, &y,&z) != 3) {    
            	printf("error reading from new_mesh.dat\n"); exit(-1);
        	}
			temp.x=x; temp.y=y; temp.z=z;
		}
		else if(new_mesh->dimension==2){
			if (fscanf(fp,"%lf %lf\n",&x, &y) != 2) {    
            	printf("error reading from new_mesh.dat\n"); exit(-1);
        	}
			temp.x=x; temp.y=y; temp.z=0;
		}
		new_mesh->node.push_back(temp);
    }
	for(int i=0; i<new_mesh->ncell;i++){
		cell_attr new_cell;
		if (fscanf(fp,"%d\n",&new_cell.cell_type)!=1){
			printf("error reading from new_mesh.dat\n");exit(-1);
		}
		int node_index;
		int nodenum=cellnode[new_cell.cell_type];
	
		for(int j=0;j<nodenum-1;j++){
			fscanf(fp,"%d",&node_index);
			new_cell.node_index.push_back(node_index);
		}
		fscanf(fp,"%d\n",&node_index);
		new_cell.node_index.push_back(node_index);
		new_mesh->cell.push_back(new_cell);
	}
	fclose(fp);
	return new_mesh;
}


void Mesh::store_mesh_vtk(const char* pathname,Mesh* mesh){
	printf("Writing OutputSimulation to ASCII file: %s \n",pathname);
  	FILE* fp;
  	fp = fopen(pathname, "w");
  	if(fp == NULL) {
    	printf("can't open file for write %s\n",pathname);
    	exit(-1);
  	}
	fprintf(fp,"%d %d %d\n",mesh->nnode,mesh->ncell,mesh->dimension);
	for(int i=0;i<mesh->nnode;i++){
		if(mesh->dimension==2){
			fprintf(fp,"%g %g %g \n",
				mesh->node[i].x,
				mesh->node[i].y,0.0);
		}
		else if(mesh->dimension==3){
			fprintf(fp,"%g %g %g \n",
				mesh->node[i].x,
				mesh->node[i].y,
				mesh->node[i].z);
		}
	}
	fprintf(fp,"\n");
	
	for(int i=0;i<mesh->ncell;i++){
		fprintf(fp,"%d\n",mesh->cell[i].cell_type);
		int cellnum=mesh->cellnode[cell[i].cell_type];
		for(int j=0;j<cellnum;j++){
			fprintf(fp,"%d ",mesh->cell[i].node_index[j]);
		}
		fprintf(fp,"\n");
	}
	fclose(fp);
}


void Mesh::parallel_looping(void(*k_func)(void*, void*, int), int* index, int index_size, void* arg, const char* element_name){
	int count = -1;
	if(element_name == NULL){
		if(index == NULL){
			return ;
		}else{
			#pragma omp parallel for
			for(int i = 0;i <= index_size-1;i++){
				k_func(arg, NULL, index[i]);
			}
			return ;
		}
	}
	if(strcmp(element_name, "node") == 0){
		if(index == NULL){
			#pragma omp parallel for
			for(int i = 0;i <= count-1;i++){
				k_func(arg, (void*)(&(this->node[i])), i);
			}
		}else{
			#pragma omp parallel for
			for(int i = 0;i <= index_size-1;i++){
				k_func(arg, (void*)(&(this->node[index[i]])), index[i]);
			}
		}
	}
	
	if(strcmp(element_name, "cell") == 0){
		if(index == NULL){
			#pragma omp parallel for
			for(int i = 0;i <= count-1;i++){
				k_func(arg, (void*)(&(this->cell[i])), i);
			}
		}else{
			#pragma omp parallel for
			for(int i = 0;i <= index_size-1;i++){
				k_func(arg, (void*)(&(this->cell[index[i]])), index[i]);
			}
		}
	}
	
	return ;

}
void Mesh::serial_looping(void(*k_func)(void*, void*, int), int* index, int index_size, void* arg, const char* element_name){
	int count = -1;
	if(element_name == NULL){
		if(index == NULL){
			return ;
		}else{
			for(int i = 0;i <= index_size-1;i++){
				k_func(arg, NULL, index[i]);
			}
			return ;
		}
	}
	if(strcmp(element_name, "node") == 0){
		if(index == NULL){
			for(int i = 0;i <= count-1;i++){
				k_func(arg, (void*)(&(this->node[i])), i);
			}
		}else{
			for(int i = 0;i <= index_size-1;i++){
				k_func(arg, (void*)(&(this->node[index[i]])), index[i]);
			}
		}
	}
	
	if(strcmp(element_name, "cell") == 0){
		if(index == NULL){
			for(int i = 0;i <= count-1;i++){
				k_func(arg, (void*)(&(this->cell[i])), i);
			}
		}else{
			for(int i = 0;i <= index_size-1;i++){
				k_func(arg, (void*)(&(this->cell[index[i]])), index[i]);
			}
		}
	}
	
	return ;
}
