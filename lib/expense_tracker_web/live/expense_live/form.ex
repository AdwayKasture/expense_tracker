defmodule ExpenseTrackerWeb.ExpenseLive.Form do
  alias ExpenseTracker.Amount
  alias ExpenseTracker.Account
  alias ExpenseTracker.Account.Expense
  use ExpenseTrackerWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage expense records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="expense-form" phx-change="validate" phx-submit="save">
        <.input
          :if={@selected_category == nil}
          field={@form[:category_id]}
          type="select"
          label="Category"
          options={@category_opts}
        />
        <.input :if={@selected_category !== nil} field={@form[:date]} type="date" label="Date" />
        <.input :if={@selected_category !== nil} field={@form[:amount]} type="text" label="Amount" />
        <.input :if={@selected_category !== nil} field={@form[:notes]} type="text" label="Notes" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Expense</.button>
          <.button navigate={return_path(@return_to, @expense)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    category_opts =
      Account.list_categories()
      |> Enum.map(fn cat -> {cat.name, cat.id} end)

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:category_opts, [{"Select category", nil}] ++ category_opts)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    expense = Account.get_expense!(id)
    expense = %{expense|amount: expense.amount /100}
    socket
    |> assign(:page_title, "Edit Expense")
    |> assign(:expense, expense)
    |> assign(selected_category: expense.category_id)
    |> assign(:form, to_form(Account.change_expense(expense)))
  end

  defp apply_action(socket, :new, _params) do
    expense = %Expense{}

    socket
    |> assign(:page_title, "New Expense")
    |> assign(:expense, expense)
    |> assign(selected_category: nil)
    |> assign(:form, to_form(Account.change_expense(expense)))
  end

  @impl true
  def handle_event("validate", %{"expense" => expense_params}, socket) do
    {socket, expense_params} =
      case Map.get(expense_params, "category_id") do
        nil ->
          {socket, expense_params}

        id ->
          {assign(socket, selected_category: String.to_integer(id)),
           %{expense_params | "category_id" => String.to_integer(id)}}
      end

    params =
      case Map.get(expense_params, "amount") do
        nil -> expense_params
        v -> %{expense_params | "amount" => Amount.adjusted_amount(v)}
      end

    changeset = Account.change_expense(socket.assigns.expense, params)

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"expense" => expense_params}, socket) do
    save_expense(socket, socket.assigns.live_action, expense_params)
  end

  defp save_expense(socket, :edit, expense_params) do
    expense_params =
      case Map.get(expense_params, "category_id") do
        nil -> expense_params
        [id] -> %{expense_params | "category_id" => String.to_integer(id)}
      end

    params =
      case Map.get(expense_params, "amount") do
        nil -> expense_params
        v -> %{expense_params | "amount" => Amount.adjusted_amount(v)}
      end

    case Account.update_expense(socket.assigns.expense, params) do
      {:ok, expense} ->
        {:noreply,
         socket
         |> put_flash(:info, "Expense updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, expense))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_expense(socket, :new, expense_params) do
    expense_params = Map.put(expense_params, "category_id", socket.assigns.selected_category)

    params =
      case Map.get(expense_params, "amount") do
        nil -> expense_params
        v -> %{expense_params | "amount" => Amount.adjusted_amount(v)}
      end

    IO.inspect(params)

    case Account.create_expense(params) do
      {:ok, expense} ->
        {:noreply,
         socket
         |> put_flash(:info, "Expense created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, expense))}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _expense), do: ~p"/expenses"
  defp return_path("show", expense), do: ~p"/expenses/#{expense}"
end
