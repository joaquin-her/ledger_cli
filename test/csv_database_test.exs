defmodule Ledger.CSV_Database_Tests do
  use ExUnit.Case
  alias ElixirLS.LanguageServer.Providers.CodeLens.Test
  alias Database.CSV_Database

  alias TestHelpers, as: TestHelper
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
    test_path = TestHelper.create_temp_csv("", "test_file.csv")
    balance = %{BTC: 10000.0, ETH: 2000.0, USDT: 4000.0}
      |> Enum.map(fn {nombre, monto} -> %Moneda{ nombre: nombre, valor: monto} end)
    CSV_Database.write_in_output("MONEDA=BALANCE", balance, test_path)
    contenido = File.read!(test_path)
    assert contenido == "MONEDA=BALANCE\nARS=3.000000\nBTC=1.000000\nETH=2.000000\nEUR=5.000000\nUSDT=4.000000\n"
    File.rm!(test_path)
  end

  test "una transaccion con un tipo incorrecto devuelve un error" do
    content ="""
      id_transaccion;timestamp;moneda_origen;moneda_destino;monto;cuenta_origen;cuenta_destino;tipo
      1;1754937004;USDT;USDT;100.5;userA;;alta_cuenta
      2;1755541804;BTC;USDT;0.1;userB;;swap
      3;1756751404;BTC;;50000.0;userC;;baja_cuenta
      4;1757183404;USDT;BTC;500.25;userD;userE;transferencia
      5;1757615404;ETH;USDT;1.5;userF;userG;swap
      """
    test_path = TestHelper.create_temp_csv(content, "transaccion_tipo_invalido.csv")
    assert {:error, 3} == CSV_Database.get_transactions(test_path)
    TestHelper.cleanup_temp_file(test_path)
  end

  test "una transferencia en una moneda con un monto negativo arroja un error con la linea donde fue encontrada" do
    content = """
      id_transaccion;timestamp;moneda_origen;moneda_destino;monto;cuenta_origen;cuenta_destino;tipo
      1;1754937004;USDT;USDT;100.5;userA;;alta_cuenta
      2;1755541804;BTC;USDT;-10.0;userB;;swap
      3;1756751404;BTC;;50000.0;userC;;baja_cuenta
      4;1757183404;USDT;BTC;500.25;userD;userE;transferencia
      5;1757615404;ETH;USDT;1.5;userF;userG;swap
      """
    test_path = TestHelper.create_temp_csv(content, "transaccion_tipo_invalido.csv")
    assert {:error, 2} == CSV_Database.get_transactions(test_path)
    TestHelper.cleanup_temp_file(test_path)

  end
end
