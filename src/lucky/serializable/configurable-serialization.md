# Configurable Serialization in Lucky

Lucky now supports multiple serialization formats beyond JSON, including YAML, MsgPack, and CSV. This document explains the new serialization API and how to use it effectively.

## Overview

The new serialization system provides three ways to handle different formats:

1. **Explicit format methods** - Direct calls like `yaml()`, `msgpack()`, `csv()`
2. **Serializable format modules** - Include format-specific modules in your serializers
3. **Content negotiation** - Automatic format selection based on HTTP Accept headers

## Basic Usage

### Direct Format Methods

Just like the existing `json()` method, you can now use `yaml()`, `msgpack()`, and `csv()` directly in your actions:

```crystal
class UsersController < ApiAction
  get "/users" do
    users = UserQuery.new
    
    # Render as JSON (existing functionality)
    json users
    
    # Render as YAML
    yaml users
    
    # Render as MsgPack
    msgpack users
    
    # Render as CSV
    csv users
  end
end
```

All format methods support status codes:

```crystal
class UsersController < ApiAction
  post "/users" do
    user = SaveUser.create!(user_params)
    
    # With integer status
    yaml user, status: 201
    
    # With HTTP::Status enum
    msgpack user, status: HTTP::Status::CREATED
    
    # With symbol
    csv user, status: :created
  end
end
```

### Content Negotiation with `respond_with`

Use `respond_with` to automatically select the format based on the client's `Accept` header:

```crystal
class UsersController < ApiAction
  get "/users" do
    users = UserQuery.new
    respond_with users
  end
end
```

This will respond with:
- **JSON** if `Accept: application/json` or no Accept header (default)
- **YAML** if `Accept: application/yaml`
- **MsgPack** if `Accept: application/msgpack`
- **CSV** if `Accept: text/csv`

### Route-Level Format Selection

You can also use file extensions in your routes for explicit format selection:

```crystal
class UsersController < ApiAction
  get "/users.json" do
    json UserQuery.new
  end
  
  get "/users.yaml" do
    yaml UserQuery.new
  end
  
  get "/users.msgpack" do
    msgpack UserQuery.new
  end
  
  get "/users.csv" do
    csv UserQuery.new
  end
  
  # Content negotiation endpoint
  get "/users" do
    respond_with UserQuery.new
  end
end
```

## Advanced Usage with Serializable Modules

For custom serializers, you can include format-specific modules to get response methods:

```crystal
class UserSerializer
  include Lucky::Serializable
  include Lucky::Serializable::JSON
  include Lucky::Serializable::YAML
  include Lucky::Serializable::MsgPack
  include Lucky::Serializable::CSV
  
  def initialize(@user : User)
  end
  
  def render
    {
      id: @user.id,
      name: @user.name,
      email: @user.email,
      created_at: @user.created_at
    }
  end
end
```

Now you can use the serializer directly in actions:

```crystal
class UsersController < ApiAction
  get "/users/:id" do
    user = UserQuery.find(id)
    serializer = UserSerializer.new(user)
    
    # Return different formats directly from the serializer
    serializer.to_json_response
    # or
    serializer.to_yaml_response(status: 200)
    # or
    serializer.to_msgpack_response(status: HTTP::Status::OK)
    # or
    serializer.to_csv_response(status: 201)
  end
end
```

## Content Types

The system automatically sets the correct content types:

- **JSON**: `application/json`
- **YAML**: `application/yaml`
- **MsgPack**: `application/msgpack`
- **CSV**: `text/csv`

You can override content types if needed:

```crystal
class UsersController < ApiAction
  get "/users" do
    users = UserQuery.new
    csv users, content_type: "text/plain"  # Override CSV content type
  end
end
```

## Error Handling

All format methods handle serialization errors gracefully. If a format-specific serialization method (like `.to_yaml`, `.to_msgpack`, or `.to_csv`) is not available on an object, you'll get a clear compile-time error.

## Migration from JSON-only

This change is fully backwards compatible. Existing `json()` calls continue to work exactly as before. To add multi-format support to existing APIs:

1. **Keep existing JSON endpoints** for backwards compatibility
2. **Add new format-specific routes** for explicit format support
3. **Use `respond_with`** for new endpoints that should support content negotiation

### Example Migration

**Before:**
```crystal
class ApiController < Lucky::Action
  get "/api/users" do
    json UserQuery.new
  end
end
```

**After (with backwards compatibility):**
```crystal
class ApiController < Lucky::Action
  # Existing endpoint - unchanged
  get "/api/users" do
    json UserQuery.new
  end
  
  # New multi-format endpoint
  get "/api/v2/users" do
    respond_with UserQuery.new
  end
  
  # Or explicit format endpoints
  get "/api/users.yaml" do
    yaml UserQuery.new
  end
  
  get "/api/users.msgpack" do
    msgpack UserQuery.new
  end
  
  get "/api/users.csv" do
    csv UserQuery.new
  end
end
```

