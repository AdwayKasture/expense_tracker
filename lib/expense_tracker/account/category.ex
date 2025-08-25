defmodule ExpenseTracker.Account.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @currency_offset 100

  schema "categories" do
    field :name,:string 
    field :description,:string
    field :monthly_budget,:integer
    field :currency_offset,:integer,default: @currency_offset
    
  end
  
  def changeset(category,attrs) do
    category
    |> cast(attrs,[:name,:description,:monthly_budget,:currency_offset])
    |> validate_required([:name,:monthly_budget])
    |> normalize_amount(:monthly_budget)

  end

  def normalize_amount(changeset,field) do
      offset = get_change(changeset,:currency_offset,@currency_offset)
      case get_change(changeset,field,:missing) do
        :missing -> changeset
        val -> put_change(changeset,field,offset * val ) 
      end
      
  end

end
