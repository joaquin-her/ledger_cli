defmodule Database.CSV_Database do
  @moduledoc """
  Handler de archivos csv para almacenar y leer datos
  """

  def get_transactions(path) do
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

  defp join_content(header, content) do
    header
    |> Enum.concat(Enum.map(content, fn t -> String.Chars.to_string(t) end))
    |> Enum.join("\n")
  end
  defp console_log(transaction) do
    transaction
    |> IO.puts()
  end
  def write_in_output(header, content, output_path) do
    case output_path do
      "console" ->
        console_log(header)
        content
        |> Enum.each(fn t -> console_log(t) end)
      _ ->
        case File.write(output_path, join_content(header, content)) do
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
