function fish_mlp
end

function tail-start
    sudo systemctl start tailscaled.service
end

function tail-up-new
    sudo tailscale up --accept-routes --exit-node=10.8.62.21 --accept-dns=true --exit-node-allow-lan-access
end

function tail-up-ian
  sudo tailscale up --accept-routes --exit-node=100.66.35.55 --exit-node-allow-lan-access
end

function tail-up
    sudo tailscale up --accept-routes --exit-node="" --accept-dns=true
end

function tail-clamp
  sudo iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1280
end

function tail-up-dep
    sudo tailscale up --accept-routes --exit-node=100.66.35.55 --exit-node-allow-lan-access
end

function tail-down
    sudo tailscale down
end

function tail-reset
    tail-down;
    tail-up;
end

function tail-status
    tailscale status
end

function mlp-aws-sso
    aws sso login --profile production
end

function mlp-docker-auth
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 818831340115.dkr.ecr.us-east-1.amazonaws.com
end
function mlp-pretty
    docker compose run frontend yarn prettier
end
function mlp-lint-frontend
    docker compose run frontend yarn lint
end
function mlp-lint-backend
    docker compose exec backend poetry run flake8
end
function mlp-lint-sponsors-backend
    docker compose exec backend poetry run ruff check
end
function mlp-dpip
    docker compose exec backend poetry run python -m pip install
end
function mlp-ipython-install
    docker compose exec backend poetry run python -m pip install ipython
end
function mlp-test-backend
    docker compose exec backend poetry run ipython -m pytest
end
function mlp-test-frontend
    docker compose exec frontend yarn test
end
function mlp-make-migrations
    docker compose exec backend poetry run python manage.py makemigrations
end
function mlp-migrate
    docker compose exec backend poetry run python manage.py migrate
end
function mlp-shell
    docker compose run backend poetry run python manage.py shell
end
function mlp-shell-plus
    docker compose run backend poetry run python manage.py shell_plus --print-sql
end
function mlp-manage
    docker compose run backend poetry run python manage.py 
end
function mlp-att-up
    docker compose -f ~/Dev/mlp/attorneys/docker compose.yml up
end
function mlp-att-down
    docker compose -f ~/Dev/mlp/attorneys/docker compose.yml down
end
function mlp-att-build
    docker compose -f ~/Dev/mlp/attorneys/docker compose.yml build
end
function mlp-por-up
    docker compose -f ~/Dev/mlp/portunus/docker compose.yml up
end
function mlp-por-down
    docker compose -f ~/Dev/mlp/portunus/docker compose.yml down
end
function mlp-por-build
    docker compose -f ~/Dev/mlp/portunus/docker compose.yml build
end
function mlp-mem-up
    docker compose -f ~/Dev/mlp/members/docker compose.yml up
end
function mlp-mem-down
    docker compose -f ~/Dev/mlp/members/docker compose.yml down
end
function mlp-mem-build
    git -C ~/Dev/mlp/members/ pull;
    docker compose -f ~/Dev/mlp/members/docker compose.yml build;
end
function mlp-doc-build
    git -C ~/Dev/mlp/document-generation/ pull;
    docker compose -f ~/Dev/mlp/document-generation/docker compose.yml build;
end
function mlp-doc-up
    docker compose -f ~/Dev/mlp/document-generation/docker compose.yml up;
end
function mlp-doc-down
    docker compose -f ~/Dev/mlp/document-generation/docker compose.yml down;
end

function mlp-build
    switch $argv[1]
        case 'att'
            git -C ~/Dev/mlp/attorneys/ pull;
            docker compose -f ~/Dev/mlp/attorneys/docker compose.yml build;
        case 'mem'
            git -C ~/Dev/mlp/members/ pull;
            docker compose -f ~/Dev/mlp/members/docker compose.yml build;
        case 'por'
            git -C ~/Dev/mlp/portunus/ pull;
            docker compose -f ~/Dev/mlp/portunus/docker compose.yml build;
        case 'dep'
            git -C ~/Dev/mlp/estate-planning/ pull;
            docker compose -f ~/Dev/mlp/estate-planning/docker compose.yml build;
        case 'spo'
            git -C ~/Dev/mlp/sponsors/ pull;
            docker compose -f ~/Dev/mlp/sponsors/docker compose.yml build;
        case 'doc'
            git -C ~/Dev/mlp/document-generation/ pull;
            docker compose -f ~/Dev/mlp/document-generation/docker compose.yml build;
    end
end


function mlp-up
    switch $argv[1]
        case 'att'
            docker compose -f ~/Dev/mlp/attorneys/docker compose.yml up;
        case 'mem'
            docker compose -f ~/Dev/mlp/members/docker compose.yml up;
        case 'por'
            docker compose -f ~/Dev/mlp/portunus/docker compose.yml up;
        case 'dep'
            docker compose -f ~/Dev/mlp/estate-planning/docker compose.yml up;
        case 'spo'
            docker compose -f ~/Dev/mlp/sponsors/docker compose.yml up;
        case 'doc'
            docker compose -f ~/Dev/mlp/document-generation/docker compose.yml up;
    end
