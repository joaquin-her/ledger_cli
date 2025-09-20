defmodule Transaccion do
  @enforce_keys [:id, :tipo, :cuenta_origen, :timestamp]
  defstruct [:id, :timestamp, :moneda_origen, :moneda_destino, :monto, :cuenta_origen, :cuenta_destino, :tipo]

  def new(id, timestamp, moneda_origen, moneda_destino, monto, cuenta_origen, cuenta_destino, tipo) do
    cond do
      not is_float(monto) or monto <= 0 -> {:error, "Amount must be a positive float"}
      tipo not in [:transferencia, :alta_cuenta, :swap] -> {:error, "Invalid transaction type"}
      true ->
        {:ok, %__MODULE__{
          id: id,
          timestamp: timestamp,
          moneda_origen: moneda_origen,
          moneda_destino: moneda_destino,
          monto: monto,
          cuenta_origen: cuenta_origen,
          cuenta_destino: cuenta_destino,
          tipo: tipo
        }}
    end
  end
  defimpl String.Chars do

    def to_string(%Transaccion{id: id, timestamp: timestamp, moneda_origen: moneda_origen, moneda_destino: moneda_destino, monto: monto, cuenta_origen: cuenta_origen, cuenta_destino: cuenta_destino, tipo: tipo}) do
      "#{id};" <>
      "#{timestamp};" <>
      "#{moneda_origen};" <>
      "#{moneda_destino};" <>
      "#{:erlang.float_to_binary(monto, [{:decimals, 6}, :compact])};" <>
      "#{cuenta_origen};" <>
      "#{cuenta_destino};" <>
      "#{tipo}";
    end
  end
end
