defmodule HELM.Software.Model.StorageDrive do

  use Ecto.Schema

  alias HELL.PK
  alias HELM.Software.Model.Storage, as: MdlStorage, warn: false
  import Ecto.Changeset

  @type t :: %__MODULE__{
    storage_id: PK.t,
    storage: MdlStorage.t,
    drive_id: integer,
    inserted_at: Ecto.DateTime.t,
    updated_at: Ecto.DateTime.t
  }

  @primary_key false
  @creation_fields ~w/drive_id storage_id/a

  schema "storage_drives" do
    belongs_to :storage, MdlStorage,
      foreign_key: :storage_id,
      references: :storage_id,
      type: EctoNetwork.INET,
      primary_key: true

    field :drive_id, :integer, primary_key: true

    timestamps
  end

  @spec create_changeset(%{drive_id: PK.t, storage_id: PK.t}) :: Ecto.Changeset.t
  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, @creation_fields)
    |> validate_required(@creation_fields)
  end
end