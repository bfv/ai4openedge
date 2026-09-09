block-level on error undo, throw.

using app.service.OrderService.
using fwebh.pas.data.IRequestData.
using fwebh.pas.data.IResponseData.
using fwebh.pas.data.RequestData.
using fwebh.pas.resource.ResourceDescriptor.
using OpenEdge.Core.Assert.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.

class sports2020.service.OrderService_UT:

  @Test.
  method public void orders_are_available_from_collection_and_resource():
    var OrderService service = new OrderService().
    var IRequestData request = new RequestData().
    var IResponseData response.

    request:Resource = new ResourceDescriptor("orders").
    response = service:GetData(request).
    Assert:Equals(true, cast(response:Data:Json, JsonArray):Length >= 0).

    request:Resource:Id = "10001".
    response = service:GetData(request).
    Assert:Equals(10001, cast(response:Data:Json, JsonObject):GetInteger("orderNum")).
  end method.  // orders_are_available_from_collection_and_resource

  @Test.
  method public void empty_json_post_is_accepted():
    var IRequestData request = new RequestData().
    var IResponseData response.

    request:Resource = new ResourceDescriptor("orders").
    request:Data:Json = new JsonObject().
    response = new OrderService():PostData(request).

    Assert:Equals("accepted", cast(response:Data:Json, JsonObject):GetCharacter("status")).
  end method.  // empty_json_post_is_accepted

  @Test(expected="fwebh.lang.error.BadRequestException").
  method public void post_without_json_body_returns_bad_request():
    var IRequestData request = new RequestData().

    request:Resource = new ResourceDescriptor("orders").
    new OrderService():PostData(request).
  end method.  // post_without_json_body_returns_bad_request

  @Test(expected="fwebh.lang.error.BadRequestException").
  method public void invalid_order_id_returns_bad_request():
    var IRequestData request = new RequestData().

    request:Resource = new ResourceDescriptor("orders").
    request:Resource:Id = "invalid".
    new OrderService():GetData(request).
  end method.  // invalid_order_id_returns_bad_request

end class.  // OrderService_UT