defmodule Commands.BalanceCommand do
  @moduledoc """
  Subcomando para calcular balances
  """
  alias Database.CSV_Database
  alias Commands.TransactionsCommand

  def get_balance(transactions, arguments) do
    case arguments.moneda do
      "all" ->
        _ = IO.puts("Se imprime el balance de la cuenta en todas las monedas de las que dispone")
        # conversion_map = CSV_Database.get_currencies(arguments.path_currencies_data)
        balance =
          # las filtra por tipo de transaccion y hace cuentas distintas
          transactions
          |> TransactionsCommand.filter_by_origin_account(arguments.cuenta_origen)
          |> Enum.reduce(%{}, fn transaction, balance ->
            case transaction.tipo do
              :transferencia ->
                balance
                |> Map.update( String.to_atom(transaction.moneda_origen), String.to_float(transaction.monto) * -1 ,fn value -> value - String.to_float(transaction.monto) end )
              _ ->
                IO.puts("no es transferencia")
                balance
            end
            end)
        IO.inspect(balance)
        transactions
        |> TransactionsCommand.filter_by_destiny_account(arguments.cuenta_origen)
        |> Enum.reduce( balance, fn t, balance ->
          balance
          |> Map.update( String.to_atom(t.moneda_origen), String.to_float(t.monto), fn value -> value + String.to_float(t.monto) end )
          end)
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
      _ ->
        IO.puts("Se imprime el balance de la cuenta convertuda a la moneda especificada")
    end
  end

end
