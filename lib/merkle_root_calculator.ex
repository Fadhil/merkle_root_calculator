defmodule MerkleRootCalculator do
  @moduledoc """
  Documentation for `MerkleRootCalculator`.
  """

  @doc """
  Gets the merkle root for a list of hashes from a file with transactions 
  hashes listed one per line. 

  ## Example
      iex> MerkleRootCalculator.get_merkle_root("test/sample_tx_file.txt") 
      "45cf67217730941b4ace1fbb50ccaf33ab4c23cdb900eb0dec19ee8e044f20a2"

      iex> MerkleRootCalculator.get_merkle_root("test/sample_with_1_tx_file.txt") 
      "86f7e437faa5a7fce15d1ddcb9eaeaea377667b8"

      # 4 transactions
      iex> MerkleRootCalculator.get_merkle_root("block_100000.txt")
      "f3e94742aca4b5ef85488dc37c06c3282295ffec960994b2c0d5ac2a25a95766"

      # 10 transactions
      iex> MerkleRootCalculator.get_merkle_root("block_150000.txt")
      "be0b136f2f3db38d4f55f1963f0acac506d637b3c27a4c42f3504836a4ec52b1"

      # 9 transactions
      iex> MerkleRootCalculator.get_merkle_root("block_100002.txt")
      "2fda58e5959b0ee53c5253da9b9f3c0c739422ae04946966991cf55895287552"
      

  If there is only 1 tx hash in the file, that tx hash is returned as is.
  When any depth of the MerkleTree has an odd number of leaves, the last odd
  leaf is hashed with a concatenation of itself.
  """
  def get_merkle_root(tx_file) do
    transactions = TransactionFile.get_transactions(tx_file)

    if Enum.count(transactions) == 1 do
      List.first(transactions)
    else
      transactions
      # We make the txids little endian for the hashing. By default Elixir is big endian
      |> reverse_all_endianness()
      |> calculate_double_sha256()
      |> hash_from_hex()
      # We reverse the endianness back to big
      |> reverse_endianness()
      |> hex_from_hash()
    end
  end

  def calculate_double_sha256([hex]) do
    :crypto.hash(:sha256, :crypto.hash(:sha256, hash_from_hex(hex <> hex)))
    |> hex_from_hash()
  end

  def calculate_double_sha256([hex1 | [hex2]]) do
    :crypto.hash(:sha256, :crypto.hash(:sha256, hash_from_hex(hex1 <> hex2)))
    |> hex_from_hash()
  end

  def calculate_double_sha256(hex_list) when is_list(hex_list) do
    hex_list
    |> Stream.chunk_every(2)
    |> Stream.map(&calculate_double_sha256/1)
    |> Enum.to_list()
    |> calculate_double_sha256()
  end

  def hash_from_hex(hex) do
    Base.decode16!(hex, case: :lower)
  end

  def hex_from_hash(hash) do
    Base.encode16(hash, case: :lower)
  end

  def reverse_all_endianness(list) do
    list
    |> Stream.map(&hash_from_hex/1)
    |> Stream.map(&reverse_endianness/1)
    |> Stream.map(&hex_from_hash/1)
    |> Enum.to_list()
  end

  def reverse_endianness(binary) do
    binary
    |> :binary.bin_to_list()
    |> Enum.reverse()
    |> :binary.list_to_bin()
  end

  # defp p(e) do
  #   require Logger
  #   Logger.debug(inspect(e, limit: :infinity))
  #   e
  # end
end
