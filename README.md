# MerkleRootCalculator

**Calculates the merkle root for a list of transaction hashes in a given file**

## Usage

Run `iex -S mix`

```elixir
iex(1)> MerkleRootCalculator.get_merkle_root("path/to/file.txt")
```

## Run tests

```
mix test
```

## Assumptions 
The hash calculations use double sha256 (sha256(sha256(tx))).
The file is assumed to be a list of hashed transactions in hexadecimal with 
one transaction per line.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/merkle_root_calculator](https://hexdocs.pm/merkle_root_calculator).

