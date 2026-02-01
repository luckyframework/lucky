# Configurable Serialization System - Changelog

## New Features

### 🎯 Multi-Format Serialization Support
- Added support for **YAML**, **MsgPack**, **CSV**, and **XML** formats alongside existing JSON
- New rendering methods: `yaml()`, `msgpack()`, `csv()`, `xml()` with full status code support
- Content negotiation via `respond_with()` method based on HTTP Accept headers

### 🔧 Macro-Based Architecture
- **`define_format` macro** for easily creating new serialization formats
- **`define_renderable_format` macro** for generating Renderable methods
- Eliminates code duplication and makes the system highly extensible

### 🏗️ Improved Code Organization
- Extracted format modules into dedicated `/src/lucky/serializable/` directory
- Clean separation between serializable and renderable concerns
- Consolidated macro definitions for maintainability

### 🛡️ Enhanced Error Handling
- Graceful fallback to JSON when serialization methods are unavailable
- Comprehensive logging for debugging serialization issues
- Runtime checks with `responds_to?` for method availability

### 🎨 Developer Experience Improvements
- **Auto MIME type registration** in `define_format` macro
- Extensive documentation with real-world examples
- Example application demonstrating all features

## API Examples

### Basic Usage
```crystal
# Direct format methods
json users
yaml users  
csv users
msgpack users

# Content negotiation
respond_with users  # Chooses format based on Accept header
```

### Custom Serializers
```crystal
class UserSerializer
  include Lucky::Serializable
  include Lucky::Serializable::JSON
  include Lucky::Serializable::YAML
  include Lucky::Serializable::CSV
  
  def render
    {id: @user.id, name: @user.name}
  end
end

# Usage
serializer.to_json_response(status: 201)
serializer.to_yaml_response
serializer.to_csv_response
```

### Adding New Formats
```crystal
# One line to add XML support
Lucky::Serializable.define_format(
  name: "XML",
  method: "to_xml", 
  content_type: "application/xml",
  mime_type: :xml
)

# Then use it
include Lucky::Serializable::XML
serializer.to_xml_response
```

## Breaking Changes
**None** - This is fully backwards compatible. All existing `json()` calls continue to work exactly as before.

## File Structure Changes
```
src/lucky/
├── serializable.cr (updated with macro require)
├── renderable.cr (enhanced with new format methods)
├── renderable_format_macro.cr (new)
└── serializable/
    └── format_macro.cr (new - contains all format definitions)
```

## Content Types Supported
- **JSON**: `application/json` (existing)
- **YAML**: `application/yaml` (new)
- **MsgPack**: `application/msgpack` (new) 
- **CSV**: `text/csv` (new)
- **XML**: `application/xml` / `text/xml` (new)

## Migration Guide

### For Existing Applications
No changes required - everything continues to work as before.

### To Add Multi-Format Support
1. **Keep existing JSON endpoints** for backwards compatibility
2. **Add explicit format routes**: `/users.yaml`, `/users.csv`
3. **Use content negotiation** for new APIs with `respond_with()`

### To Create Custom Formats
1. Use `Lucky::Serializable.define_format()` macro
2. Include the generated module in your serializers
3. Optionally extend `Lucky::Renderable` for direct action usage

## Performance Notes
- JSON remains the fastest format (no changes to existing performance)
- New formats only load when explicitly used
- Fallback mechanisms prevent runtime errors
- Macro-generated code has zero runtime overhead

## Testing
- 29 new test cases covering all format combinations
- Content negotiation testing with various Accept headers
- Error handling and fallback scenarios
- Backwards compatibility verification

This enhancement makes Lucky's serialization system one of the most flexible and developer-friendly among web frameworks while maintaining its simplicity and performance characteristics.