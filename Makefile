GO111MODULE := on
export GO111MODULE

OUTPUTS := \
	go-plugin-loader/go-plugin-loader \
	go-plugin-loader/go-plugin-loader-vendor \
	go-plugin-hook/go-plugin-hook.so \
	go-plugin-hook/go-plugin-hook-vendor.so

trimpath=-gcflags=all=-trimpath="$(abspath $(dir $@))" -asmflags=all=-trimpath="$(abspath $(dir $@))"

all: $(OUTPUTS)
	@true

go-plugin-loader/vendor/modules.txt:
	cd go-plugin-loader && go mod vendor

go-plugin-loader/go-plugin-loader: go-plugin-loader/main.go
	cd $(dir $@) && go build -o $(CURDIR)/$@ $(trimpath) $(notdir $<)

go-plugin-loader/go-plugin-loader-vendor: go-plugin-loader/main.go go-plugin-loader/vendor/modules.txt
	cd $(dir $@) && go build -mod=vendor -o $(CURDIR)/$@ $(trimpath) $(notdir $<)

go-plugin-hook/vendor/modules.txt:
	cd go-plugin-hook && go mod vendor

go-plugin-hook/go-plugin-hook.so: go-plugin-hook/main.go
	cd $(dir $@) && go build -buildmode=plugin -o $(CURDIR)/$@ $(trimpath) $(notdir $<)

go-plugin-hook/go-plugin-hook-vendor.so: go-plugin-hook/main.go go-plugin-hook/vendor/modules.txt
	cd $(dir $@) && go build -mod=vendor -buildmode=plugin -o $(CURDIR)/$@ $(trimpath) $(notdir $<)

.PHONY: test
test: test-no-vendor test-vendor
	@true

.PHONY: test-no-vendor
test-no-vendor: go-plugin-loader/go-plugin-loader go-plugin-hook/go-plugin-hook.so
	go-plugin-loader/go-plugin-loader go-plugin-hook/go-plugin-hook.so

.PHONY: test-vendor
test-vendor: go-plugin-loader/go-plugin-loader-vendor go-plugin-hook/go-plugin-hook-vendor.so
	go-plugin-loader/go-plugin-loader-vendor go-plugin-hook/go-plugin-hook-vendor.so

.PHONY: cleanall
cleanall:
	git clean -dxf
