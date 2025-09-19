defmodule TransactionCommandTest do
  alias Commands.TransactionsCommand
  use ExUnit.Case
  alias Database.CSV_Database
  alias Commands.TransactionsCommand

  test "get userB account transactions" do
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
        tipo: :alta_cuenta
      }
    ]
    userB_transactions = [
      %Transaccion{
        id: 2,
        timestamp: "1755541804",
        moneda_origen: "BTC",
        moneda_destino: "USDT",
        monto: 0.1,
        cuenta_origen: "userB",
        cuenta_destino: "",
        tipo: :alta_cuenta
      }
    ]
    filters = %{cuenta_origen: "userB", cuenta_destino: "all"}
    assert userB_transactions == TransactionsCommand.filter(transactions, filters)
  end

  test "get userA and userB transactions" do
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
      }]
    expected = %Transaccion{
      id: 1,
      timestamp: "1754937004",
      moneda_origen: "USDT",
      moneda_destino: "USDT",
      monto: 100.5,
      cuenta_origen: "userA",
      cuenta_destino: "userB",
      tipo: :transferencia
    }
    filters = %{cuenta_origen: "userA" , cuenta_destino: "userB"}
    assert [expected] == TransactionsCommand.filter(transactions, filters)
  end

  test "un filtrado de una lista de transacciones sin matchs devuelve una lista vacia" do
    transacciones = [
    %Transaccion{id: 1, timestamp: "1754937001", moneda_origen: "BTC", moneda_destino: "", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
    %Transaccion{id: 2, timestamp: "1754937002", moneda_origen: "USDT", moneda_destino: "", monto: 500.0, cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta},
    %Transaccion{id: 3, timestamp: "1754937003", moneda_origen: "BTC", moneda_destino: "", monto: 1000.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
    %Transaccion{id: 4, timestamp: "1755541804", moneda_origen: "BTC", moneda_destino: "", monto: 1.0, cuenta_origen: "userA", cuenta_destino: "userC", tipo: :transferencia},
    %Transaccion{id: 5, timestamp: "1745541805", moneda_origen: "ETH", moneda_destino: "", monto: 200.0, cuenta_origen: "userC", cuenta_destino: "userB", tipo: :transferencia},
    %Transaccion{id: 6, timestamp: "1745541806", moneda_origen: "DOGE", moneda_destino: "", monto: 1200.0, cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta}
    ]
    filtros = %{cuenta_origen: "userX", cuenta_destino: "userY"}
    assert [] == TransactionsCommand.filter(transacciones, filtros)
  end

  test "una busqueda sin coincidencias devuelve una lista vacia de transferencias" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937024", moneda_origen: "USDT", moneda_destino: "BTC", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :swap},
      %Transaccion{id: 3, timestamp: "1755541804", moneda_origen: "ETH", moneda_destino: "", monto: 2.0, cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta}
    ]
    expected = []
    filters = %{cuenta_origen: "userX", cuenta_destino: "all"}
    assert expected == TransactionsCommand.filter(transactions, filters)
  end
end
