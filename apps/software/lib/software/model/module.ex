defmodule HELM.Software.Model.Module do

  use Ecto.Schema
  import Ecto.Changeset

  alias HELL.PK
  alias HELM.Software.Model.ModuleRole, as: MdlModuleRole, warn: false
  alias HELM.Software.Model.File, as: MdlFile, warn: false

  @type t :: %__MODULE__{
    module_version: non_neg_integer,
    file: MdlFile.t,
    file_id: PK.t,
    role: MdlModuleRole.t,
    module_role: String.t,
    inserted_at: Ecto.DateTime.t,
    updated_at: Ecto.DateTime.t
  }

  @primary_key false
  @creation_fields ~w/file_id module_role module_version/a

  schema "modules" do
    field :module_version, :integer

    belongs_to :file, MdlFile,
      foreign_key: :file_id,
      references: :file_id,
      type: EctoNetwork.INET,
      primary_key: true

    belongs_to :role, MdlModuleRole,
      foreign_key: :module_role,
      references: :module_role,
      type: :string,
      primary_key: true

    timestamps
  end

  @spec create_changeset(%{
    file_id: PK.t,
    module_role: String.t,
    module_version: non_neg_integer}) :: Ecto.Changeset.t
  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, @creation_fields)
    |> validate_required([:file_id, :module_role])
    |> validate_number(:module_version, greater_than: 0)
  end
end