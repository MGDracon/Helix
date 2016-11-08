defmodule HELM.Entity.Controller.EntityServerTest do
  use ExUnit.Case

  alias HELL.IPv6
  alias HELL.TestHelper.Random, as: HRand
  alias HELM.Entity.Controller.Entity, as: CtrlEntity
  alias HELM.Entity.Controller.EntityType, as: CtrlEntityType
  alias HELM.Entity.Controller.EntityServer, as: CtrlEntityServer

  setup do
    type = HRand.string()
    ref_id = IPv6.generate([])
    id = IPv6.generate([])
    payload = %{entity_type: type, reference_id: ref_id}
    {:ok, type: type, id: id, payload: payload}
  end

  test "create/1", %{type: type, payload: payload, id: id} do
    {:ok, _} = CtrlEntityType.create(type)
    {:ok, entity} = CtrlEntity.create(payload)
    assert {:ok, _} = CtrlEntityServer.create(id, entity.entity_id)
  end

  describe "find/1" do
    test "success", %{type: type, payload: payload, id: id} do
      {:ok, _} = CtrlEntityType.create(type)
      {:ok, entity} = CtrlEntity.create(payload)
      {:ok, entity_server} = CtrlEntityServer.create(id, entity.entity_id)
      assert {:ok, ^entity_server} = CtrlEntityServer.find(entity_server.server_id)
    end

    test "failure" do
      assert {:error, :notfound} = CtrlEntityServer.find(IPv6.generate([]))
    end
  end

  test "delete/1 idempotency", %{type: type, payload: payload, id: id} do
    {:ok, _} = CtrlEntityType.create(type)
    {:ok, entity} = CtrlEntity.create(payload)
    {:ok, entity_server} = CtrlEntityServer.create(id, entity.entity_id)
    assert :ok = CtrlEntityServer.delete(entity_server.server_id)
    assert :ok = CtrlEntityServer.delete(entity_server.server_id)
  end
end