# test/transaccion_test.exs
defmodule TransaccionTest do
  use ExUnit.Case
  doctest Transaccion

  describe "Transaccion struct" do
    test "crea una transaccion con todos los campos" do
      transaccion =
        %Transaccion{
        id: 2,
        tipo: :compra,
        cuenta_origen: "userB",
        cuenta_destino: "exchange",
        moneda_origen: "USD",
        moneda_destino: "BTC",
        monto: "100.50",
        timestamp: "1754937005"
      }

      assert transaccion.cuenta_destino == "exchange"
      assert transaccion.moneda_origen == "USD"
      assert transaccion.moneda_destino == "BTC"
      assert transaccion.monto == "100.50"
    end
  end
end
