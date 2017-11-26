defmodule Helix.Server.Action.Motherboard do

  alias Helix.Server.Internal.Motherboard, as: MotherboardInternal

  defdelegate setup(mobo, initial_components),
    to: MotherboardInternal

  defdelegate link(motherboard, mobo_component, link_component, slot_id),
    to: MotherboardInternal
  defdelegate link(motherboard, link_component, slot_id),
    to: MotherboardInternal

  defdelegate unlink(component),
    to: MotherboardInternal
end