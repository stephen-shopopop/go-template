package main

import (
	"testing"
)

func TestHelloEmpty(t *testing.T) {
	msg, err := Hello("hello")
	if msg != "" || err == nil {
		t.Fatalf(`Hello("") = %q, %v, want "", error`, msg, err)
	}
}
