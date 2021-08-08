all: airfoil_seq
airfoil_seq: airfoil_seq.cpp Makefile
	g++ airfoil_seq.cpp writeVTK.cpp -o airfoil_seq -O3 -fopenmp
