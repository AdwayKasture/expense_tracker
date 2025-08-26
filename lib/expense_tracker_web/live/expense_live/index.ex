defmodule ExpenseTrackerWeb.ExpenseLive.Index do
  alias Phoenix.LiveView
  alias ExpenseTracker.Account.Expense
  alias ExpenseTracker.Account
  use ExpenseTrackerWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Expenses
        <:actions>
          <.button variant="primary" navigate={~p"/expenses/new"}>
            <.icon name="hero-plus" /> New Expense
          </.button>
        </:actions>
      </.header>

      <.table
        id="expenses"
        rows={@streams.expenses}
        row_click={fn {_id, expense} -> JS.navigate(~p"/expenses/#{expense}") end}
      >
        <:col :let={{_id, expense}} label="Date">{expense.date}</:col>
        <:col :let={{_id, expense}} label="Amount">{expense.amount / 100}</:col>
        <:col :let={{_id, expense}} label="Notes">{expense.notes}</:col>
        <:action :let={{_id, expense}}>
          <div class="sr-only">
            <.link navigate={~p"/expenses/#{expense}"}>Show</.link>
          </div>
          <.link navigate={~p"/expenses/#{expense}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, expense}}>
          <.link
            phx-click={JS.push("delete", value: %{id: expense.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do

    if connected?(socket), do: Phoenix.PubSub.subscribe(ExpenseTracker.PubSub,Expense.get_topic())
      

    {:ok,
     socket
     |> assign(:page_title, "Listing Expenses")
     |> stream(:expenses, Account.list_expenses())}
  end

  @impl LiveView
  def handle_info({:new,expense}, socket) do
    socket
    |> stream_insert(:expenses,expense,at: :head)
    |> noreply()
  end

  defp noreply(data),do: {:noreply,data}

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    expense = Account.get_expense!(id)
    {:ok, _} = Account.delete_expense(expense)

    {:noreply, stream_delete(socket, :expenses, expense)}
  end
end
