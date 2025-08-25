defmodule ExpenseTracker.Repo.Migrations.Expenses do
  use Ecto.Migration

  def change do
    create table(:expenses) do
      add :date, :date
      add :amount, :integer
      add :notes, :string
      add :category_id, references(:categories, on_delete: :nothing)

      timestamps()
    end

    create index(:expenses, [:category_id])
  end
end
