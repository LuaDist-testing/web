.PHONY: test release

NAME = web
VERSION = 0.2.4-1

VERSION_SHORT := $(shell echo $(VERSION) | sed 's/-.//')
API_KEY := $(shell cat ~/.luarocks.key)
TAG := $(shell git tag -l --points-at HEAD)
PWD := $(shell pwd)

test:
	$(info Run tests with openresty lua, lua5.1, lua5.2, lua5.3 and luajit)
	@docker run --rm -it --add-host="tester.deviant.guru:51.15.48.64" -v /var/run/docker.sock:/tmp/docker.sock -v $(PWD):/code -w=/code epicfile/openresty:busted 	
	@docker run --rm -it --add-host="tester.deviant.guru:51.15.48.64" -v /var/run/docker.sock:/tmp/docker.sock -v $(PWD):/code -w=/code epicfile/lua5.1:busted 	
	@docker run --rm -it --add-host="tester.deviant.guru:51.15.48.64" -v /var/run/docker.sock:/tmp/docker.sock -v $(PWD):/code -w=/code epicfile/lua5.2:busted 	
	@docker run --rm -it --add-host="tester.deviant.guru:51.15.48.64" -v /var/run/docker.sock:/tmp/docker.sock -v $(PWD):/code -w=/code epicfile/lua5.3:busted 	
	@docker run --rm -it --add-host="tester.deviant.guru:51.15.48.64" -v /var/run/docker.sock:/tmp/docker.sock -v $(PWD):/code -w=/code epicfile/luajit:busted 	

release: test
ifeq (v$(VERSION),$(TAG))
	$(info Making sure that the version was updated everywhere...)
	@grep -q 'version = "$(VERSION)"' $(NAME)-$(VERSION).rockspec
	@grep -q 'v$(VERSION).zip' $(NAME)-$(VERSION).rockspec
	@grep -q 'version = "$(VERSION_SHORT)"' src/$(NAME).lua
	$(info OK, uploading to luarocks...)
	luarocks upload --force --api-key=$(API_KEY) $(NAME)-$(VERSION).rockspec	
else
	$(error You did not tag the version you are going to release!)
endif	
