GO111MODULE := on
export GO111MODULE

VARIANTS := trimpath-vendor trimpath-no-vendor no-trimpath-vendor no-trimpath-no-vendor

OUTPUTS := \
	$(foreach v, $(VARIANTS), go-plugin-loader/go-plugin-loader-$(v)) \
	$(foreach v, $(VARIANTS), go-plugin-hook/go-plugin-hook-$(v).so)

all: $(OUTPUTS)
	@true

go-plugin-loader/vendor/modules.txt:
	cd go-plugin-loader && go mod vendor

go-plugin-loader/go-plugin-loader-trimpath-no-vendor: go-plugin-loader/main.go
	cd $(dir $@) && go build -trimpath -o $(CURDIR)/$@ $(notdir $<)

go-plugin-loader/go-plugin-loader-no-trimpath-no-vendor: go-plugin-loader/main.go
	cd $(dir $@) && go build -o $(CURDIR)/$@ $(notdir $<)

go-plugin-loader/go-plugin-loader-trimpath-vendor: go-plugin-loader/main.go go-plugin-loader/vendor/modules.txt
	cd $(dir $@) && go build -trimpath -mod=vendor -o $(CURDIR)/$@ $(notdir $<)

go-plugin-loader/go-plugin-loader-no-trimpath-vendor: go-plugin-loader/main.go go-plugin-loader/vendor/modules.txt
	cd $(dir $@) && go build -trimpath -mod=vendor -o $(CURDIR)/$@ $(notdir $<)

go-plugin-hook/vendor/modules.txt:
	cd go-plugin-hook && go mod vendor

go-plugin-hook/go-plugin-hook-trimpath-no-vendor.so: go-plugin-hook/main.go
	cd $(dir $@) && go build -trimpath -buildmode=plugin -o $(CURDIR)/$@ $(notdir $<)

go-plugin-hook/go-plugin-hook-no-trimpath-no-vendor.so: go-plugin-hook/main.go
	cd $(dir $@) && go build -buildmode=plugin -o $(CURDIR)/$@ $(notdir $<)

go-plugin-hook/go-plugin-hook-trimpath-vendor.so: go-plugin-hook/main.go go-plugin-hook/vendor/modules.txt
	cd $(dir $@) && go build -trimpath -mod=vendor -buildmode=plugin -o $(CURDIR)/$@ $(notdir $<)

go-plugin-hook/go-plugin-hook-no-trimpath-vendor.so: go-plugin-hook/main.go go-plugin-hook/vendor/modules.txt
	cd $(dir $@) && go build -mod=vendor -buildmode=plugin -o $(CURDIR)/$@ $(notdir $<)

.PHONY: test
test: $(OUTPUTS)
	@ for loader_type in $(VARIANTS) ; do \
		for plugin_type in $(VARIANTS) ; do \
			echo go-plugin-loader/go-plugin-loader-$${loader_type} go-plugin-hook/go-plugin-hook-$${plugin_type}.so ; \
			go-plugin-loader/go-plugin-loader-$${loader_type} go-plugin-hook/go-plugin-hook-$${plugin_type}.so || true ; \
			echo ; \
		done ; \
	done
	@true

.PHONY: cleanall
cleanall:
	git clean -dxf
