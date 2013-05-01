all:
	flex test.l
	bison -d -v test.y
	gcc -c test.tab.c
	gcc -c main.c
	gcc -c lex.yy.c
	gcc -o test main.o test.tab.o lex.yy.o
	cat test.a | ./test
