defmodule Database.CSV_Database do
  @moduledoc """
  Handler de archivos csv para almacenar y leer datos
  """

  @doc """
  Devuelve una lista de transacciones de tipo struct Transaccion obtenidas en el archivos csv con header en 'path'
  """
  def get_transactions(path) do
    path
    |> File.stream!()
    |> CSV.decode!([separator: ?;,headers: true])
    |> Enum.with_index(1)
    |> Enum.reduce_while({:ok, []}, fn {row, index}, {:ok, acc} ->
      case Transaccion.new(
        row["id_transaccion"] |> String.to_integer(),
        row["timestamp"],
        row["moneda_origen"],
        row["moneda_destino"],
        row["monto"]
        |> Float.parse()
        |> elem(0),
        row["cuenta_origen"],
        row["cuenta_destino"],
        row["tipo"] |> String.to_atom()
      ) do
        {:ok, transaccion} ->
          {:cont, {:ok, [transaccion | acc]}}
        {:error, reason} ->
          IO.puts("Error en la transaccion con ID: #{reason}")
          {:halt, {:error, index}}
      end
    end)
    |> case do
      {:ok, transactions} -> {:ok, Enum.reverse(transactions)}
      error -> error
    end
  rescue
    exception ->
      {:error, "Error leyendo archivo: #{Exception.message(exception)}"}
  end

  defp join_content(header, content) do
    Enum.map(content, fn t -> String.Chars.to_string(t) end)
    |> List.insert_at(0, header)
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

  @doc """
  Devuelve una lista de monedas, leidas de un archivo csv o con contenido csv en 'path'
  """
  def get_currencies(path) do
    path
    |> File.stream!()
    |> CSV.decode!(separator: ?;, headers: true)
    |> Enum.reduce( %{} ,fn row, currencies ->
      Map.put(currencies, row["nombre_moneda"], row["precio_usd"] |> String.to_float())
      end)
    |> then(fn map -> {:ok, map} end)
  end
end
