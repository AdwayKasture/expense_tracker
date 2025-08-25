Ok first thing i need to decide is the database schema

* Category(category_id,name,description,monthly_budget,currency_offset(for rounding))
# for handling currency will multiply all ammounts by currency offset (100)
# for currencies with different precision (1.2 x ,1.345 y ) we will have offset 10 and 1000 resp. we will also have to store currency_id 

* Expense(expense_id,date,amount,optional_notes,category)
# Assumption here is that an expense can only belong to one category.
# assumption we use same currency for expense as for its parent category

* when adding expense  we must have date,amount ,category 
    when we insert expense we must check that the amount + expense of last month is < budget 
    
    Adding more constraint on amount and monthly_budget must be > 0 and less than 10_000 (assumption)


# when creating crud for expenses user can select expense from drop down

# for real time update of list , we will use PubSub , where the liveview will listen to successful capture of expense and update the list accordingly


# TODO

tests for expenses
review ecto types, length validation on desc

