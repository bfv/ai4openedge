using dba.*.

var char tableName = "salesrep".
var DataLoader loader = new dba.DataLoader(new dba.DataLoaderJson()).
var logical loadOk. 
var char messageString.

if true then do:
  disable triggers for load of salesrep.
  for each salesrep exclusive-lock:
    delete salesrep.
  end.
  message "Salesrep table cleared.".
end.

loadOk = loader:LoadData(tableName, tableName + ".json").

messageString = substitute("done, loadOk: &1", loadOk).
message messageString.
