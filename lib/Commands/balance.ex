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
    case is_registerd?(filtered_transactions, arguments.cuenta_origen) do
      true ->
        try do
          result = filtered_transactions
            |> reduce_transactions(arguments, conversion_map)
            |> convert_to_currency(arguments.moneda, conversion_map)
          {:ok, result}
        rescue
          e in RuntimeError ->
            {:error, String.to_integer(e.message)}
        end
      false ->
        { :error, "la cuenta solicitada no fue dada de alta"}
    end
  end

  @doc """
  Recive una tupla con un estado :ok o :error y un balance para imprimir el error por consola o mapearlo con los structs Moneda y escribirlo con el modulo CSV_database
  en la direccion de path
  """
  def output_balance({:ok, balance}, path) do
    output = balance
      |> Enum.map(fn {nombre, monto} -> %Moneda{ nombre: nombre, valor: monto} end)
    CSV_Database.write_in_output("MONEDA=BALANCE", output, path)
  end
  def output_balance({:error, line}, _) do
    IO.puts("{:error, #{line}}")
  end

  defp reduce_transactions(transactions, arguments, conversion_map) do
    transactions
    |> Enum.reduce(%{}, fn transaction, balance ->
      case transaction.monto < 0 do
        true -> raise %RuntimeError{message: "#{transaction.id}"}
        false -> nil
      end
      case transaction.tipo do
        :transferencia ->
          balance
          |> apply_transaction_to_balance(transaction, arguments.cuenta_origen)
        :alta_cuenta ->
          balance
          |> add_amount(transaction.moneda_origen, transaction.monto)
        :swap ->
          balance
          |> apply_swap( transaction, conversion_map)
        _ ->
          raise %RuntimeError{message: "#{transaction.id}"}
      end
    end)
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
    Enum.any?(transactions, fn t -> t.cuenta_origen == account_name && t.tipo == :alta_cuenta end )
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
        raise %RuntimeError{message: "#{transaction.id}"}
    end
  end
end
