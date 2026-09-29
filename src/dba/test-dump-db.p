using dba.DataDumper.

var DataDumper dumper = new dba.DataDumper(new dba.DataDumperJson()).

dumper:DumpDatabase("sports2020", "all", "/workspaces/content/db/json").

message "Database dump completed.".
