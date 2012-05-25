MOAI=~/bin/moai

ifeq ($(shell uname -sm | sed -e s,x86_64,i386,),Darwin i386)
#osx(homebrew default)
LUA=/usr/local/bin/lua
LUVIT=/usr/local/bin/luvit
else
# linux(ubuntu default)
LUA=/usr/bin/lua
LUVIT=/tmp/luvit/build/luvit
endif


test: luatest luvittest
	echo lua and luvit test done

testall: luatest luvittest moaitest


luatest: $(LUA)
	$(LUA) test.lua
luvittest: $(LUVIT)
	$(LUVIT) test.lua
moaitest: $(MOAI)
	$(MOAI) test.lua

# configs for travis ubuntu workers 
$(LUVIT) :
	cd /tmp; git clone https://github.com/luvit/luvit
	cd /tmp/luvit; make; make install

$(LUA) :
	apt-get install lua5.1
