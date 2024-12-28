# run a set of processes in parallel if gnu parallel or xargs are available, otherwise run in series
run_parallel () {
    local cpu_cores=$(sysctl -n hw.logicalcpu)
    local process=$1;

    echo "CPU Cores: $cpu_cores"
    echo "Process: $process"

    # Check if GNU Parallel is available
    if command -v parallel > /dev/null; then
        echo "GNU Parallel is available. Running in parallel..."
        parallel --ungroup -j $cpu_cores $process {}
    elif command -v xargs > /dev/null; then
        echo "GNU Parallel not found. Falling back to xargs..."
        xargs -P $cpu_cores -I {} bash -c "$process \"{}\""
    else
        echo "Neither 'GNU Parallel' nor 'xargs' were found. Falling back to WHILE LOOP..."

        while read -r args; do
            $process $args
        done  
    fi
}
