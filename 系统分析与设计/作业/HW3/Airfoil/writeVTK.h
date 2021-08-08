#ifndef WRITE_VTK
#define WRITE_VTK

void WriteMeshToVTKAscii(const char *filename, double *nodeCoords_data, int nnode, int *cellsToNodes_data, int ncell, double *values_data);
void WriteMeshToVTKBinary(const char *filename, double *nodeCoords_data, int nnode, int *cellsToNodes_data, int ncell, double *values_data);
#endif
