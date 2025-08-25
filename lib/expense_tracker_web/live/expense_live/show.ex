defmodule ExpenseTrackerWeb.ExpenseLive.Show do
alias ExpenseTracker.Account
  use ExpenseTrackerWeb,:live_view


  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Expense {@expense.id}
        <:subtitle>This is a expense record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/expenses"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/expenses/#{@expense}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit expense
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Date">{@expense.date}</:item>
        <:item title="Amount">{@expense.amount}</:item>
        <:item title="Notes">{@expense.notes}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Expense")
     |> assign(:expense, Account.get_expense!(id))}
  end

  
end
