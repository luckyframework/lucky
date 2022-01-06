# These helper methods will write directly to the view.
module Lucky::HTMLTextHelpers
  # Shortens text after a length point and inserts content afterward
  #
  # **Note: This method writes HTML directly to the page. It does not return a
  # String.**
  #
  # This is ideal if you want an action associated with shortened text, like
  # "Read more".
  #
  # * `length` (default: `30`) will control the maximum length of the text,
  # including the `omission`.
  # * `omission` (default: `...`) will insert itself at the end of the
  # truncated text.
  # * `separator` (default: nil) is where words are cut off. This is often
  # overridden to break on word boundaries by setting the separator to a space
  # `" "`. Keep in mind this, may cause your text to be truncated before your
  # `length` value if the `length` - `omission` is before the `separator`.
  # * `escape` (default: true) weather or not to HTML escape the truncated
  # string.
  # * `blk` (default: nil) A block to run after the text has been truncated.
  # Often used to add an action to read more text, like a "Read more" link.
  #
  # ```
  # truncate("Four score and seven years ago", length: 20) do
  #   link "Read more", to: "#"
  # end
  # ```
  # outputs:
  # ```html
  # "Four score and se...<a href="#">Read more</a>"
  # ```
  def truncate(text : String, length : Int32 = 30, omission : String = "...", separator : String | Nil = nil, escape : Bool = true, blk : Nil | Proc = nil) : Nil
    content = truncate_text(text, length, omission, separator)
    raw(escape ? HTML.escape(content) : content)
    blk.call if !blk.nil? && text.size > length
  end

  def truncate(text : String, length : Int32 = 30, omission : String = "...", separator : String | Nil = nil, escape : Bool = true, &block : -> _) : Nil
    truncate(text, length, omission, separator, escape, blk: block)
  end

  # Wrap phrases to make them stand out
  #
  # This will wrap all the phrases inside a piece of `text` specified by the
  # `phrases` array. The default is to wrap each with the `<mark>` element.
  # This can be customized with the `highlighter` argument.
  #
  # **Note: This method writes HTML directly to the page. It does not return a
  # String**
  #
  # ```
  # highlight("Crystal is type-safe and compiled.", phrases: ["type-safe", "compiled"])
  # ```
  # outputs:
  # ```html
  # Crystal is <mark>type-safe</mark> and <mark>compiled</mark>.
  # ```
  #
  # **With a custom highlighter**
  #
  # ```
  # highlight(
  #   "You're such a nice and attractive person.",
  #   phrases: ["nice", "attractive"],
  #   highlighter: "<strong>\\1</strong>"
  # )
  # ```
  # outputs:
  # ```html
  # You're such a <strong>nice</strong> and <strong>attractive</strong> person.
  # ```
  def highlight(text : String, phrases : Array(String | Regex), highlighter : Proc | String = "<mark>\\1</mark>", escape : Bool = true) : Nil
    text = escape ? HTML.escape(text) : text

    if text.blank? || phrases.all?(&.to_s.blank?)
      raw(text || "")
    else
      match = phrases.map do |p|
        p.is_a?(Regex) ? p.to_s : Regex.escape(p.to_s)
      end.join("|")

      if highlighter.is_a?(Proc)
        raw text.gsub(/(#{match})(?![^<]*?>)/i, &highlighter)
      else
        raw text.gsub(/(#{match})(?![^<]*?>)/i, highlighter)
      end
    end
  end

  # Highlight a single phrase
  #
  # Exactly the same as the `highlight` that takes multiple phrases, but with a
  # singular `phrase` argument for readability.
  # ```
  def highlight(text : String, phrases : Array(String | Regex), escape : Bool = false, &block : String -> _) : Nil
    highlight(text, phrases, highlighter: block, escape: escape)
  end

  def highlight(text : String, phrase : String | Regex, highlighter : Proc | String = "<mark>\\1</mark>", escape : Bool = true) : Nil
    phrases = [phrase] of String | Regex
    highlight(text, phrases, highlighter: highlighter, escape: escape)
  end

  def highlight(text : String, phrase : String | Regex, escape : Bool = true, &block : String -> _) : Nil
    phrases = [phrase] of String | Regex
    highlight(text, phrases, highlighter: block, escape: escape)
  end

  # Wraps text in whatever you'd like based on line breaks
  #
  # **Note: This method writes HTML directly to the page. It does not return a
  # String**
  #
  # ```
  # simple_format("foo\n\nbar\n\nbaz") do |paragraph|
  #   text paragraph
  #   hr
  # end
  # ```
  # outputs:
  # ```html
  # foo<hr>
  #
  # bar<hr>
  #
  # baz<hr>
  # ```
  def simple_format(text : String, &block : String -> _) : Nil
    paragraphs = split_paragraphs(text)

    paragraphs = [""] if paragraphs.empty?

    paragraphs.each do |paragraph|
      yield paragraph
      raw "\n\n" unless paragraph == paragraphs.last
    end
    view
  end

  # Wraps text in paragraphs based on line breaks
  #
  # ```
  # simple_format("foo\n\nbar\n\nbaz")
  # ```
  # outputs:
  # ```html
  # <p>foo</p>
  #
  # <p>bar</p>
  #
  # <p>baz</p>
  # ```
  def simple_format(text : String, escape : Bool = true, **html_options) : Nil
    text = escape ? HTML.escape(text) : text

    simple_format(text) do |formatted_text|
      para(html_options) do
        raw formatted_text
      end
    end
  end
end
