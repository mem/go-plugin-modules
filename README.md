Interaction between Go modules and plugins
==========================================

There seems to be a bad interaction between Go modules and Go plugins when you build using -mod=vendor.

The code in this repository demonstrates the issue by building a program and plugin with / without
-mod=vendor. If no -mod=vendor is passed, everything works. If -mod=vendor is passed, the plugin
cannot be loaded.

Build with `make` and run the test with `make test`.
