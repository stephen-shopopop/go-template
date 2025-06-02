// package broz is a simple file server that serves files from a specified directory.
package main

import (
	"errors"
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
)

var (
	dir  = flag.String("dir", ".", "path to serve")
	port = flag.String("port", "0", "port to serve on, 0 for random")
)

// Init
func init() {
	flag.Parse()
}

func getPortAvailable(p string) (int, net.Listener) {
	listener, err := net.Listen("tcp", ":"+p)
	if err != nil {
		log.Fatalf("error creating listener: %v\n", err)
	}

	port := listener.Addr().(*net.TCPAddr).Port

	return port, listener
}

func handle(fs http.Handler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Add("Referrer-Policy", "0")
		// Cache
		w.Header().Add("Surrogate-Control", "no-store")
		w.Header().Add("Cache-Control", "no-store, no-cache, must-revalidate, proxy-revalidate")
		w.Header().Add("Pragma", "no-cache")
		w.Header().Add("Expires", "0")
		// Security
		w.Header().Add("X-Content-Type-Options", "nosniff")
		w.Header().Add("X-DNS-Prefetch-Control", "off")
		w.Header().Add("X-Frame-Options", "DENY")
		w.Header().Add("Strict-Transport-Security", "5184000")
		w.Header().Add("X-Download-Options", "noopen")
		w.Header().Add("X-XSS-Protection", "1; mode=block")

		fs.ServeHTTP(w, r)

		log.Println(r.Method, r.URL.Path, r.RemoteAddr, r.UserAgent(), r.Referer())
	}
}

func fileServer(listener net.Listener, path string) error {
	http.Handle("/", handle(http.FileServer(http.Dir(path))))
	return http.Serve(listener, nil)
}

func absPath() string {
	exe, err := os.Executable()
	if err != nil {
		panic(err)
	}
	exe, err = filepath.EvalSymlinks(exe)
	if err != nil {
		panic(err)
	}
	dir := filepath.Dir(exe)
	return dir
}

func main() {
	signals := make(chan os.Signal, 1)
	signal.Notify(signals, syscall.SIGTERM, os.Interrupt)

	go func() {
		<-signals
		log.Println("stopping file server")
		os.Exit(0)
	}()

	port, listener := getPortAvailable(*port)

	var path string

	if strings.HasPrefix(*dir, "./") || strings.HasPrefix(*dir, "../") || strings.HasPrefix(*dir, ".\\") || strings.HasPrefix(*dir, "..\\") {
		path = filepath.Join(absPath(), *dir)
	} else {
		path = *dir
	}

	url := fmt.Sprintf("http://localhost:%d/", port)
	log.Printf("starting file server on %s\n", url)

	if err := fileServer(listener, path); !errors.Is(err, http.ErrServerClosed) {
		log.Fatalf("HTTP server error: %v", err)
	}
}
