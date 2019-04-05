package main // import "github.com/mem/go-plugin-modules/go-plugin-hook"

import (
	"fmt"

	"golang.org/x/xerrors"
)

type MyError2 struct {
	Message string
	frame   xerrors.Frame
}

func (m *MyError2) Error() string {
	return m.Message
}

func (m *MyError2) Format(f fmt.State, c rune) { // implements fmt.Formatter
	xerrors.FormatError(m, f, c)
}

func (m *MyError2) FormatError(p xerrors.Printer) error { // implements xerrors.Formatter
	p.Print(m.Message)
	if p.Detail() {
		m.frame.Format(p)
	}
	return nil
}

func (m *MyError2) Hook() error {
	return &MyError2{Message: "oops", frame: xerrors.Caller(1)}
}

var Hook MyError2
