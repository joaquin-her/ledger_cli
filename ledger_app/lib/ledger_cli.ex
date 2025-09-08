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
      |>IO.puts()
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

    Enum.each(currencies, fn currency ->
      print_currency(currency.moneda, currency.valor)
    end)
  end

  defp print_currency(name, value) do
    IO.puts("#{name} : #{value} USD")
  end
end
