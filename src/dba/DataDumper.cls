
 /*------------------------------------------------------------------------
    File        : DataDumper
    Purpose     : 
    Syntax      : 
    Author(s)   : bronco
    Created     : Tue Sep 22 17:42:44 +02:00 2026
    Notes       : 
  ----------------------------------------------------------------------*/

using dba.IDataDumper.

block-level on error undo, throw.


class dba.DataDumper:
  
  var IDataDumper dumperImplementation.

  constructor public DataDumper():
  end constructor.

  constructor public DataDumper(implementation as IDataDumper):
    SetDumperImplementation(implementation).
  end constructor.

  method public void SetDumperImplementation(implementation as IDataDumper):
    dumperImplementation = implementation.
  end method.  // SetDumperImplementation

  method public char DumpData(tableName as char, destinationFile as char, queryString as char):

    var handle queryHandle, bufferHandle.

    if queryString = "" or queryString = ? then 
      queryString = "for each " + tableName.

    create buffer bufferHandle for table tableName.
    create query queryHandle.

    queryHandle:set-buffers(bufferHandle).
    queryHandle:query-prepare(queryString).
    queryHandle:query-open(). 

    dumperImplementation:InitializeDump(bufferHandle, destinationFile).

    queryHandle:get-first().
    do while (not queryHandle:query-off-end):
      dumperImplementation:dumpRow(bufferHandle).
      queryHandle:get-next().
    end.

    dumperImplementation:finalizeDump().

    return destinationFile.

    finally:
      if valid-handle(queryHandle) then
        delete object queryHandle.

      if valid-handle(bufferHandle) then
        delete object bufferHandle.     
    end.

  end method.  // DumpData

  method public logical DumpDatabase(databaseName as char, tables as char, destinationFolder as char):

    var handle bufferHandle, queryHandle.
    var char tableName, queryString.

    // Normalize tables to comma separated string
    tables = replace(tables, chr(13), "").  // remove carriage return characters
    tables = replace(tables, chr(10), ",").  // LF 

    create buffer bufferHandle for table databaseName + "._file".
    create query queryHandle.

    // if dumping all tables, exclude hidden ones
    queryString = "for each " + databaseName + "._file".
    if tables = ? or tables = "" or tables = "all" then
      queryString += " where _hidden = false".
      
    queryHandle:set-buffers(bufferHandle).
    queryHandle:query-prepare(queryString).
    queryHandle:query-open(). 

    queryHandle:get-first().
    do while (not queryHandle:query-off-end):
      
      tableName = bufferHandle::_file-name.

      if tables = "all" or tables = "" or tables = ?
          or lookup(tableName, tables, ",") > 0 then do:
        DumpData(bufferHandle::_file-name, destinationFolder + "/" + bufferHandle::_dump-name + ".json", "").
        message bufferHandle::_file-name + ": dumped".
      end.

      queryHandle:get-next().
    end.  //  do while...

    return true.

    finally:
      if valid-handle(queryHandle) then delete object queryHandle.
      if valid-handle(bufferHandle) then delete object bufferHandle.     
    end.

  end method.  // DumpDatabase

end class.  // DataDumper 
