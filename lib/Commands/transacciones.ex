defmodule Commands.TransactionsCommand do
  @moduledoc """
  Subcomando para listar transacciones
  """

  def filter(transactions, arguments) do
    transactions
    |> filter_by_origin_account(arguments.cuenta_origen)
  end

  def filter_by_origin_account(transactions, account_name) do
    case account_name do
      "all" -> transactions
      _ ->
        transactions
        |> Enum.filter(fn transaction -> transaction.cuenta_origen == account_name end)
    end
  end

  def get_transactions_of_account(transactions, account_name) do
    transactions
    |> Enum.filter(fn t -> t.cuenta_origen == account_name or t.cuenta_destino == account_name end)
    |> Enum.sort_by(fn t -> t.timestamp end)
  end

  def filter_by_destiny_account(transactions, account_name) do
    case account_name do
      "all" -> transactions
      _ ->
        transactions
        |> Enum.filter(fn transaction -> transaction.cuenta_destino == account_name end)
    end
  end
end
