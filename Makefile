.PHONY: test

PWD := $(shell pwd)
API_KEY := $(shell cat ~/.luarocks.key)
VERSION := 0.2.2-1
TAG :=$(shell git tag -l --points-at HEAD)

test:
	@docker run --rm -it -v $(PWD):/code -w=/code epicfile/openresty:busted 	

release: test
ifeq (v$(VERSION),$(TAG))
	luarocks upload --force --api-key=$(API_KEY) web-$(VERSION).rockspec	
else
	$(error You did not tag the version you are going to release!)
endif	
