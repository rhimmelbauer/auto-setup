function fish_venv
end

function mkve
    echo Creating Python 3 Environment: $argv[1]; 
    python -m venv --prompt $argv[1] venv; 
    source venv/bin/activate.fish;
    pip cache purge
    pip install -vvv --timeout 3 --retries 1 --upgrade pip;
    source .env 
end

function ve 
    source venv/bin/activate.fish; 
    source .env;
end

function veclean  
    echo "Cleaning out venv";
    pip install --upgrade pip; 
    pip freeze > dump; 
    pip uninstall -y -r dump; 
    rm dump; 
end

function vereset
    echo "Resetting venv"; 
    pip install --upgrade pip; 
    pip freeze > dump; 
    pip uninstall -y -r dump; 
    rm dump; pip install -e .; 
    pip freeze | grep -v "-e " > requirements.txt; 
    pip install ipython pylint; 
end

function s 
    source venv/bin/activate.fish
end

function sf 
    source $argv[1]
end

function se 
    source .env
end

function se-f 
    source $argv[1]
end

function e-drm 
    deactivate;
    rm -rf venv;
    mkve venv;
end

function env-save
    set project_name (basename $PWD)
    set time_str (date --date='now' '+%Y_%m_%d_%M')
    set backup_file_name ".env_$time_str"
    mkdir -p ~/Development/.envs/$project_name
    mv ~/Development/.envs/$project_name/.env ~/Development/.envs/$project_name/$backup_file_name
    cp -f .env ~/Development/.envs/$project_name
end

function env-create
    set project_name (basename $PWD)
    echo "# $project_name Env Vars" > .env
    mkdir -p ~/Development/.envs/$project_name
    cp -f .env ~/Development/.envs/$project_name
end

function get-basename
    set project_name (basename $PWD)
    echo "$project_name"
end

function clean_pycache --description 'Recursively remove __pycache__ dirs and .pyc/.pyo files'
    set -l target_dir (pwd)
    set -l dry_run 0
    set -l use_sudo 0

    for arg in $argv
        switch $arg
            case -n --dry-run
                set dry_run 1
            case -s --sudo
                set use_sudo 1
            case -h --help
                echo "Usage: clean_pycache [-n|--dry-run] [-s|--sudo] [path]"
                return 0
            case '*'
                set target_dir $arg
        end
    end

    if not test -d $target_dir
        echo "clean_pycache: '$target_dir' is not a directory" >&2
        return 1
    end

    # Pick the command prefix
    set -l RM rm
    set -l FIND find
    if test $use_sudo -eq 1
        set RM sudo rm
        set FIND sudo find
    end

    echo "Scanning: $target_dir"

    set -l dirs ($FIND $target_dir -type d -name __pycache__)
    set -l files ($FIND $target_dir -type f \( -name '*.pyc' -o -name '*.pyo' \))

    set -l dir_count (count $dirs)
    set -l file_count (count $files)

    if test $dir_count -eq 0 -a $file_count -eq 0
        echo "Nothing to clean. ✨"
        return 0
    end

    if test $dry_run -eq 1
        echo "[dry-run] Would remove $dir_count __pycache__ dir(s):"
        for d in $dirs
            echo "  $d"
        end
        echo "[dry-run] Would remove $file_count .pyc/.pyo file(s):"
        for f in $files
            echo "  $f"
        end
        return 0
    end

    for d in $dirs
        $RM -rf $d
    end
    for f in $files
        $RM -f $f
    end

    echo "Removed $dir_count __pycache__ dir(s) and $file_count .pyc/.pyo file(s). ✅"
end
