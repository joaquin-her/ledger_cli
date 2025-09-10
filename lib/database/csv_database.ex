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

  def get_account_transactions(transactions, account_name) do
    transactions
    |> Enum.filter(fn transaction -> transaction.cuenta_origen == account_name end)
  end
  def get_transactions(path, "all") do
    read_transactions(path)
  end

  def get_transactions(path, account_name) do
    path
    |> read_transactions()
    |> get_account_transactions(account_name)
  end

  def encode_transactions(transactions) do
    transactions
    |> Enum.map(fn t ->
      %{
        id_transaccion: t.id,
        tipo: t.tipo,
        cuenta_origen: t.cuenta_origen,
        cuenta_destino: t.cuenta_destino,
        moneda_origen: t.moneda_origen,
        moneda_destino: t.moneda_destino,
        monto: t.monto,
        timestamp: t.timestamp
      }
    end)
    |> CSV.encode(headers: true)
    |> Enum.join()
  end

  def write_transactions(transactions, output_path) do
    case output_path do
      "console" ->
        transactions
        |> Enum.each(&IO.inspect/1)
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