## Performance Notes

- **JSON serialization** remains the fastest and most lightweight option
- **YAML serialization** is human-readable but larger and slower than JSON
- **MsgPack serialization** is binary, compact, and faster than JSON for large datasets
- **CSV serialization** is ideal for tabular data and spreadsheet applications

Choose the format that best fits your use case:
- **JSON** for web APIs and JavaScript clients
- **YAML** for configuration files or human-readable APIs
- **MsgPack** for high-performance APIs or microservice communication
- **CSV** for data exports, reports, and spreadsheet-compatible formats

## Requirements

To use the different serialization formats, ensure your objects support the respective serialization methods:

- For YAML: Objects must respond to `.to_yaml`
- For MsgPack: Objects must respond to `.to_msgpack`
- For CSV: Objects must respond to `.to_csv`

Crystal's standard library provides these methods for most built-in types. For custom types, you may need to implement serialization manually or use libraries like `yaml`, `msgpack`, or `csv`.

### CSV Serialization Notes

CSV serialization works best with:
- Arrays of objects with consistent fields
- Hash collections
- Tabular data structures

For arrays of objects, Lucky will automatically generate CSV headers from the first object's keys and create rows for each subsequent object.

## Creating Custom Serialization Formats

Lucky provides a macro for easily defining new serialization formats. This makes it simple to add support for any format your application needs.

### Using the `define_format` Macro

```crystal
# Add this to your application (e.g., in config/serialization.cr)
Lucky::Serializable.define_format(
  name: "XML",
  method: "to_xml", 
  content_type: "application/xml"
)
```

This creates a `Lucky::Serializable::XML` module that you can include in your serializers:

```crystal
class UserSerializer
  include Lucky::Serializable
  include Lucky::Serializable::XML
  
  def initialize(@user : User)
  end
  
  def render
    # Your data structure that responds to .to_xml
    {
      id: @user.id,
      name: @user.name,
      email: @user.email
    }
  end
end

# Usage in actions
user_serializer = UserSerializer.new(user)
user_serializer.to_xml_response(status: 200)
```

### Adding Renderable Support

To add the new format to Lucky's `Renderable` module (for direct use in actions), you'll need to add methods manually:

```crystal
# Add to your application's Lucky::Renderable extension
module Lucky::Renderable
  def xml_content_type : String
    "application/xml"
  end

  def xml(body : String, status : Int32? = nil, content_type : String = xml_content_type) : Lucky::TextResponse
    send_text_response(body, content_type, status)
  end

  def xml(body, status : Int32? = nil, content_type : String = xml_content_type) : Lucky::TextResponse
    if body.responds_to?(:to_xml)
      xml(body.to_xml, status, content_type)
    else
      xml(body.to_json, status, content_type)  # Fallback
    end
  end

  def xml(body, status : HTTP::Status, content_type : String = xml_content_type) : Lucky::TextResponse
    xml(body, status: status.value, content_type: content_type)
  end
end
```

### Updating Content Negotiation

To include your custom format in `respond_with`, add it to the case statement:

```crystal
# Extend the respond_with method
module Lucky::Renderable
  def respond_with(data, status : Int32 = 200) : Lucky::Response
    accept_header = request.headers["Accept"]?
    
    case accept_header
    when .try(&.includes?("application/xml"))
      xml(data, status)
    when .try(&.includes?("text/csv"))
      csv(data, status)
    when .try(&.includes?("text/yaml")), .try(&.includes?("application/x-yaml"))
      yaml(data, status)
    when .try(&.includes?("application/msgpack"))
      msgpack(data, status)
    when .try(&.includes?("application/json")), nil
      json(data, status)
    else
      json(data, status)
    end
  end
end
```

### Example: Protocol Buffers Support

```crystal
# 1. Define the format
Lucky::Serializable.define_format(
  name: "Protobuf",
  method: "to_protobuf",
  content_type: "application/x-protobuf"
)

# 2. Use in serializers
class UserSerializer
  include Lucky::Serializable
  include Lucky::Serializable::Protobuf
  
  def render
    # Return an object that has .to_protobuf method
    UserProto.new(@user)
  end
end

# 3. Register MIME type if needed
Lucky::MimeType.register "application/x-protobuf", :protobuf

# 4. Add to accepted formats in actions
class ApiAction < Lucky::Action
  accepted_formats [:json, :protobuf], default: :json
end
```

This macro-based approach eliminates code duplication and makes it trivial for developers to add new serialization formats to their Lucky applications.