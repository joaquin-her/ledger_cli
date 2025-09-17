defmodule Ledger.CSV_Database_Tests do
  use ExUnit.Case
  alias Database.CSV_Database

  describe "ledger_transacciones/n" do
    alias TestDataGenerator
    alias Transaction
    test "show all transactions" do
      transactions = [
  %Transaccion{
    id: 1,
    timestamp: "1754937004",
    moneda_origen: "USDT",
    moneda_destino: "USDT",
    monto: 100.5,
    cuenta_origen: "userA",
    cuenta_destino: "userB",
    tipo: :transferencia
  },
  %Transaccion{
    id: 2,
    timestamp: "1755541804",
    moneda_origen: "BTC",
    moneda_destino: "USDT",
    monto: 0.1,
    cuenta_origen: "userB",
    cuenta_destino: "",
    tipo: :swap
  },
  %Transaccion{
    id: 3,
    timestamp: "1756751404",
    moneda_origen: "BTC",
    moneda_destino: "",
    monto: 50000.0,
    cuenta_origen: "userC",
    cuenta_destino: "",
    tipo: :alta_cuenta
  },
  %Transaccion{
    id: 4,
    timestamp: "1757183404",
    moneda_origen: "USDT",
    moneda_destino: "BTC",
    monto: 500.25,
    cuenta_origen: "userD",
    cuenta_destino: "userE",
    tipo: :transferencia
  },
  %Transaccion{
    id: 5,
    timestamp: "1757615404",
    moneda_origen: "ETH",
    moneda_destino: "USDT",
    monto: 1.5,
    cuenta_origen: "userF",
    cuenta_destino: "userG",
    tipo: :swap
  }]
    assert transactions == CSV_Database.get_transactions("test_data.csv")
    end
  end


end
