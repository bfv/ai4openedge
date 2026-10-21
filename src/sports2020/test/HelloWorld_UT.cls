block-level on error undo, throw.

using OpenEdge.Core.Assert.
using sports2020.test.HelloWorld.

class sports2020.test.HelloWorld_UT:

  @Test.
  method public void greeting_includes_supplied_name():
    var HelloWorld helloWorld = new HelloWorld().
    Assert:Equals("Hello, Ada", helloWorld:Hello("Ada")).
  end method.  // greeting_includes_supplied_name

end class.  // HelloWorld_UT
