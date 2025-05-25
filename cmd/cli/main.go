package main

import (
	"github.com/stephen-shopopop/go-template/internal/domain/hello"
	"github.com/stephen-shopopop/go-template/internal/single"
	"github.com/stephen-shopopop/go-template/pkg/logger"
)

func main() {
	for i := 0; i < 30; i++ {
		single.GetInstance()
	}

	logger.Info(hello.Execute("hello"))
}
