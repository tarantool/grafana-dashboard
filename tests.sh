#!/bin/sh

jsonnet_fmt='-n 2 --max-blank-lines 2 --sort-imports --string-style s --comment-style s'
x=0

for i in `find ./dashboard ./tests -name '*.jsonnet' -or -name '*.libsonnet'`
do
    t="Formatting $i..."
    if [[ "$1" == "update" ]]; then
        jsonnetfmt -i $jsonnet_fmt $i
    fi
    if jsonnetfmt --test $jsonnet_fmt $i;
    then
        echo $t OK
    else
        echo $t NOK
        x=1
    fi
done

for i in tests/*/*.jsonnet
do
    json=$(dirname $i)/$( basename $i .jsonnet )_test_output.json
    json_e=$(dirname $i)/$( basename $i .jsonnet )_compiled.json
    t="Compiling $i..."
    if jsonnet -J . -J ./vendor $i > $json
    then
        echo $t OK
    else
        echo $t NOK
        x=1
        continue
    fi

    if [[ "$1" == "update" ]]; then cp $json $json_e; fi

    t="Checking $i..."
    if diff -urt $json_e $json
    then
        echo $t OK
    else
        echo $t NOK
        x=1
    fi
done

for i in tests/*/*.sh
do
    json=$(dirname $i)/$( basename $i .sh )_test_output.json
    json_e=$(dirname $i)/$( basename $i .sh )_compiled.json
    t="Executing $i..."
    if OUTPUT_STATIC_DASHBOARD=$json $i > /dev/null
    then
        echo $t OK
    else
        echo $t NOK
        x=1
        continue
    fi

    if [[ "$1" == "update" ]]; then cp $json $json_e; fi

    t="Checking $i..."
    if diff -urt $json_e $json
    then
        echo $t OK
    else
        echo $t NOK
        x=1
    fi
done
exit $x
