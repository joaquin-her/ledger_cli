defmodule CliTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias LedgerApp.CLI
  test "print in console all transactions" do
    expected_output =
"ID | TIMESTAMP | MONEDA_ORIGEN | MONEDA_DESTINO | MONTO | CUENTA_ORIGEN | CUENTA_DESTINO | TIPO\n" <>
" 1 | 1754937004 | USDT | USDT | 100.50 | userA | userB | transferencia\n" <>
" 2 | 1755541804 | BTC | USDT | 0.1 | userB |  | swap\n" <>
" 3 | 1756751404 | BTC |  | 50000 | userC |  | alta_cuenta\n" <>
" 4 | 1757183404 | USDT | BTC | 500.25 | userD | userE | transferencia\n" <>
" 5 | 1757615404 | ETH | USDT | 1.5 | userF | userG | swap\n"
    assert expected_output == capture_io(fn ->
      LedgerApp.CLI.run_command("transacciones -t test_data.csv")
    end)
  end
end
