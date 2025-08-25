defmodule ExpenseTracker.Account.Expense do
  alias ExpenseTracker.Repo
  alias ExpenseTracker.Account.Expense
  alias ExpenseTracker.Account.Category
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "expenses" do
    field :date, :date
    field :amount, :integer
    field :notes, :string
    
    belongs_to :category, ExpenseTracker.Account.Category
    
    timestamps()
  end  

  def changeset(expense,%Category{} = category,attrs) do
    expense
    |> cast(attrs,[:amount,:date,:notes])
    |> put_change(:category_id,category.id)
    |> validate_required([:amount,:date,:category_id])
    |> normalize_amount(:amount,category.currency_offset)
    |> validate_number(:amount, greater_than: 0,less_than_or_equal_to: 1_000_000)
    |> validate_budget_constraint(category)
  end

  defp normalize_amount(changeset,field,offset) do
    case get_field(changeset,field,:missing) do
      :missing -> changeset
      val -> put_change(changeset,field,offset * val)
    end
  end

  defp validate_budget_constraint(changeset,cat = %Category{}) do
    last_date = get_change(changeset,:date)
    case last_date do
      nil -> changeset
      last_date -> 
        start_date = Date.beginning_of_month(last_date)
        query = from e in Expense,
          where: e.category_id == ^cat.id and e.date >= ^start_date and e.date <= ^last_date,
          select: sum(e.amount)
        total = Repo.one(query) || 0

        amt = get_change(changeset,:amount)
        # TODO adjust amount with offset in error message
        if total + amt > cat.monthly_budget do
          add_error(changeset,:amount,"Amount excedes budget by #{total + amt - cat.monthly_budget}")
        else
          changeset
        end

    end
          
  end


  
end