end

function mlp-down
    switch $argv[1]
        case 'att'
            docker compose -f ~/Dev/mlp/attorneys/docker compose.yml down;
        case 'mem'
            docker compose -f ~/Dev/mlp/members/docker compose.yml down;
        case 'por'
            docker compose -f ~/Dev/mlp/portunus/docker compose.yml down;
        case 'dep'
            docker compose -f ~/Dev/mlp/estate-planning/docker compose.yml down;
        case 'spo'
            docker compose -f ~/Dev/mlp/sponsors/docker compose.yml down;
        case 'doc'
            docker compose -f ~/Dev/mlp/document-generation/docker compose.yml down;
    end
end

function mlp-all-down
    docker compose -f ~/Dev/mlp/attorneys/docker-compose.yml down & 
    docker compose -f ~/Dev/mlp/members/docker-compose.yml down &
    docker compose -f ~/Dev/mlp/estate-planning/docker-compose.yml down &
    docker compose -f ~/Dev/mlp/sponsors/docker-compose.yml down &
    docker compose -f ~/Dev/mlp/document-generation/docker-compose.yml down &
    docker compose -f ~/Dev/mlp/portunus/docker-compose.yml down &
    wait
    echo "All MLP Containers are down"
end

function mlp-up-apps
    for arg in $argv
        mlp-up $arg
    end
end

# function mlp-new
#     tmux new -d -s $argv[1] -n docker
#     tmux new-window -t $argv[1] -n cmds
#     tmux split-window -h -t $argv[1]:cmds
#     tmux attach-session -t $argv[1]
# end

function mlp-fresh
    tmux new -d -s $argv[1] -n docker
    tmux send-keys -t $argv[1]:docker "mlp-build $argv[1]" C-m
    tmux new-window -t $argv[1] -n cmds
    tmux split-window -h -t $argv[1]:cmds
    tmux attach-session -t $argv[1]:docker
end

function mlp-start
    tmux new -d -s $argv[1] -n docker
    tmux send-keys -t $argv[1]:docker "mlp-up $argv[1]" C-m
    tmux new-window -t $argv[1] -n cmds
    tmux split-window -h -t $argv[1]:cmds
    tmux attach-session -t $argv[1]:docker
end

function mlp-start-all
  set -l use_up 0

  for i in (seq (count $argv))
    switch $argv[$i]
      case '-up'
        set use_up 1
    end
  end

  tmux new -d -s mlp -n por
  tmux new-window -t mlp -n mem
  tmux new-window -t mlp -n spo
  
  tmux send-keys -t mlp:por "mlp-cd por" C-m
  if test $use_up = 1
    tmux send-keys -t mlp:por "dcup" C-m
  end

  tmux send-keys -t mlp:mem "mlp-cd mem" C-m
  if test $use_up = 1
    tmux send-keys -t mlp:mem "dcup" C-m
  end

  tmux send-keys -t mlp:spo "mlp-cd spo" C-m
  if test $use_up = 1
    tmux send-keys -t mlp:spo "dcup" C-m
  end
  
  tmux a -t mlp:por
end

function mlp-cd
    switch $argv[1]
        case 'att'
            cd ~/Dev/mlp/attorneys/;
        case 'mem'
            cd ~/Dev/mlp/members/;
        case 'por'
            cd ~/Dev/mlp/portunus/;
        case 'dep'
            cd ~/Dev/mlp/estate-planning/;
        case 'spo'
            cd ~/Dev/mlp/sponsors/;
        case 'doc'
            cd ~/Dev/mlp/document-generation/;
    end
end

function rh-mlp-cd
  switch $argv[1]
    case 'att'
      cd ~/Dev/rhimmelbauer-legalplans/attorneys/;
    case 'mem'
      cd ~/Dev/rhimmelbauer-legalplans/members/;
    case 'por'
      cd ~/Dev/rhimmelbauer-legalplans/portunus/;
    case 'dep'
      cd ~/Dev/rhimmelbauer-legalplans/estate-planning/;
    case 'spo'
      cd ~/Dev/rhimmelbauer-legalplans/sponsors/;
    case 'doc'
      cd ~/Dev/rhimmelbauer-legalplans/document-generation/;
    end
end

function get_app_dir_path
  set -l use_rh $argv[1]
  echo "use_rh: $use_rh"
  if test "$use_rh" = "true"
    echo '~/Dev/rhimmelbauer-legalplans/'
  else
    echo '~/Dev/mlp/'
  end

end

function get_app_name
  set -l app_name $argv[1]

  switch $argv[1]
      case 'att'
        echo 'attorneys/'
      case 'mem'
        echo 'members/'
      case 'por'
        echo 'portunus/'
      case 'dep'
        echo 'estate-planning/'
      case 'spo'
        echo 'sponsors/'
      case 'doc'
        echo 'document-generation/'
  end
