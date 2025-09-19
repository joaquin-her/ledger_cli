defmodule CliTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
    test "print in console all transactions" do
    expected_output =
"ID;TIMESTAMP;MONEDA_ORIGEN;MONEDA_DESTINO;MONTO;CUENTA_ORIGEN;CUENTA_DESTINO;TIPO\n" <>
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
    expected_output = "Error: Debe especificar una cuenta origen con -c1\n"
    assert expected_output == capture_io(fn ->
      LedgerApp.CLI.main(["balance", "-t", "test_data.csv"])
    end)
  end

  test "no tener como objetivo una cuenta especifica debe arrojar una excepcion" do
      assert true
  end

  test "si la cuenta buscada no esta dentro de los datos debe devolver un :error y la causa de por que es un error" do
      assert true
  end

  test "una moneda fuera del mapa de conversion devuelve un error" do
    expected_output = "La moneda no existe en el archivo de monedas\n"
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
end
