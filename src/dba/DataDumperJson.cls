
 /*------------------------------------------------------------------------
    File        : DataDumperJson
    Purpose     : 
    Syntax      : 
    Author(s)   : bronco
    Created     : Tue Sep 22 17:43:13 +02:00 2026
    Notes       : 
  ----------------------------------------------------------------------*/

using dba.DataDumper.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.

block-level on error undo, throw.


class dba.DataDumperJson implements dba.IDataDumper:

  var private handle ttHandle, ttBufferHandle.
  var private JsonArray rows.
  var private char outputFile.
  define stream jsonStream.

  method public void InitializeDump(bufferHandle as handle, destinationFile as char):

    create temp-table ttHandle.
    ttHandle:create-like(bufferHandle). 
    ttHandle:temp-table-prepare("tt").
    ttBufferHandle = ttHandle:default-buffer-handle.
    ttBufferHandle:buffer-create().

    rows = new JsonArray().
    outputFile = destinationFile.

  end method.  // InitializeDump

  method public void DumpRow(rowBuffer as handle):
    var JsonObject jsonRow = new JsonObject().

    do on error undo, throw:
      ttBufferHandle:buffer-copy(rowBuffer).
      ttBufferHandle:serialize-row("json", "JsonObject", jsonRow, true, ?, ?, true).
      rows:add(jsonRow).
    end.
    
  end method.  // DumpRow

  method public void FinalizeDump():
    
    var handle streamHandle.
    
      /* Write the JSON array to the output file */
    output stream jsonStream to value(outputFile).

    streamHandle = stream jsonStream:handle.
    rows:write(streamHandle, true).

    output stream jsonStream close.

    if valid-handle(ttHandle) then
      delete object ttHandle.

  end method.  // FinalizeDump

end class.  // DataDumperJson
