defmodule LedgerApp.CLI do
  @moduledoc """
  Documentation for `LedgerApp`.
  """

  alias Commands.BalanceCommand
  alias Database.CSV_Database
  alias Commands.TransactionsCommand
  def run_command(args) do
    {status, config} = parse_args(args)
    case {status, config} do
      {:ok, arguments} ->
        case arguments.subcommand do
          "transacciones" ->
            CSV_Database.get_transactions(arguments.path_transacciones_data)
            |> TransactionsCommand.filter(arguments)
            |> CSV_Database.write_transactions(arguments.output_path)
          _ -> IO.puts("Comando no reconocido")
        end
    end
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
          o: :output_path,
          m: :moneda
        ],
        strict: [
          subcommand: :string,
          cuenta_origen: :string,
          path_transacciones_data: :string,
          cuenta_destino: :string,
          output_path: :string,
          moneda: :string
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
      cuenta_destino: "all",
      output_path: "console",
      moneda: "USD",
    }
  end

end
