
 /*------------------------------------------------------------------------
    File        : IDataLoader
    Purpose     : 
    Syntax      : 
    Author(s)   : bronco
    Created     : Tue Sep 22 17:44:39 +02:00 2026
    Notes       : 
  ----------------------------------------------------------------------*/

interface dba.IDataLoader:

  method public void InitializeLoad(bufferHandle as handle, sourceFile as char).
  method public handle GetNextRow().
  method public void FinalizeLoad().

end interface.
