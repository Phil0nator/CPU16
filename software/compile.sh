#!/bin/sh

rm __temp.asm

gcc -x assembler-with-cpp -nostdinc -CC -undef -P -E $1 > __temp.asm &&\
customasm __temp.asm -o $2 &&\
customasm __temp.asm -p -f annotated