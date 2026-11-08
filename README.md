# IA

IA is a compiled assembly-like language for Linux x86_64.

## Installation

### Dependencies

- gnat
- gprbuild
- nasm

Simply clone the repository and run gprbuild:

```console
$ git clone https://github.com/notjoshki/ia.git
$ cd ia
$ gprbuild
```

## Usage

```
./ia [options...] <file>
```

| Option | Description |
| --- | --- |
| ```--help``` | Show help information |

## License

IA is distributed under the [BSD 3-Clause](./LICENSE) license.