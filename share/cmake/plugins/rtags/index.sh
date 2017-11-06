#!/bin/sh

# Get the path of the current script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# check is the rc executable can be found in PATH
function has_rc {
    if hash rc 2>/dev/null; then
        true
    else
        false
    fi
}

# check is the rdm executable is already started
function is_rdm_running {
    if pgrep rdm > /dev/null; then
        true
    else
        false
    fi
}

RED='\033[0;31m'
NC='\033[0m'

if is_rdm_running; then
    if has_rc; then
        # Everything looks fine, forward the compilation database to run_index.sh to run in background
        nohup bash $DIR/run_index.sh $1 > /dev/null 2> /dev/null < /dev/null &
    else
        echo ""
        echo -e "${RED}[RTags] The rc executable was not found in PATH. Indexation cannot be performed.${NC}"
        echo ""
    fi
    else
    echo ""
    echo -e "${RED}[RTags] The rdm executable is not running. Indexation cannot be performed.${NC}"
    echo ""
fi
