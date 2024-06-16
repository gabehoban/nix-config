function build-home
    if test -e $HOME/nix-config
        # Get the number of processing units
        set -l all_cores (nproc)
        # Calculate 75% of the number of processing units
        set -l build_cores (math "round(0.75 * ($all_cores))")
        echo "Building Home Manager with $build_cores cores"
        nh home switch --ask ~/nix-config/ -- --cores $build_cores
    else
        echo "ERROR! No nix-config found in $HOME/nix-config"
    end
end
