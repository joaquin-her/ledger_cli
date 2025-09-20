defmodule Commands.BalanceCommand do
  @moduledoc """
  Subcomando para calcular balances
  """
  alias Commands.TransactionsCommand
  alias Database.CSV_Database
  alias Database.Moneda
  @doc """
  La funcion recibe un historial de transacciones, los argumentos de la linea de comando y un mapa de conversiones
  Los argumentos deben tener como 'key' por lo menos ['cuenta_origen,'cuenta_destino', 'moneda']
  Devuelve un mapa con el balance de las monedas de las que dispone la cuenta solicitada
  o un error si la cuenta no fue dada de alta o si la moneda solicitada no esta en la lista de conversiones
  """
  def get_balance(transactions, arguments, conversion_map) do
    filtered_transactions = TransactionsCommand.get_transactions_of_account(transactions, arguments.cuenta_origen)
    with {true, _} <- is_registerd?(filtered_transactions, arguments.cuenta_origen),
      {:ok, balance} <- reduce_transactions( filtered_transactions, arguments, conversion_map),
      {:ok, balance} <- convert_to_currency(balance, arguments.moneda, conversion_map) do
        IO.puts("Balance calculado correctamente")
        {:ok, balance}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Recive una tupla con un estado :ok o :error y un balance para imprimir el error por consola o mapearlo con los structs Moneda y escribirlo con el modulo CSV_database
  en la direccion de path
  """
  def output_balance(balance, path) do
    output = balance
      |> Enum.map(fn {nombre, monto} -> %Moneda{ nombre: nombre, valor: monto} end)
    CSV_Database.write_in_output("MONEDA=BALANCE", output, path)
  end
  defp reduce_transactions(transactions, arguments, conversion_map) do
    try do
      balance = transactions
        |> Enum.reduce(%{}, fn transaction, balance->
          case transaction.tipo do
            :transferencia ->
              apply_transaction_to_balance(balance, transaction, arguments.cuenta_origen)
            :alta_cuenta ->
              add_amount(balance, transaction.moneda_origen, transaction.monto)
            :swap ->
              apply_swap(balance, transaction, conversion_map)
            _ ->
              raise RuntimeError
            end
       end)
      {:ok, balance}
    rescue
      RuntimeError -> {:error, RuntimeError.message()}
    end
  end

  defp add_amount(balance, currency, amount) do
    balance
    |> Map.update( String.to_atom(currency), amount ,fn value -> value + amount end )
  end

  defp apply_transaction_to_balance(balance, transaction, cuenta_origen) do
    case transaction.cuenta_origen == cuenta_origen do
      true ->
        balance
        |> add_amount(transaction.moneda_origen, transaction.monto * -1)
      false ->
        balance
        |> add_amount(transaction.moneda_origen, transaction.monto)
      end
  end

  defp convert_to_currency(balance, "all", _conversion_map) do
    balance
    |> Enum.map(fn {moneda, monto} -> {moneda, Float.round(monto, 6)} end)
    |> Enum.into(%{})
  end

  defp convert_to_currency(balance, currency, conversion_map) do
    total_in_usd = Enum.reduce(balance, 0.0, fn {moneda, monto}, acc ->
      acc + (monto * conversion_map[Atom.to_string(moneda)])
    end)
    converted_amount = total_in_usd / conversion_map[currency]
    |> Float.round(6)
    %{ String.to_atom(currency) => converted_amount  }
  end

  defp is_registerd?(transactions, account_name) do
    case Enum.any?(transactions, fn t -> t.cuenta_origen == account_name && t.tipo == :alta_cuenta end ) do
      true -> {true, "Cuenta registrada"}
      false -> {:error, "la cuenta solicitada no fue dada de alta"}
    end
  end

  defp apply_swap(balance, transaction, conversion_map) do
    case {Map.has_key?(conversion_map, transaction.moneda_origen), Map.has_key?(conversion_map, transaction.moneda_destino)} do
      {true, true} ->
        origen_to_usd = transaction.monto * conversion_map[transaction.moneda_origen]
        destino_from_usd = origen_to_usd / conversion_map[transaction.moneda_destino]
        balance
        |> add_amount(transaction.moneda_origen,transaction.monto * -1)
        |> add_amount(transaction.moneda_destino, destino_from_usd)
      _ ->
        {:error, transaction.id}
    end
  end
end
