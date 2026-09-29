for each customer no-lock:
  display customer.Name.
end.

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

message "Customer display completed.".