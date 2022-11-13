#!/bin/bash

LD_LIBRARY_PATH=./lib sbcl \
    --load src/main.lisp \
    --eval "(sb-ext:save-lisp-and-die \"game\" :toplevel #'flappy:main :executable t)" \
    --quit
mv game ./bin/
echo "#!/bin/sh
     LD_LIBRARY_PATH=./lib ./bin/game" | tee start.sh
chmod +x start.sh
