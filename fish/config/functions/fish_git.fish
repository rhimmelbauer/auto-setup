function fish_git
end

function gc 
    git commit -m $argv[1] --no-verify
end

function g-cv 
    git commit -m $argv[1]
end

function gca 
    git commit -a -m $argv[1]
end

function gc-ap
    git commit -a -m $argv[1]; git push
end

function ga 
    git add .
end

function gst
    git status
end

function vs-s 
    source ../.env
end

function g-pu 
    git push -u origin $argv[1]
end

function gcheck-dev 
    git checkout develop
    git pull
end

function gcheck-new 
    git checkout -b $argv[1];g-c 'Initial branch commit';g-pu $argv[1]
end

function gbl 
    git branch -l
end

function gb-rename 
    git branch -m $argv[1]
end

function g-rlog 
    git log --author="Roberto" --pretty=format:'- %Creset %s ' --abbrev-commit --date=relative
end

function g-push-all
    git add ../.;g-c $argv[1];git push;
end

function gsm
    git switch main;
    git pull;
end

function gsdev
    git switch develop;
    git pull;
end
