defmodule LedgerApp do
  @moduledoc """
  Documentation for `LedgerApp`.
  """

  alias Transaccion
  def read_transactions(path) do
    transacciones = path
    |> File.stream!()
    |> CSV.decode!([separator: ?;,headers: true])
    |> Enum.map(fn row ->
      %Transaccion{
        id: row["id_transaccion"] |> String.to_integer(),
        timestamp: row["timestamp"] |> String.to_integer(),
        tipo: row["tipo"] |> String.to_atom()
      }
    end)
    transacciones
  end

  def read_currencies(path) do
    currencies =
      path
      |> File.stream!()
      |> CSV.decode!(separator: ?;, headers: true)
      |> Enum.map(fn row ->
        %{
          moneda: row["nombre_moneda"],
          valor: row["precio_usd"]
        }
      end)
      |> Enum.to_list()

      currencies
  end

end
