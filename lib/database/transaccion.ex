defmodule Transaccion do
  @enforce_keys [:id, :tipo, :cuenta_origen, :timestamp]
  defstruct [:id, :timestamp, :moneda_origen, :moneda_destino, :monto, :cuenta_origen, :cuenta_destino, :tipo]
end
