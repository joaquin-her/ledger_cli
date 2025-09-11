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
        monto: row["monto"],
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
        id_transaccion: t.id,
        timestamp: t.timestamp,
        moneda_origen: t.moneda_origen,
        moneda_destino: t.moneda_destino,
        cuenta_origen: t.cuenta_origen,
        cuenta_destino: t.cuenta_destino,
        monto: t.monto,
        tipo: t.tipo,
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

# defp read_currencies(path) do
  #   currencies =
  #     path
  #     |> File.stream!()
  #     |> CSV.decode!(separator: ?;, headers: true)
  #     |> Enum.map(fn row ->
  #       %{
  #         moneda: row["nombre_moneda"],
  #         valor: row["precio_usd"]
  #       }
  #     end)
  #     |> Enum.to_list()
  #     currencies
  # end

end
