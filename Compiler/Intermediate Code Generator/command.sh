yacc -d -y parser.y -o parser.cpp
echo 'Generated the parser cpp file as well the header file'

g++ -g -w -c -o parser.o parser.cpp
echo 'Generated the parser object file'

flex -o scanner.cpp scanner.l
echo 'Generated the scanner cpp file'

g++ -g -w -c -o scanner.o scanner.cpp
echo 'Generated the scanner object file'

g++ parser.o scanner.o -lfl -o output.out
echo 'All ready, running'
echo 'Use command $./output.out <file_name> to generate asm code'
# ./output.out ./input.c