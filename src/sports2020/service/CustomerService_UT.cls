block-level on error undo, throw.

using fwebh.pas.data.IRequestData.
using fwebh.pas.data.IResponseData.
using fwebh.pas.data.RequestData.
using fwebh.pas.resource.ResourceDescriptor.
using OpenEdge.Core.Assert.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.
using sports2020.service.CustomerService.

class sports2020.service.CustomerService_UT:

  @Test.
  method public void posted_customer_is_available_from_collection_and_resource():
    var integer custNum = 9999.
    var CustomerService service = new CustomerService().
    var IRequestData request = new RequestData().
    var IResponseData response.
    var JsonObject customerJson = new JsonObject().

    do transaction on error undo, throw:
      customerJson:Add("custNum", custNum).
      customerJson:Add("name", "Unit Test Customer").
      request:Resource = new ResourceDescriptor("customers").
      request:Data:Json = customerJson.

      response = service:PostData(request).
      Assert:Equals(custNum, cast(response:Data:Json, JsonObject):GetInteger("custNum")).

      request:Resource:Id = string(custNum).
      response = service:GetData(request).
      Assert:Equals(custNum, cast(response:Data:Json, JsonObject):GetInteger("custNum")).

    //   request:Resource:Id = ?.
    //   response = service:GetData(request).
    //   Assert:True(cast(response:Data:Json, JsonArray):Length > 0).

      undo, leave.
    end.
  end method.  // posted_customer_is_available_from_collection_and_resource

  @Test(expected="fwebh.lang.error.BadRequestException").
  method public void post_without_json_body_returns_bad_request():
    var IRequestData request = new RequestData().

    request:Resource = new ResourceDescriptor("customers").
    new CustomerService():PostData(request).
  end method.  // post_without_json_body_returns_bad_request

  @Test(expected="fwebh.lang.error.NotFoundException").
  method public void unknown_customer_resource_returns_not_found():
    var IRequestData request = new RequestData().

    request:Resource = new ResourceDescriptor("customers").
    request:Resource:Id = "999999999".
    new CustomerService():GetData(request).
  end method.  // unknown_customer_resource_returns_not_found

end class.  // CustomerService_UT