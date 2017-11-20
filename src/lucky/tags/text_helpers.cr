module Lucky::TextHelpers
  @@_cycles = Hash(String, Cycle).new

  def truncate(text, length = 30, omission = "...", separator = nil, escape = false, blk : Nil | Proc = nil)
    if text
      content = truncate_text(text, length, omission, separator)
      content = escape ? HTML.escape(content) : content
      content += blk.call.to_s if blk.is_a?(Proc) && text.size > length
      content
    end
  end

  def truncate(text, length = 30, omission = "...", separator = nil, escape = true, &block : -> _)
    truncate(text, length, omission, separator, escape, blk: block)
  end

  # This could go in a String extension
  private def truncate_text(text, truncate_at, omission = "...", separator = nil)
    return text unless text.size > truncate_at

    length_with_room_for_omission = truncate_at - omission.size
    stop = \
      if separator
        text.rindex(separator, length_with_room_for_omission) || length_with_room_for_omission
      else
        length_with_room_for_omission
      end

    "#{text[0, stop]}#{omission}"
  end

  def highlight(text, phrases : Nil | String | Regex | Array(String | Regex), highlighter : Proc | String = "<mark>\\1</mark>")
    if text.to_s.blank? || phrases.to_s.blank?
      text.nil? ? "" : text
    else
      unless phrases.is_a?(Array)
        phrase = phrases
        phrases = Array(String | Regex | Nil).new
        phrases << phrase
      end

      match = phrases.map do |p|
        p.is_a?(Regex) ? p.to_s : Regex.escape(p.to_s)
      end.join("|")

      if highlighter.is_a?(Proc)
        text.gsub(/(#{match})(?![^<]*?>)/i, &highlighter)
      else
        text.to_s.gsub(/(#{match})(?![^<]*?>)/i, highlighter)
      end
    end
  end

  def highlight(text, phrases : Nil | String | Regex | Array(String | Regex), &block : String -> _)
    highlight(text, phrases, highlighter: block)
  end

  def excerpt(text, phrase : Nil | Regex | String, separator = "", radius = 100, omission = "...")
    return "" if text.to_s.blank?

    separator = "" if separator.nil?

    case phrase
    when Nil
      return ""
    when Regex
      regex = phrase
    else
      regex = /#{Regex.escape(phrase.to_s)}/i
    end

    return unless matches = text.match(regex)
    phrase = matches[0]

    unless separator.empty?
      text.split(separator).each do |value|
        if value.match(regex)
          phrase = value
          break
        end
      end
    end

    first_part, second_part = text.split(phrase, 2)

    prefix, first_part   = cut_excerpt_part(:first, first_part, separator, radius, omission)
    postfix, second_part = cut_excerpt_part(:second, second_part, separator, radius, omission)

    affix = [first_part, separator, phrase, separator, second_part].join.strip
    [prefix, affix, postfix].join
  end

  def pluralize(count, singular, plural_arg = nil, plural = plural_arg)
    word = if (count == 1 || count =~ /^1(\.0+)?$/)
      singular
    else
      plural || LuckyInflector::Inflector.pluralize(singular)
    end

    "#{count || 0} #{word}"
  end

  def word_wrap(text, line_width = 80, break_sequence = "\n")
    text = text.split("\n").map do |line|
      line.size > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1#{break_sequence}").strip : line
    end
    text.join(break_sequence)
  end

  def cycle(*values, name = "default")
    string_values = Array(String).new
    values.each{ |v| string_values << v.to_s }
    values = string_values

    cycle = get_cycle(name)
    unless cycle && cycle.values == values
      cycle = set_cycle(name, Cycle.new(values))
    end
    cycle.to_s
  end

  def cycle(values : Array, name = "default")
    string_values = Array(String).new
    values.each{ |v| string_values << v.to_s }
    values = string_values

    cycle = get_cycle(name)
    unless cycle && cycle.values == values
      cycle = set_cycle(name, Cycle.new(values))
    end
    cycle.to_s
  end

  def current_cycle(name = "default")
    cycle = get_cycle(name)
    cycle.current_value if cycle
  end

  def reset_cycle(name = "default")
    cycle = get_cycle(name)
    cycle.reset if cycle
  end

  class Cycle #:nodoc:
    @values : Array(String)
    getter :values
    @index = 0

    def initialize(*values)
      string_values = Array(String).new
      values.each{ |v| string_values << v.to_s }
      @values = string_values
      reset
    end
    
    def initialize(values : Array(String))
      @values = Array(String).new
      @values = values
      reset
    end

    def reset
      @index = 0
    end

    def current_value
      @values[previous_index]?.to_s
    end

    def to_s
      value = @values[@index]?.to_s
      @index = next_index
      value
    end

    private def next_index
      step_index(1)
    end

    private def previous_index
      step_index(-1)
    end

    private def step_index(n)
      (@index + n) % @values.size
    end
  end

  def reset_cycles
    @@_cycles = Hash(String, Cycle).new
  end

  private def get_cycle(name : String)
    @@_cycles[name]?
  end

  private def set_cycle(name : String, cycle_object : Cycle)
    @@_cycles[name] = cycle_object
  end

  private def split_paragraphs(text)
    return Array(String) if text.blank?

    text.to_str.gsub(/\r\n?/, "\n").split(/\n\n+/).map! do |t|
      t.gsub!(/([^\n]\n)(?=[^\n])/, "\\1<br />") || t
    end
  end

  private def cut_excerpt_part(part_position, part, separator, radius, omission)
    return "", "" if part.nil?

    part = part.split(separator)
    part.delete("")
    affix = part.size > radius ? omission : ""

    part = if part_position == :first
      drop_index = [part.size - radius, 0].max
      part[drop_index..-1]
    else
      part.first(radius)
    end

    return affix, part.join(separator)
  end
end