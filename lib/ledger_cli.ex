defmodule LedgerApp.CLI do
  @moduledoc """
  Documentation for `LedgerApp`.
  """

  alias Commands.BalanceCommand
  alias Database.CSV_Database
  alias Commands.TransactionsCommand

  def main(args) do
    run_command(args)
  end

  def run_command(args) do
    {status, config} = parse_args(args)
    case {status, config} do
      {:ok, arguments} ->
        case arguments.subcommand do
          "balance" ->
            handle_balance(arguments)
          "transacciones" ->
            CSV_Database.get_transactions(arguments.path_transacciones_data)
            |> TransactionsCommand.filter(arguments)
            |> CSV_Database.write_transactions(arguments.output_path)
          _ -> IO.puts("Comando no reconocido")
        end
    end
  end

  defp handle_balance(args) do
    case args.cuenta_origen do
      "all" ->
        IO.puts("Error: Debe especificar una cuenta origen con -c1")
        # throw an exception
      _ ->
        conversion_map = CSV_Database.get_currencies(args.path_currencies_data)
        CSV_Database.get_transactions(args.path_transacciones_data)
        |> TransactionsCommand.get_transactions_of_account(args.cuenta_origen)
        |> BalanceCommand.get_balance(args, conversion_map)
        |> BalanceCommand.output_balance(args.output_path)
    end
  end

  defp parse_args(args) do
    [command | arguments] = args
    {options, remaining_args, errors} =
      arguments
      |> OptionParser.parse(
        aliases: [
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
          |> Map.put(:subcommand, command)
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
      path_currencies_data: "monedas.csv",
      cuenta_destino: "all",
      output_path: "console",
      moneda: "all",
    }
  end

end
