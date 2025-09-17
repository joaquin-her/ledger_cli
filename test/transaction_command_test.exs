defmodule TransactionCommandTest do
  alias Commands.TransactionsCommand
  use ExUnit.Case
  alias Database.CSV_Database
  alias Commands.TransactionsCommand

  test "get userA account transactions" do
    userA_transactions = [
      %Transaccion{
        id: 1,
        timestamp: "1754937004",
        moneda_origen: "USDT",
        moneda_destino: "USDT",
        monto: 100.5,
        cuenta_origen: "userA",
        cuenta_destino: "userB",
        tipo: :transferencia
      }]
    filters = %{cuenta_origen: "userA"}
    assert userA_transactions == TransactionsCommand.filter(CSV_Database.get_transactions("test_data.csv"), filters)
  end

end
