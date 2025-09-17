defmodule BalanceCommandTests do
  use ExUnit.Case
  alias Commands.BalanceCommand
  alias Transaccion

  test "un alta de cuenta genera un balance correcto" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
    ]
    conversion_values = %{}
    assert { :ok, %{ USDT: 5000.0 }} == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userA", moneda: "all"}, conversion_values)
  end

  test "la suma de 3 transferencias positivas genera un balance correcto" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937001", moneda_origen: "USDT", moneda_destino: "", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937002", moneda_origen: "BTC", moneda_destino: "", monto: 5.0, cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta},

      %Transaccion{id: 3, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: 1000.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1754937002", moneda_origen: "USDT", moneda_destino: "", monto: 1000.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
    ]
    conversion_values = %{}
    assert { :ok, %{ USDT: 2000.0, BTC: 5.0 }} == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userB", moneda: "all"}, conversion_values)
  end
  test "la suma de 3 transferencias y un gasto genera un balance correcto" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937001", moneda_origen: "USDT", moneda_destino: "", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937002", moneda_origen: "ETH", moneda_destino: "", monto: 50.0, cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta},

      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: 1000.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 3, timestamp: "1754937002", moneda_origen: "USDT", moneda_destino: "", monto: 1000.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1754937002", moneda_origen: "USDT", moneda_destino: "", monto: 1500.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 5, timestamp: "1745541804", moneda_origen: "ETH", moneda_destino: "", monto: 0.1, cuenta_origen: "userB", cuenta_destino: "userA", tipo: :transferencia}
    ]
    conversion_values = %{}
    assert { :ok, %{ USDT: 3500.0, ETH: 49.9 }} == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userB", moneda: "all"} , conversion_values)
  end
  test "la suma de 3 transferencias positivas y una negativa en una cantidad muy pequeña  genera un balance correcto" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937001", moneda_origen: "BTC", moneda_destino: "", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937002", moneda_origen: "BTC", moneda_destino: "", monto: 500.0, cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta},

      %Transaccion{id: 3, timestamp: "1754937003", moneda_origen: "BTC", moneda_destino: "", monto: 1000.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1755541804", moneda_origen: "BTC", moneda_destino: "", monto: 1.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 5, timestamp: "1745541805", moneda_origen: "BTC", moneda_destino: "", monto: 1200.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1745541806", moneda_origen: "BTC", moneda_destino: "", monto: 0.0001214, cuenta_origen: "userB", cuenta_destino: "userA", tipo: :transferencia}
    ]
    conversion_values = %{}
    assert { :ok, %{BTC: 2700.9998786 }} == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userB", moneda: "all"}, conversion_values)
  end


  test "la aparicion de varias alta_cuenta incrementa el balance de la cuenta como si fuese un ingreso de divisa" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937024", moneda_origen: "USDT", moneda_destino: "", monto: 6000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 3, timestamp: "1755541804", moneda_origen: "USDT", moneda_destino: "", monto: 150.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1745541804", moneda_origen: "ETH", moneda_destino: "", monto: 0.0001214, cuenta_origen: "userB", cuenta_destino: "userA", tipo: :transferencia}
    ]
    conversion_values = %{}
    assert { :ok, %{ USDT: 10850.0, ETH: 0.0001214 }} == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userA", moneda: "all"}, conversion_values)
  end

  test "un swap es convertido correctamente " do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937024", moneda_origen: "USDT", moneda_destino: "ETH", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :swap},
    ]
    conversion_values = %{"BTC" => 67500.00, "ETH" => 2500.00, "USDT" => 1.00}
    assert {:ok, %{ USDT: 0.0, ETH: 2.0 }} == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userA", moneda: "all"}, conversion_values)
  end

  test "un swap con un monto mayor al disponible genera una deuda en la divisa convertida " do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937024", moneda_origen: "USDT", moneda_destino: "ETH", monto: 5020.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :swap},
    ]
    conversion_values = %{"BTC" => 67500.00, "ETH" => 2500.00, "USDT" => 1.00}
    assert {:ok, %{USDT: -20.0, ETH: 2.008}} == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userA", moneda: "all"}, conversion_values)
  end

  test "el balance con una moneda dentro de los valores de conversion en especifico se calcula correctamente" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937001", moneda_origen: "BTC", moneda_destino: "", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937002", moneda_origen: "BTC", moneda_destino: "", monto: 500.0, cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 3, timestamp: "1754937003", moneda_origen: "BTC", moneda_destino: "", monto: 1000.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1755541804", moneda_origen: "BTC", moneda_destino: "", monto: 1.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 5, timestamp: "1745541805", moneda_origen: "BTC", moneda_destino: "", monto: 1200.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1745541806", moneda_origen: "BTC", moneda_destino: "", monto: 0.0001214, cuenta_origen: "userB", cuenta_destino: "userA", tipo: :transferencia}
    ]
    conversion_values = %{"BTC" => 30000.00, "ETH" => 2500.00, "USDT" => 1.00}
    assert { :ok, %{USDT: 81029996.358 }} == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userB", moneda: "USDT"}, conversion_values)
  end

  test "una moneda fuera del mapa de conversion devuelve un error" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937001", moneda_origen: "BTC", moneda_destino: "", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937002", moneda_origen: "BTC", moneda_destino: "", monto: 500.0, cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 3, timestamp: "1754937003", moneda_origen: "BTC", moneda_destino: "", monto: 1000.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia}
    ]
    conversion_values = %{"BTC" => 30000.00, "ETH" => 2500.00, "USDT" => 1.00}
    assert { :error, "Moneda no encontrada en la lista de conversiones"} == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userB", moneda: "DOGE"}, conversion_values)
  end
end
