defmodule TransactionFileTest do
  use ExUnit.Case

  test "get_transactions/1 gets all transactions into a list" do
    assert TransactionFile.get_transactions("test/tx_file.txt") == ["a", "b", "c"]
  end
end
