---
name: "Create fwebh REST Service"
description: "Use when: creating an ABL REST service, webhandler service, or services.json definition for fwebh"
argument-hint: "Resource id, HTTP verbs, ABL package/class, request and response contract"
agent: "agent"
---

Create a production-ready fwebh REST service from the supplied requirements.

Required input:
- Resource id (lowercase), for example `orders`
- HTTP verb(s): `GET`, `POST`, `PUT`, and/or `DELETE`
- ABL package and class name
- Request contract: headers, parameters, resource id, and body format as applicable
- Response contract: status behavior, body format, and content type

Follow [architecture](../../docs/architecture.md) and [coding standards](../../docs/coding-standards.md). Before editing, inspect the nearest applicable service and test implementation.

Deliver the complete feature:
1. Create the service class in the requested package. Start it with `block-level on error undo, throw.`.
2. Implement the fwebh interface for every requested verb and return `IResponseData` through `ResponseData`.
3. Validate input explicitly. Throw the appropriate `fwebh.lang.error.*Exception` for expected HTTP failures; do not return an error payload with a successful status.
4. Set one `response:Data` property appropriate to the requested response: `Json`, `TempTableHandle`, `DatasetHandle`, `BufferHandle`, `PlainText`, or `Memptr`. Set `ContentType` only when the default negotiation is unsuitable.
5. Add or update the service registration in `src/services.json` using the resource id and fully qualified class name. Add `"singleton": true` only when the service has no request-specific or mutable state.
6. Add or update a colocated `<ClassName>_UT.cls` test using the repository's test conventions. Cover the success path and each validation or domain error introduced by the service.
7. Compile changed ABL files and run the focused tests or existing equivalent validation.

Constraints:
- `ResourceWebHandler` supports only `GET`, `POST`, `PUT`, and `DELETE`. For `PATCH`, explain that handler support must be added before implementing the service.
- `services.json` maps a resource id to a service class; it does not configure the public URL. Inspect and change PAS routing only if its configuration exists in the workspace.
- Do not modify framework handlers, entity writers, or shared factory code unless the requirement cannot be implemented through a service interface and registration. State the reason before such a change.

At completion, report the created class, changed `services.json` entry, test coverage, validation run, and any PAS route that must be configured outside this repository.
