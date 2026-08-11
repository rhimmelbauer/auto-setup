function fish_django
end

function d-m 
    ./manage.py migrate
end

function d-mm 
    ./manage.py makemigrations
end

function d-r 
    ./manage.py runserver
end

function d-cr 
    ./manage.py collectreact
end

function d-c 
    ./manage.py collectstatic --noinput --verbosity 2
end

function d-t 
    ./manage.py test --noinput
end

function d-ta 
    ./manage.py test $argv[1]
end
