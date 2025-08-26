defmodule ExpenseTracker.Account.Expense do
  alias ExpenseTracker.Account
  alias ExpenseTracker.Repo
  alias ExpenseTracker.Account.Expense
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @broadcast_topic "expenses"

  schema "expenses" do
    field :date, :date
    field :amount, :integer
    field :notes, :string

    belongs_to :category, ExpenseTracker.Account.Category

    timestamps(type: :utc_datetime)
  end

  def changeset(expense, attrs) do
    expense
    |> cast(attrs, [:amount, :date, :notes, :category_id])
    |> validate_required([:amount, :date, :category_id])
    |> validate_number(:amount, greater_than: 0, less_than_or_equal_to: 1_000_000)
    |> validate_budget()
    |> foreign_key_constraint(:category_id)
  end

  defp validate_budget_constraint(changeset, cat) do
    last_date = get_change(changeset, :date)
    amt = get_change(changeset, :amount)

    case {last_date, amt} do
      {nil, _} ->
        changeset

      {_, nil} ->
        changeset

      {last_date, amt} ->
        start_date = Date.beginning_of_month(last_date)

        query = get_monthly_expense(cat.id,start_date,last_date)
          
        total = Repo.one(query) || 0

        # TODO adjust amount with offset in error message
        if total + amt > cat.monthly_budget do
          add_error(
            changeset,
            :amount,
            "Amount excedes budget by #{total + amt - cat.monthly_budget}"
          )
        else
          changeset
        end
    end
  end

  defp validate_budget(changeset) do
    category_id = get_change(changeset, :category_id)

    if category_id !== nil do
      validate_budget_constraint(changeset, Account.get_category!(category_id))
    else
      changeset
    end
  end

  def get_monthly_expense(category_id,start_date,end_date) do
    from e in Expense,
            where: e.category_id == ^category_id and e.date >= ^start_date and e.date <= ^end_date,
            select: sum(e.amount)
  end

  def get_topic(),do: @broadcast_topic
end
