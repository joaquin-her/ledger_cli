defmodule LedgerApp.CLI do
  @moduledoc """
  Command Line Interface para ledger app
  """

  alias Commands.BalanceCommand
  alias Database.CSV_Database
  alias Commands.TransactionsCommand

  def main(args) do
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
      {:error, reason} ->
        IO.puts("#{reason}")
    end
  end

  defp handle_transacciones(arguments) do
    CSV_Database.get_transactions(arguments.path_transacciones_data)
    |> TransactionsCommand.filter(arguments)
    |> TransactionsCommand.output_transactions(arguments.output_path)
  end

  defp handle_balance(args) do
    case args.cuenta_origen do
      "all" ->
        IO.puts("Error: Debe especificar una cuenta origen con -c1")
      _ ->
        {conversion_map, transactions} = {
          CSV_Database.get_currencies(args.path_currencies_data),

        }
        case Map.has_key?(conversion_map, args.moneda) || args.moneda == "all" do
          false ->
            IO.puts("La moneda no existe en el archivo de monedas")
            true ->
              with {:ok, transactions} <- CSV_Database.get_transactions(args.path_transacciones_data),
                {:ok, conversion_map} <- CSV_Database.get_currencies(args.path_currencies_data),
                {:ok, balance} <- BalanceCommand.get_balance(transactions, args, conversion_map),
                do: BalanceCommand.output_balance(balance, args.output_path)
            false ->
              IO.puts("La moneda no existe en el archivo de monedas")

      end
    end
  end

  defp parse_args(args) do
    [command | arguments] = args
    processed_args = preprocess_account_flags(arguments)
    {options, remaining_args, errors} =
      processed_args
      |> OptionParser.parse(
        aliases: [
          t: :path_transacciones_data,
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
        |> then(fn msg -> {:error, "#{msg} no se reconoce como opcion valida"} end)

      {_opts, _remaining, errors} ->
        errors
        |> Enum.map(fn {key, val} -> "#{key}#{val}" end)
        |> Enum.join(", ")
        |> then(fn msg -> {:error, "#{msg} no se reconoce como opcion valida"} end)
    end
  end

  # Helper function to convert -c1 and -c2 to full option names
  defp preprocess_account_flags(args) do
    args
    |> Enum.flat_map(fn
      "-c1" -> ["--cuenta-origen"]
      "-c2" -> ["--cuenta-destino"]
      arg -> [arg]
    end)
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
