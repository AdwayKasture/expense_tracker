defmodule ExpenseTracker.CategoryTest do
  use ExUnit.Case, async: true
  import Ecto.Changeset
  alias ExpenseTracker.Account.Category
  import ExpenseTracker.CategoryFixture

  describe "valid changeset" do
    
    test "positive case" do
      changeset = Category.changeset(%Category{},test_category())

      assert changeset.valid?
    end

    test "missing required fields" do
      changeset = Category.changeset(%Category{},%{})

      refute changeset.valid?

      assert {"can't be blank", [validation: :required]} == Keyword.get(changeset.errors, :name)
      assert {"can't be blank", [validation: :required]} == Keyword.get(changeset.errors, :monthly_budget)
 
    end

    test "default amount normalization" do
      
      %{monthly_budget: amt} = test_category()

      changeset = Category.changeset(%Category{},test_category())

      assert changeset.valid?

      assert get_change(changeset,:monthly_budget) == amt * 100
    end

    test "amount normalization" do
      

      changeset = Category.changeset(%Category{},test_category(%{monthly_budget: 1,currency_offset: 10}))

      assert changeset.valid?

      assert get_change(changeset,:monthly_budget) == 10
    end


  end

end
