defmodule Helix.Universe.Bank.Internal.BankTest do

  use Helix.Test.IntegrationCase

  import Helix.Test.IDCase

  alias Helix.Universe.Bank.Internal.Bank, as: BankInternal
  alias Helix.Universe.NPC.Model.NPC

  alias HELL.TestHelper.Setup
  alias Helix.Universe.NPC.Helper, as: NPCHelper

  describe "create/1" do
    test "creates when params are valid" do
      npc = Setup.npc()

      params = %{
        bank_id: npc.npc_id,
        name: "BancoPelado"
      }

      assert {:ok, _} = BankInternal.create(params)
    end

    test "refuses to create when data is invalid" do
      params = %{bank_id: NPC.ID.generate, name: "asdf"}
      assert_raise Ecto.ConstraintError, fn ->
        BankInternal.create(params)
      end
    end
  end

  describe "fetch/1" do
    test "fetches with valid data" do
      bank_id = NPCHelper.bank().id
      bank = BankInternal.fetch(bank_id)
      assert bank
      assert_id bank.bank_id, bank_id
    end
  end
end
