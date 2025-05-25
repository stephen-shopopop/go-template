package hello

import "errors"

func Execute(v string) (string, error) {
	if v == "hello" {
		return "", errors.New("empty name")
	}

	return v, nil
}
