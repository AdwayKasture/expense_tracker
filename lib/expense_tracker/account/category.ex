defmodule ExpenseTracker.Account.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @currency_offset 100

  schema "categories" do
    field :name,:string 
    field :description,:string
    field :monthly_budget,:integer
    field :currency_offset,:integer,default: @currency_offset
    
    timestamps(type: :utc_datetime)
  end
  
  def changeset(category,attrs) do
    category
    |> cast(attrs,[:name,:description,:monthly_budget,:currency_offset])
    |> validate_required([:name,:monthly_budget])
    |> normalize_amount(:monthly_budget)
    |> validate_number(:monthly_budget, greater_than: 0,less_than_or_equal_to: 1_000_000)
    |> unique_constraint(:name)

  end

  def normalize_amount(changeset,field) do
    if not changed?(changeset,field) do
      changeset
    else
      offset = get_change(changeset,:currency_offset,@currency_offset)
      case get_change(changeset,field,:missing) do
        :missing -> changeset
        val -> put_change(changeset,field,offset * val ) 
      end
    end
  end

end
