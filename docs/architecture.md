# fwebh Architecture

`fwebh` is a thin adapter that exposes ABL service classes through PAS for OpenEdge web handlers. It keeps HTTP parsing and serialization in the framework; a service implements the business operation for one or more HTTP verbs.

## Request Flow

```mermaid
flowchart LR
	HTTP[HTTP request] --> Handler[ResourceWebHandler]
	Handler --> Request[RequestDataProcessor]
	Request --> Factory[ServiceFactory]
	Factory --> Service[Verb-specific service]
	Service --> Response[ResponseData]
	Response --> Writer[EntityWriterFactory]
	Writer --> HTTPResponse[HTTP response]
```

1. `ResourceWebHandler` handles `GET`, `POST`, `PUT`, and `DELETE`.
2. `RequestDataProcessor` converts the PAS `IWebRequest` to `IRequestData`.
3. `IRequestData:Resource:Name` selects a definition from `services.json`.
4. `ServiceFactory` creates the configured class and verifies that it implements the interface for the HTTP verb.
5. The service returns `IResponseData`. Its `Data` holder selects the response representation.
6. `EntityWriterFactory` serializes the response according to the resolved content type.

The URL-to-resource mapping is provided by PAS routing and is not defined in this repository. Confirm the deployed PAS route before choosing a public resource name.

## Service Contract

Implement the interface matching each supported verb:

| HTTP verb | Interface | Method |
| --- | --- | --- |
| `GET` | `IGetDataService` | `GetData(request)` |
| `POST` | `IPostDataService` | `PostData(request)` |
| `PUT` | `IPutDataService` | `PutData(request)` |
| `DELETE` | `IDeleteDataService` | `DeleteData(request)` |

A class can implement multiple interfaces, as `EchoService` does. `IPatchDataService` and its factory method exist, but `ResourceWebHandler` does not implement `HandlePatch`; do not expose `PATCH` through this handler without extending it.

`IRequestData` provides the parsed resource descriptor, request and response content types, accepted content type, verb, version, parameters, headers, and body in `request:Data`. Inspect `request:Data:DataType` before reading the body.

Create `ResponseData` and assign exactly the appropriate `response:Data` property. Assignment sets its data type automatically:

| Response property | Typical use |
| --- | --- |
| `Json` | JSON object or array |
| `TempTableHandle`, `DatasetHandle`, `BufferHandle` | ABL data structures |
| `PlainText` | Text response |
| `Memptr` | Binary response |

An empty response (`ResponseDataType:NONE`) becomes HTTP `204`. For a non-empty response, content type precedence is: `response:ContentType`, request `Accept` (unless `*/*`), `IDefaultContentType:GetDefaultContentType()`, then `application/json`.

## Create a Service

1. Create an ABL class in an application package; do not add business logic to a framework handler or include.
2. Add `block-level on error undo, throw.` and implement the required verb interface.
3. Validate input from `request` and perform the business operation. Keep transaction ownership explicit in the service when database changes span multiple operations.
4. Return a new `ResponseData` with one response data property assigned.
5. Throw an `fwebh.lang.error` exception for expected HTTP errors; the handler maps `BadRequest`, `Unauthorized`, `Forbidden`, `NotFound`, `NotAllowed`, `NotAcceptable`, and `Concurrency` exceptions to `400`, `401`, `403`, `404`, `405`, `406`, and `409`. Other errors become `500`.
6. Register the service in `src/services.json` with a lowercase resource identifier and fully qualified class name. The configured class must be available on the PROPATH.
7. Add a colocated `ServiceName_UT.cls` test for its behavior.

Minimal `GET` service shape:

```abl
block-level on error undo, throw.

using fwebh.pas.data.IRequestData.
using fwebh.pas.data.IResponseData.
using fwebh.pas.data.ResponseData.
using fwebh.pas.service.IGetDataService.
using Progress.Json.ObjectModel.JsonObject.

class app.service.StatusService implements IGetDataService:

	method public IResponseData GetData(request as IRequestData):
		var IResponseData response = new ResponseData().
		var JsonObject body = new JsonObject().

		body:Add("status", "ok").
		response:Data:Json = body.

		return response.
	end method.  // GetData

end class.  // StatusService
```

Register it as:

```json
"status": { "classname": "app.service.StatusService" }
```

## Configuration and Lifecycle

`services.json` is loaded when `ServiceFactory` is constructed. Each property name is the resource identifier. `classname` is required. The optional `singleton` setting controls whether the shared `Factory` caches an instance; omit it unless the service is safe to reuse across requests. Do not store request-specific state in a singleton.

`Factory` can configure an `IConfigurable` instance, but `ServiceFactory` currently passes unknown configuration (`?`) when registering services. Therefore, service-specific JSON configuration is not wired through this service registry yet.

## Boundaries

- The framework does not provide authentication, authorization, request validation, database transaction policy, or caching. Implement these in application services or surrounding PAS infrastructure.
- Entity writers are configured separately in `src/entitywriter.json`; add a writer only when an existing response format cannot serve the endpoint.
- Framework examples are `EchoService` (multiple verbs and request-body handling) and `TempTableService` (temp-table output and a default content type).