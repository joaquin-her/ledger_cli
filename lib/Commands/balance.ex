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
    Enum.sort_by(transactions, fn t -> t.timestamp end)
    case {is_registerd?(transactions, arguments.cuenta_origen)} do
      {true} ->
        _get_balance(transactions, arguments, conversion_map)
      {false} ->
        "la cuenta solicitada no fue dada de alta"
    end
  end

  @doc """
  Recibe un enumerable de transacciones y el nombre de una cuenta para definir si esa cuenta fue dada de alta en algun momento
  """
  defp is_registerd?(transactions, account_name) do
    Enum.any?(transactions, fn t -> t.cuenta_origen == account_name && t.tipo == :alta_cuenta end )
    #Map.get(Enum.at(transactions, 0), :tipo) == :alta_cuenta
  end

  defp _get_balance(transactions, arguments, conversion_map) do
    case arguments.moneda do
      "all" ->
        balance =
          # las filtra por tipo de transaccion y hace cuentas distintas
          transactions
          |> TransactionsCommand.filter_by_origin_account(arguments.cuenta_origen)
          |> Enum.reduce(%{}, fn transaction, balance ->
            case transaction.tipo do
              :transferencia ->
                balance
                |> Map.update( String.to_atom(transaction.moneda_origen), String.to_float(transaction.monto) * -1 ,fn value -> value - String.to_float(transaction.monto) end )
              :alta_cuenta ->
                balance
                |> Map.update( String.to_atom(transaction.moneda_origen), String.to_float(transaction.monto) ,fn value ->String.to_float(transaction.monto) end )
              :swap ->
                balance
                |> apply_swap( transaction, conversion_map)
              _ ->
                IO.puts("no es transferencia")
                balance
            end
          end)
        transactions
        |> TransactionsCommand.filter_by_destiny_account(arguments.cuenta_origen)
        |> Enum.reduce( balance, fn t, balance ->
          balance
          |> Map.update( String.to_atom(t.moneda_origen), String.to_float(t.monto), fn value -> value + String.to_float(t.monto) end )
          end)
      _ ->
        IO.puts("Se imprime el balance de la cuenta convertuda a la moneda especificada")
#      Enum.empty?(balance) ->
#        {:error, "Cuenta no existe"}
    end
  end

  defp apply_swap(balance, transaction, conversion_map) do
    case {Map.has_key?(conversion_map, transaction.moneda_origen), Map.has_key?(conversion_map, transaction.moneda_destino)} do
      {true, true} ->
        origen_to_usd = String.to_float(transaction.monto) * conversion_map[transaction.moneda_origen]
        destino_from_usd = origen_to_usd / conversion_map[transaction.moneda_destino]
        balance
        |> Map.update( String.to_atom(transaction.moneda_origen), String.to_float(transaction.monto) * -1 ,fn value -> value - String.to_float(transaction.monto) end )
        |> Map.update( String.to_atom(transaction.moneda_destino), destino_from_usd ,fn value -> value + destino_from_usd end )
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
