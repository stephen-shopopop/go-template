package main

import (
	"errors"
	"fmt"
)

func Hello(v string) (string, error) {
	if v == "hello" {
		return "", errors.New("empty name")
	}

	return v, nil
}

func main() {
	fmt.Println(Hello("hello"))
}
