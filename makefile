all:
	flex tema.l
	yacc -d -v tema.y
	gcc lex.yy.c y.tab.c -o exe
	./exe input.txt
