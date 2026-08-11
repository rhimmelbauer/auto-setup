function fish_docker
end


function dcup
    docker compose up
end

function dcdown
    docker compose down
end

function dcstop
    docker compose stop
end

function dccrm
  docker container rm $argv[1]
end

function dcbuild
  docker build -t $argv[1]:latest .
end

function dccreate
  docker create --name $argv[1] $argv[2]:latest
end

function dcstart
  docker start $argv[1]
end

function dclog
  docker logs $argv[1]
end

function docker-clean-volumes
    set -l delete_all 0

    # Parse arguments
    for arg in $argv
        switch $arg 
            case '--all'
                set delete_all 1
            case '*'
                echo "Unknown argument: $arg"
                echo "Usage: docker_clean_volumes [--all]"
                return 1
        end
    end

    echo "Listing all Docker volumes..."

    set -l volumes (docker volume ls -q)

    if test (count $volumes) -eq 0
        echo "No Docker volumes found."
        return 0
    end

    for vol in $volumes
        echo ""
        echo "Volume: $vol"
        if test $delete_all -eq 1
            echo "Deleting volume without confirmation..."
            docker volume rm $vol
        else
            read -P "Do you want to delete this volume? [y/N]: " confirm
            if test "$confirm" = "y" -o "$confirm" = "Y"
                echo "Deleting volume: $vol"
                docker volume rm $vol
            else
                echo "Skipping volume: $vol"
            end
        end
    end

    echo ""
    echo "Done processing Docker volumes."
end

function docker-clean-networks
    set -l delete_all 0
    set -l skip_networks bridge host none
    set -l networks

    # Parse arguments
    for arg in $argv
        switch $arg
            case '--all'
                set delete_all 1
            case '*'
                echo "Unknown argument: $arg"
                echo "Usage: docker_clean_networks [--all]"
                return 1
        end
    end

    echo "Collecting user-defined Docker networks..."

    for id in (docker network ls -q)
        set name (docker network inspect --format '{{ .Name }}' $id ^/dev/null)
        if not contains $name $skip_networks
            set networks $networks $name
        end
    end

    if test (count $networks) -eq 0
        echo "No user-defined Docker networks found."
        return 0
    end

    for net in $networks
        echo ""
        echo "Network: $net"
        if test $delete_all -eq 1
            echo "Deleting network without confirmation..."
            docker network rm $net
        else
            read -P "Do you want to delete this network? [y/N]: " confirm
            if test "$confirm" = "y" -o "$confirm" = "Y"
                echo "Deleting network: $net"
                docker network rm $net
            else
                echo "Skipping network: $net"
            end
        end
    end

    echo ""
    echo "Done processing Docker networks."
end
