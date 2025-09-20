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
    assert { :ok, %{BTC: 2700.999879 }} == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userB", moneda: "all"}, conversion_values)
  end


  test "la aparicion de varias alta_cuenta incrementa el balance de la cuenta como si fuese un ingreso de divisa" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937024", moneda_origen: "USDT", moneda_destino: "", monto: 6000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 3, timestamp: "1755541804", moneda_origen: "USDT", moneda_destino: "", monto: 150.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1745541804", moneda_origen: "ETH", moneda_destino: "", monto: 0.000121, cuenta_origen: "userB", cuenta_destino: "userA", tipo: :transferencia}
    ]
    conversion_values = %{}
    assert { :ok, %{ USDT: 10850.0, ETH: 0.000121 }} == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userA", moneda: "all"}, conversion_values)
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



  test "el balance con transacciones de varias monedas convierte correctamente a la moneda especificada" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937001", moneda_origen: "BTC", moneda_destino: "", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937002", moneda_origen: "USDT", moneda_destino: "", monto: 500.0, cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 3, timestamp: "1754937003", moneda_origen: "BTC", moneda_destino: "", monto: 1000.0, cuenta_origen: "userA", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 4, timestamp: "1755541804", moneda_origen: "BTC", moneda_destino: "", monto: 1.0, cuenta_origen: "userA", cuenta_destino: "userC", tipo: :transferencia},
      %Transaccion{id: 5, timestamp: "1745541805", moneda_origen: "ETH", moneda_destino: "", monto: 200.0, cuenta_origen: "userC", cuenta_destino: "userB", tipo: :transferencia},
      %Transaccion{id: 6, timestamp: "1745541806", moneda_origen: "DOGE", moneda_destino: "", monto: 1200.0, cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta}
    ]
    conversion_values = %{"BTC" => 30000.00, "ETH" => 2500.00, "USDT" => 1.00, "DOGE" => 5.062}
    # 1000 btc = 30_000_000 usdt
    # 200 eth = 500_000 usdt
    # 500 usdt = 500 usdt
    # 1200 doge = 1012.4 usdt
    # total = 30_501_512.4 usdt
    # convertido a doge = 30_501_512.4 / 5.062 = 6_026_585.2232319 doge
    # redondeado a 6 decimales = 6_026_585.223232 doge
    assert { :ok, %{DOGE: 6026585.223232 }} == BalanceCommand.get_balance(transactions, %{cuenta_origen: "userB", moneda: "DOGE"}, conversion_values)
  end

  test "el balance de una cuenta se imprime correctamente por consola" do
    expected_output = "MONEDA=BALANCE\nBTC=0.000000\nDOGE=6026585.223232\nUSDT=500.000000\n"
    balance = %{DOGE: 6026585.223232, USDT: 500.0, BTC: 0.0}
    output_path = "console"
    assert expected_output == ExUnit.CaptureIO.capture_io(fn ->
      BalanceCommand.output_balance(balance, output_path)
    end)
  end

  test "una cuenta no registrada devuelve un error" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937024", moneda_origen: "USDT", moneda_destino: "ETH", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :swap},
      %Transaccion{id: 3, timestamp: "1755541804", moneda_origen: "ETH", moneda_destino: "", monto: 2.0, cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta}
    ]
    conversion_values = %{}
    arguments = %{cuenta_origen: "userX", moneda: "all"}
    assert { :error, "la cuenta solicitada no fue dada de alta"} == BalanceCommand.get_balance(transactions, arguments, conversion_values)
  end

  test "una transaccion de un tipo desconocido arroja un error y la linea donde fue encontrada" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: 5000.0, cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937024", moneda_origen: "USDT", moneda_destino: "ETH", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :swap},
      %Transaccion{id: 3, timestamp: "1755541804", moneda_origen: "ETH", moneda_destino: "", monto: 2.0, cuenta_origen: "userB", cuenta_destino: "", tipo: :baja_cuenta}
    ]
    conversion_values = %{}
    arguments = %{cuenta_origen: "userB", moneda: "all"}
    assert {:error, "error en transaction_id=3"} == BalanceCommand.get_balance(transactions, arguments, conversion_values)
  end

  test "un swap en una moneda no registrada en el mapa de conversion arroja un error con la linea donde fue encontrada" do
    transactions = [
      %Transaccion{id: 1, timestamp: "1754937004", moneda_origen: "USDT", moneda_destino: "", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :alta_cuenta},
      %Transaccion{id: 2, timestamp: "1754937024", moneda_origen: "USDT", moneda_destino: "BTC", monto: 5000.0, cuenta_origen: "userA", cuenta_destino: "", tipo: :swap},
      %Transaccion{id: 3, timestamp: "1755541804", moneda_origen: "ETH", moneda_destino: "", monto: 2.0, cuenta_origen: "userB", cuenta_destino: "", tipo: :alta_cuenta}
    ]
    conversion_values = %{"USDT" => 1.0, "ETH" => 2500.00}
    arguments = %{cuenta_origen: "userA", moneda: "all"}
    assert {:error, "error en transaction_id=2"} == BalanceCommand.get_balance(transactions, arguments, conversion_values)
  end


end
