LUA=/usr/local/bin/lua
LUVIT=/usr/local/bin/luvit
MOAI=~/bin/moai

test: luatest luvittest
	echo lua and luvit test done

testall: luatest luvittest moaitest


luatest:
	$(LUA) test.lua
luvittest:
	$(LUVIT) test.lua
moaitest:
	$(MOAI) test.lua


