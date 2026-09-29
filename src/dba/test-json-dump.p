using dba.DataDumper.

var char tableName = "salesrep".
var DataDumper dumper = new dba.DataDumper(new dba.DataDumperJson()).

if false then do:
  dumper:DumpData(tableName, tableName + ".json", "").
  message "JSON dump completed.".
end.
else do:
  disable triggers for load of salesrep.
  for each salesrep exclusive-lock:
    delete salesrep.
  end.
  message "Salesrep table cleared.".
end.

message "done".
