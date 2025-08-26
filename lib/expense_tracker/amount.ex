defmodule ExpenseTracker.Amount do
  @currency_offset 100

  def get_offset, do: @currency_offset

  def adjusted_amount(amt) do
    case amt do
      nil ->
        nil

      v ->
        case Float.parse(v) do
          {v, _} -> round(v * get_offset())
          _ -> nil
        end
    end
  end
end
