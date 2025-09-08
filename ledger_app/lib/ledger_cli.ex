defmodule LedgerApp do
  @moduledoc """
  Documentation for `LedgerApp`.
  """


  def read_transactions(path) do
    path
    |> File.stream!()
    |> CSV.decode!([separator: ?;,headers: true])
    |> Enum.each(fn row ->
      row
      |> IO.inspect()
    end)
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
