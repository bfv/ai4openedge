block-level on error undo, throw.

using fwebh.lang.error.BadRequestException.
using fwebh.lang.error.NotFoundException.
using fwebh.pas.data.IRequestData.
using fwebh.pas.data.IResponseData.
using fwebh.pas.data.ResponseData.
using fwebh.pas.data.ResponseDataType.
using fwebh.pas.service.IGetDataService.
using fwebh.pas.service.IPostDataService.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.

@unittest.
class sports2020.service.OrderService implements IGetDataService, IPostDataService:

  define private buffer b-order for Order.

  method public IResponseData GetData(request as IRequestData):
    var IResponseData response = new ResponseData().
    var JsonArray orders = new JsonArray().
    var int orderNum.

    do on error undo, throw:
      if request:Resource:Id = ? then do:
        for each b-order no-lock by b-order.OrderNum:
          orders:Add(OrderToJson()).
        end.

        response:Data:Json = orders.
        return response.
      end.

      orderNum = OrderId(request:Resource:Id).
      find b-order where b-order.OrderNum = orderNum no-lock no-error.
      if not available b-order then
        undo, throw new NotFoundException("Order not found").

      response:Data:Json = OrderToJson().
      return response.
    end.
  end method.  // GetData

  method public IResponseData PostData(request as IRequestData):
    var IResponseData response = new ResponseData().
    var JsonObject requestJson.
    var JsonObject responseJson = new JsonObject().
    var char[] names.

    do on error undo, throw:
      if request:Data:DataType <> ResponseDataType:JSON then
        undo, throw new BadRequestException("A JSON request body is required").

      requestJson = cast(request:Data:Json, JsonObject).
      names = requestJson:GetNames().
      if extent(names) <> 0 then
        undo, throw new BadRequestException("The request body must be an empty JSON object").
    end.

    responseJson:Add("status", "accepted").
    response:Data:Json = responseJson.
    return response.
  end method.  // PostData

  method private int OrderId(resourceId as char):
    var int orderNum.

    do on error undo, throw:
      assign orderNum = integer(resourceId) no-error.
      if error-status:error or orderNum <= 0 then
        undo, throw new BadRequestException("Order id must be a positive integer").

      return orderNum.
    end.
  end method.  // OrderId

  method private JsonObject OrderToJson():
    var JsonObject orderJson = new JsonObject().

    orderJson:Add("orderNum", b-order.OrderNum).
    orderJson:Add("custNum", b-order.CustNum).
    orderJson:Add("orderStatus", b-order.OrderStatus).

    return orderJson.
  end method.  // OrderToJson

end class.  // OrderService