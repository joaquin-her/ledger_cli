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
            handle_transacciones(arguments)
          _ -> IO.puts("Comando no reconocido")
        end
    end
  end

  defp handle_transacciones(arguments) do
    CSV_Database.get_transactions(arguments.path_transacciones_data)
    |> TransactionsCommand.filter(arguments)
    |> CSV_Database.write_transactions(arguments.output_path)
  end

  defp handle_balance(args) do
    case args.cuenta_origen do
      "all" ->
        IO.puts("Error: Debe especificar una cuenta origen con -c1")
      _ ->
        {conversion_map, transactions} = {
          CSV_Database.get_currencies(args.path_currencies_data),
          CSV_Database.get_transactions(args.path_transacciones_data)
        }
          case Map.has_key?(conversion_map, args.moneda) do
            false ->
              IO.puts("La moneda no existe en el archivo de monedas")
              true ->
                {status, balance} = BalanceCommand.get_balance(transactions, args, conversion_map)
                case status do
                  :error ->
                    IO.inspect({:error, balance})
                  :ok ->
                    balance
                    |> BalanceCommand.output_balance(args.output_path)
                end
          end
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
