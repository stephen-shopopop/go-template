# broz

broz is a simple file server that serves files from a specified directory.

## Usage

### go

```bash
go run bin/broz/main.go
```

## Options

- `--dir` or `-c`, set rootDir to files. Default is `.`.
- `--port` or `-C`, set up a port http. Default is `0`

## Example

```bash
go run bin/broz/main.go --port=8080 --dir=./docs
```
