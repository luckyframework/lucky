# Format enum for handling different content types and file extensions
enum Lucky::Format
  Html
  Json
  Xml
  Csv
  Js
  PlainText
  Yaml
  Rss
  Atom
  Ics
  Css
  Ajax
  MultipartForm
  UrlEncodedForm

  # Convert format to file extension
  def to_extension : String
    case self
    in .html?             then "html"
    in .json?             then "json"
    in .xml?              then "xml"
    in .csv?              then "csv"
    in .js?               then "js"
    in .plain_text?       then "txt"
    in .yaml?             then "yaml"
    in .rss?              then "rss"
    in .atom?             then "atom"
    in .ics?              then "ics"
    in .css?              then "css"
    in .ajax?             then "" # Ajax doesn't have a file extension
    in .multipart_form?   then "" # Form data doesn't have a file extension
    in .url_encoded_form? then "" # Form data doesn't have a file extension
    end
  end

  # Convert format to MIME type
  def to_mime_type : String
    case self
    in .html?             then "text/html"
    in .json?             then "application/json"
    in .xml?              then "application/xml"
    in .csv?              then "text/csv"
    in .js?               then "text/javascript"
    in .plain_text?       then "text/plain"
    in .yaml?             then "application/x-yaml"
    in .rss?              then "application/rss+xml"
    in .atom?             then "application/atom+xml"
    in .ics?              then "text/calendar"
    in .css?              then "text/css"
    in .ajax?             then "text/plain"
    in .multipart_form?   then "multipart/form-data"
    in .url_encoded_form? then "application/x-www-form-urlencoded"
    end
  end

  # Parse format from file extension
  # ameba:disable Metrics/CyclomaticComplexity
  def self.from_extension(extension : String) : Format?
    case extension.downcase
    when "html", "htm" then Html
    when "json"        then Json
    when "xml"         then Xml
    when "csv"         then Csv
    when "js"          then Js
    when "txt"         then PlainText
    when "yaml", "yml" then Yaml
    when "rss"         then Rss
    when "atom"        then Atom
    when "ics", "ical" then Ics
    when "css"         then Css
    else                    nil
    end
  end

  # Parse format from MIME type
  # ameba:disable Metrics/CyclomaticComplexity
  def self.from_mime_type(mime_type : String) : Format?
    case mime_type.downcase
    when "text/html"                         then Html
    when "application/json", "text/json"     then Json
    when "application/xml"                   then Xml
    when "text/csv"                          then Csv
    when "text/javascript"                   then Js
    when "text/plain"                        then PlainText
    when "application/x-yaml", "text/yaml"   then Yaml
    when "application/rss+xml"               then Rss
    when "application/atom+xml"              then Atom
    when "text/calendar"                     then Ics
    when "text/css"                          then Css
    when "multipart/form-data"               then MultipartForm
    when "application/x-www-form-urlencoded" then UrlEncodedForm
    else                                          nil
    end
  end
end
