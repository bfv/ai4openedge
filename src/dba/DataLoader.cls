
 /*------------------------------------------------------------------------
    File        : DataLoader
    Purpose     : 
    Syntax      : 
    Author(s)   : bronco
    Created     : Tue Sep 22 17:43:53 +02:00 2026
    Notes       : 
  ----------------------------------------------------------------------*/

using dba.IDataLoader.

block-level on error undo, throw.


class dba.DataLoader:

  var IDataLoader loaderImplementation.

/*------------------------------------------------------------------------------
	Purpose: 
	Notes:   
 ------------------------------------------------------------------------------*/  
  constructor public DataLoader():
  end constructor.

/*------------------------------------------------------------------------------
	Purpose: 
	Notes:   
	@param parameter1 Description
	@return 
 ------------------------------------------------------------------------------*/
  constructor public DataLoader(implementation as IDataLoader):
    SetLoaderImplementation(implementation).
  end constructor.

/*------------------------------------------------------------------------------
	Purpose: 
	Notes:   
	@param parameter1 Description
	@return 
 ------------------------------------------------------------------------------*/ 
  method public void SetLoaderImplementation(implementation as IDataLoader):
    loaderImplementation = implementation.
  end method.  // SetLoaderImplementation
  
  /*------------------------------------------------------------------------------
	Purpose: 
	Notes:   
	@param tableName tableName of the target table
	@param sourceFilename sourceFilename containing full filename of the data to load
	@return 
  ------------------------------------------------------------------------------*/
  method public logical LoadData(tableName as char, sourceFilename as char):
    
    var handle bufferHandle, ttBufferHandle.
    var logical bufferAvailable = true, loadOk = true.
    var int recordNumber.
    var char errorString.

    create buffer bufferHandle for table tableName.
    
    initializeTable(bufferHandle).
    loaderImplementation:InitializeLoad(bufferHandle, sourceFilename).

    // the assumption that the amount of records is rather small
    // so 1 transaction for all the records
    do transaction on error undo, throw:

      do while bufferAvailable:
        ttBufferHandle = loaderImplementation:GetNextRow().
        bufferAvailable = valid-handle(ttBufferHandle).
        if bufferAvailable then do:
          loadIntoDatabase(ttBufferHandle, bufferHandle).
          recordNumber += 1.
        end.
      end.

      catch e as Progress.Lang.Error:
        // to prevent timing issues with devcontainers, we first make the complete string before outputting it
        errorString = substitute("Error occurred after &1 records: &2", recordNumber + 1, e:GetMessage(1)).  
        message errorString.
        loadOk = false.
      end.

    end.  // transaction

    loaderImplementation:FinalizeLoad().
    finalizeTable(bufferHandle).
    
    return loadOk.

    finally:
      if valid-handle(bufferHandle) then
        delete object bufferHandle.
    end.

  end method.  // LoadData

  method private void initializeTable(bufferHandle as handle):
    bufferHandle:disable-load-triggers(false).
  end method.  // initializeTable
  
  method private void loadIntoDatabase(sourceBuffer as handle, tableBuffer as handle):
    tableBuffer:buffer-create().
    tableBuffer:buffer-copy(sourceBuffer).
    tableBuffer:buffer-release().
  end method.  // loadIntoDatabase
  
  method private void finalizeTable(bufferHandle as handle):
    /* Finalize the table buffer as needed */    
  end method.  // finalizeTable
  
  /*------------------------------------------------------------------------------
	Purpose: Load 1 or more tables into the database
	Notes:   if tables is "all" or empty, all tables will be loaded for which _Hidden = false
	@param databaseName name of the target database
	@param tables comma separated list of tables to load (or "all" for all tables)
	@param sourceFolder folder containing the JSON files to load
	@return 
  ------------------------------------------------------------------------------*/
  method public logical LoadDatabase(databaseName as char, tables as char, sourceFolder as char):
    
    var handle bufferHandle, queryHandle.
    var char tableName.

    // Normalize tables to comma separated string
    tables = replace(tables, chr(13), "").  // remove carriage return characters
    tables = replace(tables, chr(10), ",").  // LF 

    create buffer bufferHandle for table databaseName + "._file".
    create query queryHandle.

    queryHandle:set-buffers(bufferHandle).
    queryHandle:query-prepare("for each " + databaseName + "._file").
    queryHandle:query-open(). 

    queryHandle:get-first().
    do while (not queryHandle:query-off-end):
      
      tableName = bufferHandle::_file-name.

      if tables = "all" or tables = "" or tables = ?
          or lookup(tableName, tables, ",") > 0 then do:
            LoadData(bufferHandle::_file-name, sourceFolder + "/" + bufferHandle::_dump-name + ".json").
        message bufferHandle::_file-name + ": loaded".
      end.

      queryHandle:get-next().
    end.  //  do while...

    return true.

    finally:
      if valid-handle(queryHandle) then delete object queryHandle.
      if valid-handle(bufferHandle) then delete object bufferHandle.     
    end.

  end method.  // LoadDatabase

end class.  // DataLoader
