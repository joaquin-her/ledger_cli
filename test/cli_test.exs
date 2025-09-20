defmodule CliTest do
  use ExUnit.Case
  alias TestHelpers, as: TestHelper
  import ExUnit.CaptureIO
    test "print in console all transactions" do
    expected_output =
"ID_TRANSACCION;TIMESTAMP;MONEDA_ORIGEN;MONEDA_DESTINO;MONTO;CUENTA_ORIGEN;CUENTA_DESTINO;TIPO\n" <>
"1;1754937004;USDT;USDT;100.5;userA;;alta_cuenta\n" <>
"2;1755541804;BTC;USDT;0.1;userB;;swap\n" <>
"3;1756751404;BTC;;50000.0;userC;;alta_cuenta\n" <>
"4;1757183404;USDT;BTC;500.25;userD;userE;transferencia\n" <>
"5;1757615404;ETH;USDT;1.5;userF;userG;swap\n"
    assert expected_output == capture_io(fn ->
      LedgerApp.CLI.main(["transacciones", "-t", "test_data.csv"])
    end)
  end

  test "usar el comando balance sin el flag -c1 debe arrojar un error" do
    expected_output = "{:error, Debe especificar una cuenta origen con -c1}\n"
    assert expected_output == capture_io(fn ->
      LedgerApp.CLI.main(["balance", "-t", "test_data.csv"])
    end)
  end

  test "si la cuenta buscada no esta dentro de los datos debe devolver una lista de transacciones vacia" do
    expected_output = "ID_TRANSACCION;TIMESTAMP;MONEDA_ORIGEN;MONEDA_DESTINO;MONTO;CUENTA_ORIGEN;CUENTA_DESTINO;TIPO\n"
    assert capture_io(fn ->
      LedgerApp.CLI.main(["transacciones", "-t", "test_data.csv", "-c1", "userX"])
    end) == expected_output
  end

  test "una moneda fuera del mapa de conversion devuelve un error" do
    expected_output = "{:error, La moneda no existe en el archivo de monedas}\n"
    assert capture_io(fn ->
      LedgerApp.CLI.main(["balance", "-c1", "userA", "-t", "test_data.csv", "-m", "DOGE"])
    end) == expected_output
  end

  test "un comando no conocido devuelve un mensaje de error" do
    expected_output = "Comando no reconocido\n"
    assert expected_output == capture_io(fn ->
      LedgerApp.CLI.main(["comando_inexistente", "-t", "test_data.csv"])
    end)
  end

  test "un flag no reconocido devuelve un mensaje de error" do
    expected_output = "-flag_inexistente no se reconoce como opcion valida\n"
    assert expected_output == capture_io(fn ->
      LedgerApp.CLI.main(["balance", "-flag_inexistente", "userA", "-t", "test_data.csv"])
    end)
  end

  test "un balance se imprime correctamente en consola" do
    expected_output = "MONEDA=BALANCE\nUSDT=100.500000\n"
    assert expected_output == capture_io(fn ->
      LedgerApp.CLI.main(["balance", "-c1", "userA", "-t", "test_data.csv"])
    end)
  end

  test "un balance con cuenta origen y cuenta destino devuelve una lista de transacciones entre ellos" do
    expected_output = "{:error, No se puede especificar una cuenta destino en este comando}\n"
    assert expected_output == capture_io(fn ->
      LedgerApp.CLI.main(["balance", "-t", "test_data.csv", "-c1", "userA", "-c2", "userB"])
    end)

  end

  test "una transaccion entre dos cuentas se obtienen correctamente" do
    content = """
      id_transaccion;timestamp;moneda_origen;moneda_destino;monto;cuenta_origen;cuenta_destino;tipo
      1;1754937001;USDT;;18000;userA;;alta_cuenta
      2;1754937002;EUR;;25000;userB;;alta_cuenta
      3;1754937010;USDT;USDT;1200;userA;userB;transferencia
      4;1754937030;USDT;USDT;2300;userA;userC;transferencia
      5;1754937060;USDT;USDT;800;userA;userD;transferencia
      6;1754937070;USDT;USDT;6150;userA;userE;transferencia
      7;1754937090;EUR;EUR;3980;userB;userA;transferencia
      """
    expected_output = """
      ID_TRANSACCION;TIMESTAMP;MONEDA_ORIGEN;MONEDA_DESTINO;MONTO;CUENTA_ORIGEN;CUENTA_DESTINO;TIPO
      3;1754937010;USDT;USDT;1200.0;userA;userB;transferencia
      """
    test_path = TestHelper.create_temp_csv(content, "transaccion_entre_cuentas.csv")
    arguments = ["transacciones", "-t", test_path, "-c1", "userA", "-c2", "userB"]
    assert expected_output == capture_io(fn ->
      LedgerApp.CLI.main(arguments)
    end)
    TestHelper.cleanup_temp_file(test_path)
  end

end
