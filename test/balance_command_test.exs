defmodule BalanceCommandTests do
  use ExUnit.Case
  alias Commands.BalanceCommand
  alias Transaccion
  test "la suma de 3 transferencias genera un balance correcto" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: "1000.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 2, timestamp: "1754937002", moneda_origen: "USDT", moneda_destino: "", monto: "1000.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 3, timestamp: "1755541804", moneda_origen: "BTC", moneda_destino: "", monto: "0.1", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
    ]
    assert %{ USDT: 2000.0, BTC: 0.1 } == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userB", moneda: "all"})
  end
end
