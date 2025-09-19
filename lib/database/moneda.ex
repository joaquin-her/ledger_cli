defmodule Database.Moneda do
  defstruct [:nombre, :valor]

  defimpl String.Chars do
    def to_string(%Database.Moneda{nombre: nombre, valor: valor}) do
      "#{nombre}=#{:erlang.float_to_binary(valor, [{:decimals, 6}])}"
    end
  end
end
