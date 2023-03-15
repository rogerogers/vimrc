help:
	echo 'help'
install:
	luarocks install --server=https://luarocks.org/dev luaformatter
	npm install -g prettier
