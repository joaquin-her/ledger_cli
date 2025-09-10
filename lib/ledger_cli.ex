defmodule LedgerApp do
  @moduledoc """
  Documentation for `LedgerApp`.
  """

  alias Transaccion
  def run_command(args) do
    {status, config} = parse_args(args)
    # case {status, config} do
    #   {:ok, arguments} ->
    #     case arguments.subcommand do
    #       "transactions" -> get_account_transactions(arguments.path_transacciones_data, arguments.cuenta_origen)
    #       _ -> IO.puts("Comando no reconocido")
    #     end
    # end
  end

  defp parse_args(args) do
    {options, remaining_args, errors} =
      "-c " <> args
      |> String.split(" ")
      |> OptionParser.parse(
        aliases: [
          c: :subcommand,
          c1: :cuenta_origen,
          t: :path_transacciones_data,
          c2: :cuenta_destino,
          o: :output_path
        ],
        strict: [
          subcommand: :string,
          cuenta_origen: :string,
          path_transacciones_data: :string,
          cuenta_destino: :string,
          output_path: :string
        ]
      )
    case {options, remaining_args, errors} do
      {opts, [], []} ->
        opts =
          default_args()
          |> Map.merge(Map.new(opts))
        {:ok, opts}

      {_opts, remaining, []} ->
        remaining
        |> Enum.join(", ")
        |> then(fn msg -> {:error, "Argumentos no reconocidos: #{msg}"} end)


      {_opts, _remaining, errors} ->
        errors
        |> Enum.map(fn {key, val} -> "#{key}: #{val}" end)
        |> Enum.join(", ")
        |> then(fn msg -> {:error, "Errores: #{msg}"} end)
      end
    end

  defp default_args() do
    %{
      subcommand: "transacciones",
      cuenta_origen: "all",
      path_transacciones_data: "transacciones.csv",
      cuenta_destino: "",
      output_path: "out.csv"
    }
  end

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

  def write_transactions(output_path, transactions) do
    try  do
      content =
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
      case File.write(output_path, content) do
        :ok ->
          IO.puts("Transacciones guardadas en: #{output_path}")
          :ok
        {:error, reason} ->
          IO.puts("Error al guardar las transacciones: #{reason}")
          {:error, reason}
      end
    rescue
      e in File.Error ->
        IO.puts("Error al escribir el archivo: #{e.reason}")
        {:error, e.reason}
    end
  end

  def get_transactions(path, "all") do
    read_transactions(path)
  end

  def get_transactions(path, account_name) do
    path
    |> read_transactions()
    |> get_account_transactions(account_name)
  end

  def get_account_transactions(transactions, account_name) do
    transactions
    |> Enum.filter(fn transaction -> transaction.cuenta_origen == account_name end)
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
