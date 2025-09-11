defmodule Transaccion do
  @enforce_keys [:id, :tipo, :cuenta_origen, :timestamp]
  defstruct [:id, :timestamp, :moneda_origen, :moneda_destino, :monto, :cuenta_origen, :cuenta_destino, :tipo]

  def get_keys() do
    [ :id, :timestamp, :moneda_origen, :moneda_destino, :monto, :cuenta_origen, :cuenta_destino, :tipo ]
  end

  defimpl String.Chars do

    def to_string(%Transaccion{id: id, timestamp: timestamp, moneda_origen: moneda_origen, moneda_destino: moneda_destino, monto: monto, cuenta_origen: cuenta_origen, cuenta_destino: cuenta_destino, tipo: tipo}) do
      " #{id} |" <>
      " #{timestamp} |" <>
      " #{moneda_origen} |" <>
      " #{moneda_destino} |" <>
      " #{monto} |" <>
      " #{cuenta_origen} |" <>
      " #{cuenta_destino} |" <>
      " #{tipo}"
    end
  end
end
