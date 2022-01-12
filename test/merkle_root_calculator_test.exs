defmodule MerkleRootCalculatorTest do
  use ExUnit.Case
  import MerkleRootCalculator, only: [hex_from_hash: 1, hash_from_hex: 1]
  doctest MerkleRootCalculator

  setup do
    hashes = %{
      hash1: :crypto.hash(:sha256, "a"),
      hash2: :crypto.hash(:sha256, "b"),
      hash3: :crypto.hash(:sha256, "c"),
      hash4: :crypto.hash(:sha256, "d"),
      hash5: :crypto.hash(:sha256, "e"),
      hash6: :crypto.hash(:sha256, "f"),
      hash7: :crypto.hash(:sha256, "g")
    }

    hexes = %{
      hex1: hashes.hash1 |> Base.encode16(case: :lower),
      hex2: hashes.hash2 |> Base.encode16(case: :lower),
      hex3: hashes.hash3 |> Base.encode16(case: :lower),
      hex4: hashes.hash4 |> Base.encode16(case: :lower),
      hex5: hashes.hash5 |> Base.encode16(case: :lower),
      hex6: hashes.hash6 |> Base.encode16(case: :lower),
      hex7: hashes.hash7 |> Base.encode16(case: :lower)
    }

    {:ok, hashes: hashes, hexes: hexes}
  end

  test "reverse_endianness/2 converts a binary from big to little endian and vice versa" do
    assert MerkleRootCalculator.reverse_endianness(<<1, 0>>) == <<0, 1>>
    assert MerkleRootCalculator.reverse_endianness(<<0, 1>>) == <<1, 0>>
  end

  test "hash_from_hex/1 returns the binary form of a hash from a given hex", %{hexes: hexes} do
    assert MerkleRootCalculator.hash_from_hex(hexes.hex1) ==
             <<202, 151, 129, 18, 202, 27, 189, 202, 250, 194, 49, 179, 154, 35, 220, 77, 167,
               134, 239, 248, 20, 124, 78, 114, 185, 128, 119, 133, 175, 238, 72, 187>>
  end

  test "hex_from_hash/1 returns the hex form of a given hash", %{hashes: hashes, hexes: hexes} do
    assert MerkleRootCalculator.hex_from_hash(hashes.hash1) == hexes.hex1
  end

  test "calculate_double_sha256/1 when input has only 1 hash returns a hash of that hash concatenated with itself",
       %{hexes: hexes} do
    result =
      :crypto.hash(:sha256, :crypto.hash(:sha256, hash_from_hex(hexes.hex1 <> hexes.hex1)))
      |> Base.encode16(case: :lower)

    assert MerkleRootCalculator.calculate_double_sha256([hexes.hex1]) == result
  end

  test "calculate_double_sha256/1 when input has 2 hashes", %{hexes: hexes} do
    result =
      :crypto.hash(:sha256, :crypto.hash(:sha256, hash_from_hex(hexes.hex1 <> hexes.hex2)))
      |> Base.encode16(case: :lower)

    assert MerkleRootCalculator.calculate_double_sha256([hexes.hex1, hexes.hex2]) == result
  end

  test "calculate_double_sha256/1 when input has 4 hashes", %{hashes: hashes, hexes: hexes} do
    hash1_2 = :crypto.hash(:sha256, :crypto.hash(:sha256, hashes.hash1 <> hashes.hash2))

    hash3_4 = :crypto.hash(:sha256, :crypto.hash(:sha256, hashes.hash3 <> hashes.hash4))

    result =
      :crypto.hash(:sha256, :crypto.hash(:sha256, hash1_2 <> hash3_4))
      |> Base.encode16(case: :lower)

    assert MerkleRootCalculator.calculate_double_sha256([
             hexes.hex1,
             hexes.hex2,
             hexes.hex3,
             hexes.hex4
           ]) == result
  end

  test "calculate_double_sha256/1 when input has 3 hashes", %{hashes: hashes, hexes: hexes} do
    hex1_2 = :crypto.hash(:sha256, :crypto.hash(:sha256, hashes.hash1 <> hashes.hash2))

    # If we have an odd number of hashes, we repeat the last one
    hex3_3 = :crypto.hash(:sha256, :crypto.hash(:sha256, hashes.hash3 <> hashes.hash3))

    result =
      :crypto.hash(:sha256, :crypto.hash(:sha256, hex1_2 <> hex3_3))
      |> Base.encode16(case: :lower)

    assert MerkleRootCalculator.calculate_double_sha256([hexes.hex1, hexes.hex2, hexes.hex3]) ==
             result
  end

  test "calculate_double_sha256/1 when input has 5 hashes", %{hashes: hashes, hexes: hexes} do
    hex1_2 = :crypto.hash(:sha256, :crypto.hash(:sha256, hashes.hash1 <> hashes.hash2))

    hex3_4 = :crypto.hash(:sha256, :crypto.hash(:sha256, hashes.hash3 <> hashes.hash4))

    # If we have an odd number of hashes, we repeat the last one
    hex5_5 = :crypto.hash(:sha256, :crypto.hash(:sha256, hashes.hash5 <> hashes.hash5))

    hex_1_2_3_4 = :crypto.hash(:sha256, :crypto.hash(:sha256, hex1_2 <> hex3_4))

    hex_5_5_5_5 = :crypto.hash(:sha256, :crypto.hash(:sha256, hex5_5 <> hex5_5))

    result =
      :crypto.hash(:sha256, :crypto.hash(:sha256, hex_1_2_3_4 <> hex_5_5_5_5))
      |> Base.encode16(case: :lower)

    assert MerkleRootCalculator.calculate_double_sha256([
             hexes.hex1,
             hexes.hex2,
             hexes.hex3,
             hexes.hex4,
             hexes.hex5
           ]) == result
  end

  test "calculate_double_sha256/1 when input has 6 hashes", %{hashes: hashes, hexes: hexes} do
    hash1_2 = :crypto.hash(:sha256, :crypto.hash(:sha256, hashes.hash1 <> hashes.hash2))

    hash3_4 = :crypto.hash(:sha256, :crypto.hash(:sha256, hashes.hash3 <> hashes.hash4))

    hash5_6 = :crypto.hash(:sha256, :crypto.hash(:sha256, hashes.hash5 <> hashes.hash6))

    hash1_2_3_4 = :crypto.hash(:sha256, :crypto.hash(:sha256, hash1_2 <> hash3_4))

    hash5_6_5_6 = :crypto.hash(:sha256, :crypto.hash(:sha256, hash5_6 <> hash5_6))

    result =
      :crypto.hash(:sha256, :crypto.hash(:sha256, hash1_2_3_4 <> hash5_6_5_6))
      |> Base.encode16(case: :lower)

    result_2 =
      MerkleRootCalculator.calculate_double_sha256([
        hex_from_hash(hash1_2),
        hex_from_hash(hash3_4),
        hex_from_hash(hash5_6)
      ])

    assert MerkleRootCalculator.calculate_double_sha256([
             hexes.hex1,
             hexes.hex2,
             hexes.hex3,
             hexes.hex4,
             hexes.hex5,
             hexes.hex6
           ]) ==
             result

    assert result == result_2
  end
end
