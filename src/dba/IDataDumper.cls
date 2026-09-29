
 /*------------------------------------------------------------------------
    File        : IDataDumper
    Purpose     : 
    Syntax      : 
    Author(s)   : bronco
    Created     : Tue Sep 22 17:44:20 +02:00 2026
    Notes       : 
  ----------------------------------------------------------------------*/

interface dba.IDataDumper:

  method public void InitializeDump(bufferHandle as handle, destinationFile as char).
  method public void DumpRow(rowBuffer as handle).
  method public void FinalizeDump().

end interface.
