defmodule TransactionFile do
  @doc """
  Gets list of transactions from a given file path. We assume that the contains
  a list of hashed transactions, one per line
  """
  def get_transactions(file_path) do
    File.stream!(file_path)
    |> Enum.map(&String.trim/1)
  end
end
