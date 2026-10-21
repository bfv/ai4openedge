block-level on error undo, throw.

using fwebh.pas.data.IRequestData.
using fwebh.pas.data.IResponseData.
using fwebh.pas.data.RequestData.
using fwebh.pas.resource.ResourceDescriptor.
using OpenEdge.Core.Assert.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.
using sports2020.service.SalesRepService.

class sports2020.service.SalesRepService_UT:

  @Test.
  method public void sales_reps_are_available_from_collection_and_resource():
    var SalesRepService service = new SalesRepService().
    var IRequestData request = new RequestData().
    var IResponseData response.

    request:Resource = new ResourceDescriptor("salesrep").
    response = service:GetData(request).
    Assert:True(cast(response:Data:Json, JsonArray):Length > 0).

    request:Resource:Id = "BBB".
    response = service:GetData(request).
    Assert:Equals("BBB", cast(response:Data:Json, JsonObject):GetCharacter("salesRep")).
  end method.  // sales_reps_are_available_from_collection_and_resource

  @Test(expected="fwebh.lang.error.NotFoundException").
  method public void unknown_sales_rep_resource_returns_not_found():
    var IRequestData request = new RequestData().

    request:Resource = new ResourceDescriptor("salesrep").
    request:Resource:Id = "NONE".
    new SalesRepService():GetData(request).
  end method.  // unknown_sales_rep_resource_returns_not_found

end class.  // SalesRepService_UT