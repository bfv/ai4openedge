block-level on error undo, throw.

using fwebh.pas.data.IRequestData.
using fwebh.pas.data.IResponseData.
using fwebh.pas.data.RequestData.
using fwebh.pas.resource.ResourceDescriptor.
using OpenEdge.Core.Assert.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.
using sports2020.service.OrderLineService.

class sports2020.service.OrderLineService_UT:

  @Test.
  method public void order_lines_are_available_from_collection_and_resource():
    var OrderLineService service = new OrderLineService().
    var IRequestData request = new RequestData().
    var IResponseData response.

    request:Resource = new ResourceDescriptor("orderline").
    request:Resource:ParentName = "order".
    request:Resource:ParentId = "10000".
    response = service:GetData(request).
    Assert:Equals(true, cast(response:Data:Json, JsonArray):Length > 0).

    request:Resource:Id = "1".
    response = service:GetData(request).
    Assert:Equals(10000, cast(response:Data:Json, JsonObject):GetInteger("orderNum")).
    Assert:Equals(1, cast(response:Data:Json, JsonObject):GetInteger("lineNum")).
  end method.  // order_lines_are_available_from_collection_and_resource

  @Test.
  method public void posted_order_line_is_returned():
    var OrderLineService service = new OrderLineService().
    var IRequestData request = new RequestData().
    var IResponseData response.
    var JsonObject orderLineJson = new JsonObject().

    do transaction on error undo, throw:
      request:Resource = new ResourceDescriptor("orderline").
      request:Resource:ParentName = "order".
      request:Resource:ParentId = "10000".
      orderLineJson:Add("lineNum", 999).
      orderLineJson:Add("itemNum", 54).
      orderLineJson:Add("quantity", 2).
      request:Data:Json = orderLineJson.

      response = service:PostData(request).
      Assert:Equals(10000, cast(response:Data:Json, JsonObject):GetInteger("orderNum")).
      Assert:Equals(999, cast(response:Data:Json, JsonObject):GetInteger("lineNum")).
      Assert:Equals(2, cast(response:Data:Json, JsonObject):GetInteger("quantity")).

      undo, leave.
    end.
  end method.  // posted_order_line_is_returned

  @Test(expected="fwebh.lang.error.BadRequestException").
  method public void invalid_parent_order_id_returns_bad_request():
    var IRequestData request = new RequestData().

    request:Resource = new ResourceDescriptor("orderline").
    request:Resource:ParentId = "invalid".
    new OrderLineService():GetData(request).
  end method.  // invalid_parent_order_id_returns_bad_request

  @Test(expected="fwebh.lang.error.NotFoundException").
  method public void unknown_order_line_returns_not_found():
    var IRequestData request = new RequestData().

    request:Resource = new ResourceDescriptor("orderline").
    request:Resource:ParentId = "10000".
    request:Resource:Id = "999".
    new OrderLineService():GetData(request).
  end method.  // unknown_order_line_returns_not_found

  @Test(expected="fwebh.lang.error.BadRequestException").
  method public void post_without_json_body_returns_bad_request():
    var IRequestData request = new RequestData().

    request:Resource = new ResourceDescriptor("orderline").
    request:Resource:ParentId = "10000".
    new OrderLineService():PostData(request).
  end method.  // post_without_json_body_returns_bad_request

end class.  // OrderLineService_UT