defmodule Commands.BalanceCommand do
  @moduledoc """
  Subcomando para calcular balances
  """
  alias Commands.TransactionsCommand

  @doc """
  La funcion recibe el historial de las transacciones de una cuenta incluyendo su alta de cuenta, las transacciones que realizó y realizaron hacia ella, y los swaps que haya hehco
  Devuelve un mapa con el balance de las monedas de las que dispone luego de todas sus transacciones
  """
  def get_balance(transactions, arguments, conversion_map) do
    filtered_transactions = Enum.sort_by(transactions, fn t -> t.timestamp end)
      |> TransactionsCommand.get_transactions_of_account(arguments.cuenta_origen)
    case is_registerd?(filtered_transactions, arguments.cuenta_origen) do
      true ->
        filtered_transactions
        |> reduce_transactions(arguments, conversion_map)
        |> convert_to_currency(arguments.moneda, conversion_map)
      false ->
        { :error, "la cuenta solicitada no fue dada de alta"}
    end
  end

  defp reduce_transactions(transactions, arguments, conversion_map) do
    transactions
    |> Enum.reduce(%{}, fn transaction, balance ->
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
          IO.puts("no es transferencia")
          balance
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
    {:ok, balance}
  end

  defp convert_to_currency(balance, currency, conversion_map) do
    case Map.has_key?(conversion_map, currency) do
      true ->
        total_in_usd = Enum.reduce(balance, 0.0, fn {moneda, monto}, acc ->
          case Map.has_key?(conversion_map, Atom.to_string(moneda)) do
            true -> acc + (monto * conversion_map[Atom.to_string(moneda)])
            false -> acc
          end
        end)
        converted_amount = total_in_usd / conversion_map[currency]
        |> Float.round(6)
        {:ok, %{ String.to_atom(currency) => converted_amount  }}
      false ->
        {:error, "Moneda no encontrada en la lista de conversiones"}
    end
  end

  @doc """
  Recibe un enumerable de transacciones y el nombre de una cuenta para definir si esa cuenta fue dada de alta en algun momento
  """
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
        {:error, transaction.id}
        balance
    end
  end
        #   |> Enum.each(fn t ->
        #   case {t.tipo, t.moneda_origen, t.modena_destino, t.monto} do
        #     {"transferencia", moneda_origen, _, monto} ->
        #     # para las transferencias debe:
        #       # sumar al balance en esa moneda si la cuenta -c1 es cuenta_destino
        #       # restar al balance en esa moneda si la cuenta -c1 es cuenta_origen
        #       IO.puts("Procesando transferencia")
        #     {"swap", moneda_origen, moneda_destino, monto} ->
        #       # para los swaps debe restar al balance en la moneda_origen y sumar al balance en la moneda_destino acorde al valor de la conversion
        #       IO.puts("Procesando swap")
        #     {"alta_cuenta", moneda_origen, _, monto} ->
        #       # para las alta de cuenta debe asignar su valor inicial con el que se dio de alta a el balance
        #       IO.puts("Procesando alta de cuenta")
        #   end
        # end)
        # devuelve un mapa de clave: valor con la suma de los valores que coincidian


end
