#!/usr/bin/env zsh
set -ex


# setup nvm and node begin

source ./languages/node.sh

# setup nvm and node end


# setup python begin

source ./languages/python.sh

# setup python end

# setup git begin

source ./tools/git.sh

# setup git end

# setup golang begin

source ./languages/go.sh

# setup golang end


# setup rust begin

source ./languages/rust.sh

# setup rust end
