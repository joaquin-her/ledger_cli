defmodule LedgerAppTest do
  use ExUnit.Case
  doctest LedgerApp

  test "greets the world" do
    assert LedgerApp.hello() == :world
  end
end