end
# co pilot code
function mlp-new
  set -l app_name ""
  set -l app_name_path ""
  set -l app_dir ~/Dev/mlp/
  set -l full_path ""
  set -l use_up 0

  for i in (seq (count $argv))
    switch $argv[$i]
      case '-a'
        set app_name $argv[(math $i + 1)]
      case '-rh'
        set app_dir ~/Dev/rhimmelbauer-legalplans/
      case '-up'
        set use_up 1
    end
  end

  set app_name_path (get_app_name $app_name)
  set full_path $app_dir$app_name_path
  cd $full_path

  # Check if session exists
  tmux has-session -t $app_name ^/dev/null
  if test $status -ne 0
    echo 'Creating session $app_name'
    tmux new -d -s $app_name -n nvim
    tmux send-keys -t $app_name:nvim "nvim ." C-m
  end

  # Create 'docker' window if it doesn't exist
  if not tmux list-windows -t $app_name -F '#W' | grep -q '^docker$'
    echo 'Creating docker window' 
    tmux new-window -t $app_name:2 -n docker
    if test $use_up = 1
      tmux send-keys -t $app_name:docker "dcup" C-m
    end
    tmux split-window -v -t $app_name:docker
  end

  # Create 'git' window if it doesn't exist
  if not tmux list-windows -t $app_name -F '#W' | grep -q '^git$'
    echo 'Creating git window'
    tmux new-window -t $app_name:3 -n git
  end

  tmux attach-session -t $app_name:git
end
# function mlp-new
#   set -l app_name ""
#   set -l app_name_path ""
#   set -l app_dir ~/Dev/mlp/
#   set -l full_path ""
#   set -l use_up 0
#
#   for i in (seq (count $argv))
#     switch $argv[$i]
#       case '-a'
#         set app_name $argv[(math $i + 1)]
#       case '-rh'
#         set app_dir ~/Dev/rhimmelbauer/mlp/
#       case '-up'
#         set use_up 1
#     end
#   end
#
#   set app_name_path (get_app_name $app_name)
#   set full_path $app_dir$app_name_path  
#   cd $full_path
#
#   tmux new -d -s $app_name -n nvim
#   tmux new-window -t $app_name -n docker
#   tmux new-window -t $app_name -n git 
#
#   tmux send-keys -t $app_name:nvim "nvim ." C-m
#
#   if test $use_up = 1
#     tmux send-keys -t $app_name:docker "dcup" C-m
#   end
#
#   tmux split-window -h -t $app_name:docker
#   tmux attach-session -t $app_name:git
# end

function rhimmelbauer_mlp_check
    set current_dir (pwd)

    if string match -q '*rhimmelbauer-legalplans*' $current_dir
        echo " rh"
    else if string match -q '*mlp*' $current_dir
        echo " mlp"
    end
end

function mlp-fpp
  set -l app_name $argv[1]
  
  mlp-cd $app_name
  gsdev
  git push -f rh develop
  rh-mlp-cd $app_name
  gsdev

end

function mlp-nvim
    mlp-cd $argv[1]
    tmux new -d -s mlp-$argv[1] -n $argv[1]
    tmux send-keys -t mlp-$argv[1]:$argv[1] "nvim" C-m
    tmux new-window -t mlp-$argv[1]
    tmux attach-session -t mlp-$argv[1]:$argv[1]
end


function rh-mlp-nvim
    rh-mlp-cd $argv[1]
    tmux new -d -s rh-mlp-$argv[1]
    tmux send-keys -t rh-mlp-$argv[1] "nvim" C-m
    tmux attach-session -t rh-mlp-$argv[1]
end

function mlp-getaws
    set -e AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
    set sts_credentials $(aws sts get-session-token --serial-number arn:aws:iam::818831340115:mfa/rhimmelbauer@legalplans.com --token-code $1 | jq .Credentials)
    set AWS_ACCESS_KEY_ID $(echo $sts_credentials | jq -r .AccessKeyId)
    set AWS_SECRET_ACCESS_KEY $(echo $sts_credentials | jq -r .SecretAccessKey)
    set AWS_SESSION_TOKEN $(echo $sts_credentials | jq -r .SessionToken)q
end
# function getaws() {
#     unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
#     sts_credentials=$(aws sts get-session-token --serial-number arn:aws:iam::818831340115:mfa/[insert your username here] --token-code $1 | jq .Credentials)
#     export AWS_ACCESS_KEY_ID=$(echo $sts_credentials | jq -r .AccessKeyId)
#     export AWS_SECRET_ACCESS_KEY=$(echo $sts_credentials | jq -r .SecretAccessKey)
#     export AWS_SESSION_TOKEN=$(echo $sts_credentials | jq -r .SessionToken)
# }
# source $(poetry env info --path)/bin/activate

