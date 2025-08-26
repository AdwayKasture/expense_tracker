defmodule ExpenseTracker.CategoryFixture do
  def test_category(attrs \\ %{}) do
    Map.merge(%{name: "Food", monthly_budget: 3035}, attrs, fn _k, _l, r -> r end)
  end
end
