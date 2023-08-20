flex lisp.l
yacc -d lisp.y
g++ lex.yy.c y.tab.c -ll

sleep 2

test_execv=./a.out
for file in ./test_data/[0-9]* ./test_data/b[1-4]*; do
    echo $file >> ./result
    $test_execv < $file >> ./result
done    