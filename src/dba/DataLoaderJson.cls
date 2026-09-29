
 /*------------------------------------------------------------------------
    File        : DataLoaderJson
    Purpose     : 
    Syntax      : 
    Author(s)   : bronco
    Created     : Tue Sep 22 17:42:24 +02:00 2026
    Notes       : 
  ----------------------------------------------------------------------*/


using Progress.Json.ObjectModel.*.
using dba.IDataLoader.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Json.ObjectModel.ObjectModelParser.

block-level on error undo, throw.


class dba.DataLoaderJson implements IDataLoader:

  var handle ttHandle, ttBufferHandle.
  var JsonArray rows.
  var int iterator.

  constructor public DataLoaderJson():
    
  end constructor.
  
  method public void InitializeLoad(bufferHandle as handle, sourceFile as char):

    var ObjectModelParser parser = new ObjectModelParser().

    rows = cast(parser:ParseFile(sourceFile), JsonArray).

    create temp-table ttHandle.
    ttHandle:create-like(bufferHandle). 
    ttHandle:temp-table-prepare("tt").
    ttBufferHandle = ttHandle:default-buffer-handle.
    ttBufferHandle:buffer-create().
    
    message substitute("Loaded &1 rows from &2", string(rows:Length), sourceFile).

  end method.  // InitializeLoad

  method public handle GetNextRow():

    var JsonObject row.
    var logical readOk.

    iterator += 1.
    if iterator > rows:Length then
      return ?.

    row = rows:GetJsonObject(iterator).
    readOk = ttBufferHandle:read-json("JsonObject", row, "empty").
    ttBufferHandle:find-first().

    return ttBufferHandle.
    
  end method.  // GetNextRow

  method public void FinalizeLoad():
    // nothing to finalize
  end method.  // FinalizeLoad

end class.  // DataLoaderJson
