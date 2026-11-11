# LDC

LDC is a transpiler for GNU linker script that generates C code.

## Example

Hello world:

```ld
ENTRY(.text);

SECTIONS {
    .text : {
        ."Hello, world!\n";
    }
}
```

## Installation

### Dependencies

- gnat
- gprbuild
- gcc

Simply clone the repository and run gprbuild:

```console
$ git clone https://github.com/notjoshki/ldc.git
$ cd ldc
$ gprbuild
```

## Usage

```
./ldc [options...] <file>
```

| Option | Description |
| --- | --- |
| ```--help``` | Show help information |

## License

LDC is distributed under the [BSD 3-Clause](./LICENSE) license.