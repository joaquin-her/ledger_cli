defmodule LedgerApp do
  @moduledoc """
  Documentation for `LedgerApp`.
  """


  def read_transactions(path) do
    case File.read(path) do

      {:ok, content} -> IO.puts(content)

      {:error, :enoent} -> IO.puts("Error: El archivo #{path} no fue encontrado")
    end
  end
end
