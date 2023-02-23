.PHONY: 

PWD = $(shell pwd)

test:
	docker run -it --rm \
	-w /var/lua/ \
	-v $(PWD)/examples/:/var/lua/ \
	-e LUA_PATH="/var/lua/?.lua;;;" \
	openresty/openresty:1.21.4.1-2-centos7 \
	sh -c "luajit first.lua"
