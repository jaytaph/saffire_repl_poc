all:
	flex test.l
	bison -d -v test.y
	gcc -g -DYYDEBUG=1 -c test.tab.c
	gcc -g -DYYDEBUG=1 -c main.c
	gcc -g -DYYDEBUG=1 -c lex.yy.c
	gcc -g -o test main.o test.tab.o lex.yy.o

clean:
	rm test.tab.c lex.yy.c *.o test || true
