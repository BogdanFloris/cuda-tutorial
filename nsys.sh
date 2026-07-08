#!/bin/bash

trace="--trace=cuda"
sample="--sample=none"
ctxsw="--cpuctxsw=none"
output="report"
report="cuda_gpu_sum"

# Usage function
usage() {
    echo "Usage: $0 [-t trace] [-s sample] [-c ctxsw] [-o output] [-r report]"
    echo "  -t trace   : Set the trace option (default: --trace=cuda)"
    echo "  -s sample  : Set the sample option (default: --sample=none)"
    echo "  -c ctxsw   : Set the context switch option (default: --cpuctxsw=none)"
    echo "  -o output  : Set the output file name (default: report)"
    echo "  -r report  : Set the report name (default: cuda_gpu_sum)"
    exit 1
}

# Parse command line options
while getopts "t:s:c:o:r:" opt; do
    case $opt in
        t) trace="--trace=$OPTARG" ;;
        s) sample="--sample=$OPTARG" ;;
        c) ctxsw="--cpuctxsw=$OPTARG" ;;
        o) output="$OPTARG" ;;
        r) report="$OPTARG" ;;
        \?) usage ;;
    esac
done

# Shift the processed options away
shift $((OPTIND -1))

# Run the nsys profile command
LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH nsys profile $trace $sample $ctxsw --force-overwrite=true -o $output "$@"

# Run the nsys stats command
nsys stats --force-export=true -r $report $output.nsys-rep
