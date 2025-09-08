defmodule Ledger.TransactionsTests do
  use ExUnit.Case

  describe "ledger_transacciones/n" do

    test "show all transactions" do
      assert {:ok, transactions} = Ledger.get_transactions()
    end
  end

end
