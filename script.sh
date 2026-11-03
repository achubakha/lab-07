
#!/bin/bash

for testcase in 1 2 3 4
do
    rm -rf Testcase${testcase}Diff

    for file in Testcase${testcase}/*.1.txt
    do
        file2=${file%.1.txt}.2.txt

        if ! diff -q "$file" "$file2" > /dev/null
        then
            mkdir -p Testcase${testcase}Diff

            output=${file##*/}
            output=${output%.1.txt}Diff.txt

            diff -u "$file" "$file2" > "Testcase${testcase}Diff/$output"
        fi
    done
done
