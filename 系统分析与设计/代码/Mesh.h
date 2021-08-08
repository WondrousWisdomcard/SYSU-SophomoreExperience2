#ifndef MESH_H
#define MESH_H
#include<map>
#include <vector>

#define real double



typedef struct {
	real x;
	real y;
	real z;
	void* attr;
}coordinate_3d;

typedef struct {
	std::vector<int> node_index;
	int cell_type;
	void* attr;
}cell_attr;

typedef struct {
	std::vector<int> node_index;
	void* attr;
}face_attr;


class Mesh
{
	public:
		bool empty;
		int dimension;
		int nnode,ncell;
		std::vector<coordinate_3d> node;
		std::vector<std::vector<int>> adj;
		std::vector<face_attr> face;
		std::vector<cell_attr> cell;
		static std::map<int,int> cellnode; /*key:celltype   value:nodenumber*/

	public:
		Mesh();
		virtual ~Mesh();
		Mesh* load_mesh_vtk(const char* pathname);
		void store_mesh_vtk(const char* pathname,Mesh* mesh);
		void parallel_looping(void(*k_func)(void*, void*, int), int* index, int index_size, void* arg, const char* element_name);
		void serial_looping(void(*k_func)(void*, void*, int), int* index, int index_size, void* arg, const char* element_name);

	protected:

	private:
		

};

#endif // MESH_H
