defmodule Ledger.CSV_Database_Tests do
  use ExUnit.Case
  alias Database.CSV_Database

  alias TestDataGenerator
  alias Transaction
  alias Database.Moneda
  test "get transacciones de test_data.csv se obtienen correctamente" do
    transactions = [
      %Transaccion{id: 1,timestamp: "1754937004",moneda_origen: "USDT",moneda_destino: "USDT",monto: 100.5,cuenta_origen: "userA",cuenta_destino: "",tipo: :alta_cuenta},
      %Transaccion{id: 2,timestamp: "1755541804",moneda_origen: "BTC",moneda_destino: "USDT",monto: 0.1,cuenta_origen: "userB",cuenta_destino: "",tipo: :swap},
      %Transaccion{id: 3,timestamp: "1756751404",moneda_origen: "BTC",moneda_destino: "",monto: 50000.0,cuenta_origen: "userC",cuenta_destino: "",tipo: :alta_cuenta},
      %Transaccion{id: 4,timestamp: "1757183404",moneda_origen: "USDT",moneda_destino: "BTC",monto: 500.25,cuenta_origen: "userD",cuenta_destino: "userE",tipo: :transferencia},
      %Transaccion{id: 5,timestamp: "1757615404",moneda_origen: "ETH",moneda_destino: "USDT",monto: 1.5,cuenta_origen: "userF",cuenta_destino: "userG",tipo: :swap}
    ]
    assert { :ok, transactions} == CSV_Database.get_transactions("test_data.csv")
  end

  test "se muestra correctamente un balance por salida definida en flag -o" do
    test_path = "data/test_file.txt"
    balance = %{BTC: 10000.0, ETH: 2000.0, USDT: 4000.0}
      |> Enum.map(fn {nombre, monto} -> %Moneda{ nombre: nombre, valor: monto} end)
    CSV_Database.write_in_output("MONEDA=BALANCE", balance, test_path)
    contenido = File.read!(test_path)
    assert contenido == "MONEDA=BALANCE\nARS=3.000000\nBTC=1.000000\nETH=2.000000\nEUR=5.000000\nUSDT=4.000000\n"
    File.rm!(test_path)
  end

  test "una transaccion con un tipo incorrecto devuelve un error" do
    test_path = "data/test_file.txt"
    transactions = [
      %Transaccion{id: 1,timestamp: "1754937004",moneda_origen: "USDT",moneda_destino: "USDT",monto: 100.5,cuenta_origen: "userA",cuenta_destino: "",tipo: :alta_cuenta},
      %Transaccion{id: 2,timestamp: "1755541804",moneda_origen: "BTC",moneda_destino: "USDT",monto: 0.1,cuenta_origen: "userB",cuenta_destino: "",tipo: :swap},
      %Transaccion{id: 3,timestamp: "1756751404",moneda_origen: "BTC",moneda_destino: "",monto: 50000.0,cuenta_origen: "userC",cuenta_destino: "",tipo: :baja_cuenta},
      %Transaccion{id: 4,timestamp: "1757183404",moneda_origen: "USDT",moneda_destino: "BTC",monto: 500.25,cuenta_origen: "userD",cuenta_destino: "userE",tipo: :transferencia},
      %Transaccion{id: 5,timestamp: "1757615404",moneda_origen: "ETH",moneda_destino: "USDT",monto: 1.5,cuenta_origen: "userF",cuenta_destino: "userG",tipo: :swap}
    ]
    CSV_Database.write_in_output("ID;TIMESTAMP;MONEDA_ORIGEN;MONEDA_DESTINO;MONTO;CUENTA_ORIGEN;CUENTA_DESTINO;TIPO", transactions, test_path)
    assert {:error, 3} = CSV_Database.get_transactions(test_path)
  end

end
