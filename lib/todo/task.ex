defmodule Todo.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :name, :string
    field :status, :integer

    timestamps()
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :status])
    |> validate_required([:name, :status])
  end
end
