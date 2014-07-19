OBJ = client.o

world: compile

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

compile: $(OBJ)
	$(CC) -o udphd $(OBJ)

clean:
	rm -f *.o *.so udphd

