block-level on error undo, throw.

using fwebh.lang.error.NotFoundException.
using fwebh.pas.data.IRequestData.
using fwebh.pas.data.IResponseData.
using fwebh.pas.data.ResponseData.
using fwebh.pas.service.IGetDataService.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.

@unittest.
class sports2020.service.SalesRepService implements IGetDataService:

  define private buffer b-salesRep for SalesRep.

  method public IResponseData GetData(request as IRequestData):
    var IResponseData response = new ResponseData().
    var JsonArray salesReps = new JsonArray().

    if request:Resource:Id = ? then do:
      for each b-salesRep no-lock by b-salesRep.SalesRep:
        salesReps:Add(SalesRepToJson()).
      end.

      response:Data:Json = salesReps.
      return response.
    end.

    find b-salesRep where b-salesRep.SalesRep = request:Resource:Id no-lock no-error.
    if not available b-salesRep then
      undo, throw new NotFoundException("Sales representative not found").

    response:Data:Json = SalesRepToJson().
    return response.
  end method.  // GetData

  method private JsonObject SalesRepToJson():
    var JsonObject salesRepJson = new JsonObject().

    salesRepJson:Add("salesRep", b-salesRep.SalesRep).
    salesRepJson:Add("repName", b-salesRep.RepName).
    salesRepJson:Add("region", b-salesRep.Region).

    return salesRepJson.
  end method.  // SalesRepToJson

end class.  // SalesRepService