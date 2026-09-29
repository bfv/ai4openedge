using dba.DataLoader.

var DataLoader loader = new dba.DataLoader(new dba.DataLoaderJson()).

// if true then do:
//   disable triggers for load of customer.
//   for each customer exclusive-lock:
//     delete customer.
//   end.
//   message "customer table cleared.".
//   disable triggers for load of order.
//   for each order exclusive-lock:
//     delete order.
//   end.
//   message "order table cleared.".
// end.

//loader:LoadDatabase("sports2020", "customer,order", "/workspaces/content/db/json").
loader:LoadDatabase("sports2020", "", "/workspaces/content/db/json").

message "Database load completed.".

