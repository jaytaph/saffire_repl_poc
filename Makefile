all:
	flex test.l
	bison -d -v test.y
	gcc -g -c test.tab.c
	gcc -g -c main.c
	gcc -g -c lex.yy.c
	gcc -g -o test main.o test.tab.o lex.yy.o
	cat test.a | ./test
