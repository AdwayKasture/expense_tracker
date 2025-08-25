Ok first thing i need to decide is the database schema

* Category(category_id,name,description,monthly_budget,currency_offset(for rounding))
# for handling currency will multiply all ammounts by currency offset (100)
# for currencies with different precision (1.2 x ,1.345 y ) we will have offset 10 and 1000 resp. we will also have to store currency_id 

* Expense(expense_id,date,amount,optional_notes,category)
# Assumption here is that an expense can only belong to one category.



