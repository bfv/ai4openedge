block-level on error undo, throw.

var int customerNumber = 3000.
var decimal orderTotal.

for each Order no-lock
  where Order.CustNum = customerNumber
  by Order.OrderNum:

  orderTotal = 0.

  display
    Order.OrderNum label "Bestelling"
    Order.OrderDate label "Datum"
    skip
    "Artikel" label "Artikel"
    "Aantal" label "Aantal"
    "Regelbedrag" label "Regelbedrag"
    with frame orderHeader width 80.

  for each OrderLine of Order no-lock,
    first Item of OrderLine no-lock:

    display
      Item.ItemName format "x(25)"
      OrderLine.Qty
      OrderLine.ExtendedPrice format ">>>,>>9.99"
      with frame orderLines width 80.

    orderTotal += OrderLine.ExtendedPrice.
  end.

  display
    orderTotal format ">>>,>>9.99" label "Totaal bestelling"
    with frame orderTotalFrame width 80.
end.