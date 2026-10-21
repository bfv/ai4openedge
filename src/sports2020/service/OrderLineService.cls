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
class sports2020.service.OrderLineService implements IGetDataService, IPostDataService:

  define private buffer b-orderLine for OrderLine.

  method public IResponseData GetData(request as IRequestData):
    var IResponseData response = new ResponseData().
    var JsonArray orderLines = new JsonArray().
    var int orderNum.
    var int lineNum.

    orderNum = OrderId(request:Resource:ParentId).

    if request:Resource:Id = ? then do:
      for each b-orderLine where b-orderLine.OrderNum = orderNum no-lock by b-orderLine.LineNum:
        orderLines:Add(OrderLineToJson()).
      end.

      response:Data:Json = orderLines.
      return response.
    end.

    lineNum = LineId(request:Resource:Id).
    find b-orderLine where b-orderLine.OrderNum = orderNum
                     and b-orderLine.LineNum = lineNum no-lock no-error.
    if not available b-orderLine then
      undo, throw new NotFoundException("Order line not found").

    response:Data:Json = OrderLineToJson().
    return response.
  end method.  // GetData

  method public IResponseData PostData(request as IRequestData):
    var IResponseData response = new ResponseData().
    var JsonObject orderLineJson.
    var int orderNum.
    var int lineNum.

    if request:Data:DataType <> ResponseDataType:JSON then
      undo, throw new BadRequestException("A JSON request body is required").

    orderNum = OrderId(request:Resource:ParentId).
    orderLineJson = cast(request:Data:Json, JsonObject).
    lineNum = RequiredPositiveInteger(orderLineJson, "lineNum").

    if not orderLineJson:Has("itemNum") then
      undo, throw new BadRequestException("itemNum is required").

    if orderLineJson:GetInteger("itemNum") <= 0 then
      undo, throw new BadRequestException("itemNum must be greater than zero").

    find b-orderLine where b-orderLine.OrderNum = orderNum
                     and b-orderLine.LineNum = lineNum no-lock no-error.
    if available b-orderLine then
      undo, throw new BadRequestException("Order line already exists").

    do transaction on error undo, throw:
      create b-orderLine.
      b-orderLine.OrderNum = orderNum.
      b-orderLine.LineNum = lineNum.
      b-orderLine.ItemNum = orderLineJson:GetInteger("itemNum").
      ApplyOrderLineJson(orderLineJson).
    end.

    response:Data:Json = OrderLineToJson().
    return response.
  end method.  // PostData

  method private int OrderId(resourceId as char):
    var int orderNum.

    assign orderNum = integer(resourceId) no-error.
    if error-status:error or orderNum <= 0 then
      undo, throw new BadRequestException("Order id must be a positive integer").

    return orderNum.
  end method.  // OrderId

  method private int LineId(resourceId as char):
    var int lineNum.

    assign lineNum = integer(resourceId) no-error.
    if error-status:error or lineNum <= 0 then
      undo, throw new BadRequestException("Order line id must be a positive integer").

    return lineNum.
  end method.  // LineId

  method private int RequiredPositiveInteger(orderLineJson as JsonObject, name as char):
    var int intValue.

    if not orderLineJson:Has(name) then
      undo, throw new BadRequestException(name + " is required").

    intValue = orderLineJson:GetInteger(name).
    if intValue <= 0 then
      undo, throw new BadRequestException(name + " must be greater than zero").

    return intValue.
  end method.  // RequiredPositiveInteger

  method private void ApplyOrderLineJson(orderLineJson as JsonObject):
    if orderLineJson:Has("price") then
      b-orderLine.Price = orderLineJson:GetDecimal("price").
    if orderLineJson:Has("quantity") then
      b-orderLine.Qty = orderLineJson:GetInteger("quantity").
    if orderLineJson:Has("discount") then
      b-orderLine.Discount = orderLineJson:GetInteger("discount").
    if orderLineJson:Has("extendedPrice") then
      b-orderLine.ExtendedPrice = orderLineJson:GetDecimal("extendedPrice").
    if orderLineJson:Has("status") then
      b-orderLine.OrderLineStatus = orderLineJson:GetCharacter("status").
  end method.  // ApplyOrderLineJson

  method private JsonObject OrderLineToJson():
    var JsonObject orderLineJson = new JsonObject().

    orderLineJson:Add("orderNum", b-orderLine.OrderNum).
    orderLineJson:Add("lineNum", b-orderLine.LineNum).
    orderLineJson:Add("itemNum", b-orderLine.ItemNum).
    orderLineJson:Add("price", b-orderLine.Price).
    orderLineJson:Add("quantity", b-orderLine.Qty).
    orderLineJson:Add("discount", b-orderLine.Discount).
    orderLineJson:Add("extendedPrice", b-orderLine.ExtendedPrice).
    orderLineJson:Add("status", b-orderLine.OrderLineStatus).

    return orderLineJson.
  end method.  // OrderLineToJson

end class.  // OrderLineService