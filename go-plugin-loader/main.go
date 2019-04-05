package main // import "github.com/mem/go-plugin-modules/go-plugin-loader"

import (
	"fmt"
	"os"
	"plugin"

	"golang.org/x/xerrors"
)

type Hook interface {
	Hook() error
}

func main() {
	fn := "plugin.so"

	if len(os.Args) == 2 {
		fn = os.Args[1]
	}

	p, err := plugin.Open(fn)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	sym, err := p.Lookup("Hook")
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	var hook Hook
	hook, ok := sym.(Hook)
	if !ok {
		fmt.Println("Expecting symbol 'Hook' to implement interface 'Hook', but got something else.")
		os.Exit(2)
	}

	err = hook.Hook()

	if err != nil {
		var pathError *os.PathError
		if xerrors.As(err, &pathError) {
			fmt.Println("Failed at path:", pathError.Path)
		}
	}

	fmt.Println("OK")
}
