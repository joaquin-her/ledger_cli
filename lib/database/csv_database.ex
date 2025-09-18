defmodule Database.CSV_Database do
  @moduledoc """
  Handler de archivos csv para almacenar y leer datos
  """


  def read_transactions(path) do
    transacciones = path
    |> File.stream!()
    |> CSV.decode!([separator: ?;,headers: true])
    |> Enum.map(fn row ->
      %Transaccion{
        id: row["id_transaccion"] |> String.to_integer(),
        tipo: row["tipo"] |> String.to_atom(),
        cuenta_origen: row["cuenta_origen"],
        cuenta_destino: row["cuenta_destino"],
        moneda_origen: row["moneda_origen"],
        moneda_destino: row["moneda_destino"],
        monto: row["monto"]
        |> Float.parse()
        |> elem(0),
        timestamp: row["timestamp"]
     }
    end)
    transacciones
  end

  def get_transactions(path) do
    read_transactions(path)
  end

  def encode_transactions(transactions) do
    transactions
    |> Enum.map(fn t ->
      %{
        id_transaccion: String.to_atom(t.id),
        timestamp: t.timestamp,
        moneda_origen: String.to_atom(t.moneda_origen),
        moneda_destino: String.to_atom(t.moneda_destino),
        cuenta_origen: String.to_atom(t.cuenta_origen),
        cuenta_destino: String.to_atom(t.cuenta_destino),
        monto: String.to_float(t.monto),
        tipo: String.to_atom(t.tipo),
      }
    end)
    |> CSV.encode(headers: true)
    |> Enum.join()
  end
  defp console_log(transaction) do
    transaction
    |> IO.puts()
  end
  defp print_transactions_header() do
    "ID | TIMESTAMP | MONEDA_ORIGEN | MONEDA_DESTINO | MONTO | CUENTA_ORIGEN | CUENTA_DESTINO | TIPO"
    |> IO.puts()
  end
  def write_transactions(transactions, output_path) do
    case output_path do
      "console" ->
        print_transactions_header()
        transactions
        |> Enum.each(fn t -> console_log(t) end)
      _ ->
        case File.write(output_path, encode_transactions(transactions)) do
          :ok -> IO.puts("Transacciones guardadas en: #{output_path}")
          {:error, reason} ->
            IO.puts("Error al guardar las transacciones: #{reason}")
            {:error, reason}
        end
    end
  end

  def get_currencies(path) do
    path
    |> File.stream!()
    |> CSV.decode!(separator: ?;, headers: true)
    |> Enum.reduce( %{} ,fn row, currencies ->
      Map.put(currencies, row["nombre_moneda"], row["precio_usd"] |> String.to_float())
      end)
  end
end
