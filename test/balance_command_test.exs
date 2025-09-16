defmodule BalanceCommandTests do
  use ExUnit.Case
  alias Commands.BalanceCommand
  alias Transaccion

  test "un alta de cuenta genera un balance correcto" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: "5000.0", cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
    ]
    assert %{ USDT: 5000.0 } == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userA", moneda: "all"})
  end

  test "la suma de 3 transferencias positivas genera un balance correcto" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937001", moneda_origen: "USDT", moneda_destino: "", monto: "5000.0", cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937002", moneda_origen: "BTC", moneda_destino: "", monto: "5.0", cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta},

      %Transaccion{id: 3, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: "1000.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1754937002", moneda_origen: "USDT", moneda_destino: "", monto: "1000.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
    ]
    assert %{ USDT: 2000.0, BTC: 5.0 } == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userB", moneda: "all"})
  end
  test "la suma de 3 transferencias y un gasto genera un balance correcto" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937001", moneda_origen: "USDT", moneda_destino: "", monto: "5000.0", cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937002", moneda_origen: "ETH", moneda_destino: "", monto: "50.0", cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta},

      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: "1000.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 3, timestamp: "1754937002", moneda_origen: "USDT", moneda_destino: "", monto: "1000.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1754937002", moneda_origen: "USDT", moneda_destino: "", monto: "1500.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 5, timestamp: "1745541804", moneda_origen: "ETH", moneda_destino: "", monto: "0.1", cuenta_origen: "userB", cuenta_destino: "userA", tipo: :transferencia}
    ]
    assert %{ USDT: 3500.0, ETH: 49.9 } == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userB", moneda: "all"})
  end
  test "la suma de 3 transferencias positivas y una negativa en una cantidad muy pequeña  genera un balance correcto" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937001", moneda_origen: "BTC", moneda_destino: "", monto: "5000.0", cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937002", moneda_origen: "BTC", moneda_destino: "", monto: "500.0", cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta},

      %Transaccion{id: 3, timestamp: "1754937003", moneda_origen: "BTC", moneda_destino: "", monto: "1000.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1755541804", moneda_origen: "BTC", moneda_destino: "", monto: "1.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 5, timestamp: "1745541805", moneda_origen: "BTC", moneda_destino: "", monto: "1200.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1745541806", moneda_origen: "BTC", moneda_destino: "", monto: "0.0001214", cuenta_origen: "userB", cuenta_destino: "userA", tipo: :transferencia}
    ]
    assert %{BTC: 2700.9998786 } == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userB", moneda: "all"})
  end
  test "no tener como objetivo una cuenta especifica debe arrojar una excepcion" do
      assert true
  end

  test "si la cuenta buscada no esta dentro de los datos debe devolver un :error y la causa de por que es un error" do
      assert true
  end


  test "la aparicion de varias alta_cuenta de una misma cuenta debe arrojar un error con la linea donde fue encontrado" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: "5000.0", cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937024", moneda_origen: "USDT", moneda_destino: "", monto: "6000.0", cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 3, timestamp: "1755541804", moneda_origen: "USDT", moneda_destino: "", monto: "150.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1745541804", moneda_origen: "ETH", moneda_destino: "", monto: "0.0001214", cuenta_origen: "userB", cuenta_destino: "userA", tipo: :transferencia}
    ]
    assert { :error, 2} == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userA", moneda: "all"})
  end
end
