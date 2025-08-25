defmodule ExpenseTracker.Repo.Migrations.Category do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :description, :string
      add :monthly_budget, :integer, null: false
      add :currency_offset, :integer, default: 100, null: false

      timestamps()
    end
      create unique_index(:categories,[:name])
  end
end
