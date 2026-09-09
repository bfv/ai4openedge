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

class sports2020.service.CustomerService implements IGetDataService, IPostDataService:

  define private buffer b-customer for Customer.

  method public IResponseData GetData(request as IRequestData):
    var IResponseData response = new ResponseData().
    var JsonArray customers = new JsonArray().
    var integer custNum.

    do on error undo, throw:
      if request:Resource:Id = ? then do:
        for each b-customer no-lock by b-customer.CustNum:
          customers:Add(CustomerToJson()).
        end.

        response:Data:Json = customers.
        return response.
      end.

      custNum = CustomerId(request:Resource:Id).
      find b-customer where b-customer.CustNum = custNum no-lock no-error.
      if not available b-customer then
        undo, throw new NotFoundException("Customer not found").

      response:Data:Json = CustomerToJson().
      return response.
    end.
  end method.  // GetData

  method public IResponseData PostData(request as IRequestData):
    var IResponseData response = new ResponseData().
    var JsonObject customerJson.

    do on error undo, throw:
      if request:Data:DataType <> ResponseDataType:JSON then
        undo, throw new BadRequestException("A JSON request body is required").

      customerJson = cast(request:Data:Json, JsonObject).

      if not customerJson:Has("custNum") then
        undo, throw new BadRequestException("custNum is required").

      if customerJson:GetInteger("custNum") <= 0 then
        undo, throw new BadRequestException("custNum must be greater than zero").

      find b-customer where b-customer.CustNum = customerJson:GetInteger("custNum") no-lock no-error.
      if available b-customer then
        undo, throw new BadRequestException("custNum already exists").

      do transaction on error undo, throw:
        create b-customer.
        b-customer.CustNum = customerJson:GetInteger("custNum").
        ApplyCustomerJson(customerJson).
      end.
    end.

    response:Data:Json = CustomerToJson().
    return response.
  end method.  // PostData

  method private integer CustomerId(resourceId as char):
    var int custNum.

    do on error undo, throw:

      assign custNum = integer(resourceId) no-error.
      if error-status:error or custNum <= 0 then
        undo, throw new BadRequestException("Customer id must be a positive integer").

      return custNum.

    end.

  end method.  // CustomerId

  method private void ApplyCustomerJson(customerJson as JsonObject):
    if customerJson:Has("name") then
      b-customer.Name = customerJson:GetCharacter("name").
    if customerJson:Has("address") then
      b-customer.Address = customerJson:GetCharacter("address").
    if customerJson:Has("address2") then
      b-customer.Address2 = customerJson:GetCharacter("address2").
    if customerJson:Has("city") then
      b-customer.City = customerJson:GetCharacter("city").
    if customerJson:Has("state") then
      b-customer.State = customerJson:GetCharacter("state").
    if customerJson:Has("country") then
      b-customer.Country = customerJson:GetCharacter("country").
    if customerJson:Has("phone") then
      b-customer.Phone = customerJson:GetCharacter("phone").
    if customerJson:Has("contact") then
      b-customer.Contact = customerJson:GetCharacter("contact").
    if customerJson:Has("salesRep") then
      b-customer.SalesRep = customerJson:GetCharacter("salesRep").
    if customerJson:Has("comments") then
      b-customer.Comments = customerJson:GetCharacter("comments").
    if customerJson:Has("creditLimit") then
      b-customer.CreditLimit = customerJson:GetDecimal("creditLimit").
    if customerJson:Has("balance") then
      b-customer.Balance = customerJson:GetDecimal("balance").
    if customerJson:Has("terms") then
      b-customer.Terms = customerJson:GetCharacter("terms").
    if customerJson:Has("discount") then
      b-customer.Discount = customerJson:GetInteger("discount").
    if customerJson:Has("postalCode") then
      b-customer.PostalCode = customerJson:GetCharacter("postalCode").
    if customerJson:Has("fax") then
      b-customer.Fax = customerJson:GetCharacter("fax").
    if customerJson:Has("emailAddress") then
      b-customer.EmailAddress = customerJson:GetCharacter("emailAddress").
  end method.  // ApplyCustomerJson

  method private JsonObject CustomerToJson():
    var JsonObject customerJson = new JsonObject().

    customerJson:Add("custNum", b-customer.CustNum).
    customerJson:Add("name", b-customer.Name).
    customerJson:Add("address", b-customer.Address).
    customerJson:Add("address2", b-customer.Address2).
    customerJson:Add("city", b-customer.City).
    customerJson:Add("state", b-customer.State).
    customerJson:Add("country", b-customer.Country).
    customerJson:Add("phone", b-customer.Phone).
    customerJson:Add("contact", b-customer.Contact).
    customerJson:Add("salesRep", b-customer.SalesRep).
    customerJson:Add("comments", b-customer.Comments).
    customerJson:Add("creditLimit", b-customer.CreditLimit).
    customerJson:Add("balance", b-customer.Balance).
    customerJson:Add("terms", b-customer.Terms).
    customerJson:Add("discount", b-customer.Discount).
    customerJson:Add("postalCode", b-customer.PostalCode).
    customerJson:Add("fax", b-customer.Fax).
    customerJson:Add("emailAddress", b-customer.EmailAddress).

    return customerJson.
  end method.  // CustomerToJson

end class.  // CustomerService
