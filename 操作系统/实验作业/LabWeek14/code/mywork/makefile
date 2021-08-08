a.out: pshmcon.o pshmwrite.o pshmread.o
	gcc -o a.out pshmcon.o -pthread
pshmcon.o: pshmcon.c pshmdata.h
	gcc -c pshmcon.c -pthread
pshmwrite.o: pshmwrite.c pshmdata.h
	gcc -o pshmwrite.o pshmwrite.c -pthread
pshmread.o: pshmread.c pshmdata.h
	gcc -o pshmread.o pshmread.c -pthread
clean:
	rm *.o
