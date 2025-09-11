defmodule Commands.BalanceCommand do
  @moduledoc """
  Subcomando para calcular balances
  """
  alias Commands.TransactionsCommand

  def get_balance(transactions, arguments) do
    case arguments.moneda do
      "all" ->
        _ = IO.puts("Se imprime el balance de la cuenta en todas las monedas de las que dispone")
        transactions
        # filtra obteniendo las transacciones de la cuenta
        |> TransactionsCommand.get_transactions_of_account(arguments.cuenta_origen)
        # las filtra por tipo de transaccion y hace cuentas distintas
        |> Enum.each(fn t ->
          case {t.tipo, t.moneda_origen, t.modena_destino, t.monto} do
            {"transferencia", moneda_origen, _, monto} ->
            # para las transferencias debe:
              # sumar al balance en esa moneda si la cuenta -c1 es cuenta_destino
              # restar al balance en esa moneda si la cuenta -c1 es cuenta_origen
              IO.puts("Procesando transferencia")
            {"swap", moneda_origen, moneda_destino, monto} ->
              # para los swaps debe restar al balance en la moneda_origen y sumar al balance en la moneda_destino acorde al valor de la conversion
              IO.puts("Procesando swap")
            {"alta_cuenta", moneda_origen, _, monto} ->
              # para las alta de cuenta debe asignar su valor inicial con el que se dio de alta a el balance
              IO.puts("Procesando alta de cuenta")
          end
        end)
        # devuelve un mapa de clave: valor con la suma de los valores que coincidian
      _ ->
        IO.puts("Se imprime el balance de la cuenta convertuda a la moneda especificada")
    end
  end

end
