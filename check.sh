
#!/bin/bash

overall=0

for testcase in 1 2 3 4
do
    pass=1
    has_diff=0

    diff_dir="Testcase${testcase}Diff"

    # Check every original file pair
    for file in Testcase${testcase}/*.1.txt
    do
        file2=${file%.1.txt}.2.txt

        # Check that the matching file exists
        if [ ! -f "$file2" ]
        then
            pass=0
            continue
        fi

        # Determine whether the files differ
        if ! cmp -s "$file" "$file2"
        then
            has_diff=1

            output=${file##*/}
            output=${output%.1.txt}Diff.txt

            output_file="$diff_dir/$output"

            # Check that the expected output file exists
            if [ ! -f "$output_file" ]
            then
                pass=0
            else
                # Compare the diff output, ignoring the first two lines
                if ! diff -u <(diff -u "$file" "$file2" | tail -n +3) <(tail -n +3 "$output_file") > /dev/null
                then
                    pass=0
                fi
            fi
        else
            # Identical pairs must not have output files
            output=${file##*/}
            output=${output%.1.txt}Diff.txt

            if [ -f "$diff_dir/$output" ]
            then
                pass=0
            fi
        fi
    done

    # Check whether the Diff directory should exist
    if [ "$has_diff" -eq 1 ]
    then
        if [ ! -d "$diff_dir" ]
        then
            pass=0
        fi
    else
        if [ -e "$diff_dir" ] || [ -L "$diff_dir" ]
        then
            pass=0
        fi
    fi

    # Check for unexpected extra files in the Diff directory
    if [ -d "$diff_dir" ]
    then
        for output_file in "$diff_dir"/* "$diff_dir"/.[!.]* "$diff_dir"/..?*
        do
            if [ ! -e "$output_file" ] && [ ! -L "$output_file" ]
            then
                continue
            fi

            if [ ! -f "$output_file" ]
            then
                pass=0
                continue
            fi

            output_name=${output_file##*/}

            case "$output_name" in
                *Diff.txt)
                    version=${output_name%Diff.txt}
                    ;;
                *)
                    pass=0
                    continue
                    ;;
            esac

            original1="Testcase${testcase}/${version}.1.txt"
            original2="Testcase${testcase}/${version}.2.txt"

            if [ ! -f "$original1" ] || [ ! -f "$original2" ]
            then
                pass=0
                continue
            fi

            if cmp -s "$original1" "$original2"
            then
                pass=0
            fi
        done
    fi

    # Print the result for this testcase
    if [ "$pass" -eq 1 ]
    then
        echo "Testcase${testcase}: PASS"
    else
        echo "Testcase${testcase}: FAIL"
        overall=1
    fi
done

exit "$overall"
