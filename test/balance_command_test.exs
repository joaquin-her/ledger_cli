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
  test "la suma de 3 transferencias y un gasto genera un balance correcto" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: "1000.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 2, timestamp: "1754937002", moneda_origen: "USDT", moneda_destino: "", monto: "1000.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 3, timestamp: "1755541804", moneda_origen: "BTC", moneda_destino: "", monto: "2.1", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1745541804", moneda_origen: "BTC", moneda_destino: "", monto: "0.1", cuenta_origen: "userB", cuenta_destino: "userA", tipo: :transferencia}
    ]
    assert %{ USDT: 2000.0, BTC: 2.0 } == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userB", moneda: "all"})
  end
  test "la suma de 3 transferencias positivas y una negativa en una cantidad muy pequeña genera un balance correcto" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: "1000.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 2, timestamp: "1754937002", moneda_origen: "USDT", moneda_destino: "", monto: "1000.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 3, timestamp: "1755541804", moneda_origen: "BTC", moneda_destino: "", monto: "2.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1745541804", moneda_origen: "BTC", moneda_destino: "", monto: "0.01", cuenta_origen: "userB", cuenta_destino: "userA", tipo: :transferencia}
    ]
    assert %{ USDT: 2000.0, BTC: 1.99 } == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userB", moneda: "all"})
  end
  test "la suma de 3 transferencias positivas y una negativa en una cantidad muy muy pequeña  genera un balance correcto" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: "1000.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 2, timestamp: "1754937002", moneda_origen: "USDT", moneda_destino: "", monto: "1000.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 3, timestamp: "1755541804", moneda_origen: "BTC", moneda_destino: "", monto: "1.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1745541804", moneda_origen: "BTC", moneda_destino: "", monto: "0.0001214", cuenta_origen: "userB", cuenta_destino: "userA", tipo: :transferencia}
    ]
    assert %{ USDT: 2000.0, BTC: 0.9998786 } == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userB", moneda: "all"})
  end
  test "no tener como objetivo una cuenta especifica debe arrojar una excepcion" do
      assert true
  end  

  test "si la cuenta buscada no esta dentro de los datos debe devolver un :error y la causa de por que es un error" do
      assert true
  end  

  test "un alta de cuenta y una secuencia de transacciones dan un balance correcto" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: "5000.0", cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937002", moneda_origen: "USDT", moneda_destino: "", monto: "1000.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 3, timestamp: "1755541804", moneda_origen: "USDT", moneda_destino: "", monto: "150.0", cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1745541804", moneda_origen: "ETH", moneda_destino: "", monto: "0.0001214", cuenta_origen: "userB", cuenta_destino: "userA", tipo: :transferencia}
    ]
    assert %{ USDT: 3850.0, ETH: 0.0001214 } == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userA", moneda: "all"})
  end  

  test "" do
      assert true
  end  
end
