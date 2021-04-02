# Set up defaults arguments for HTML tags.
#
# This is automatically included in Pages and Components.
module Lucky::TagDefaults
  # This is typically used in components and helper methods to set up defaults for
  # reusable components.
  #
  # Example in a page or component:
  #
  #    tag_defaults field: form.email, class: "input" do |tag_builder|
  #      tag_builder.email_input placeholder: "Email"
  #    end
  #
  # Is the same as:
  #
  #     email_input field: form.email, class: "input", placeholder: "Email"
  def tag_defaults(**named_args)
    OptionMerger.new(page_context: self, named_args: named_args).run do |tag_builder|
      yield tag_builder
    end
  end

  class OptionMerger(T, V)
    def initialize(@page_context : T, @named_args : V)
    end

    def run
      yield self
    end

    macro method_missing(call)
      overridden_html_class = nil

      {% named_args = call.named_args %}
      {% if named_args %}
        {% if call.named_args.any? { |arg| arg.name == :class } %}
          {% raise <<-ERROR


          Use 'replace_class' or 'append_class' instead of 'class'.

          Correct example:

              tag_defaults class: "default" do |tag_builder|
                # Use 'replace_class' or 'append_class' here
                tag_builder.div replace_class: "replaced"
              end

          Incorrect example:

              tag_defaults class: "default" do |tag_builder|
                # Won't work with 'class'
                tag_builder.div class: "replaced"
              end

          -----------------

          ERROR
          %}
        {% end %}

        {% appended_class_arg = call.named_args.find { |arg| arg.name == :append_class } %}
        {% if appended_class_arg %}
          original_class = if klass = @named_args[:class]?
            # Append an empty space if there is a default class that
            # we are appending to
            "#{klass} "
          else
            # Otherwise leave it empty
            ""
          end

          overridden_html_class = "#{original_class}#{{{ appended_class_arg.value }}}"
        {% end %}
        {% named_args = named_args.reject { |arg| arg.name == :append_class } %}

        {% replace_class_arg = call.named_args.find { |arg| arg.name == :replace_class } %}
        {% if replace_class_arg %}
          overridden_html_class = "#{{{ replace_class_arg.value }}}"
        {% end %}
        {% named_args = named_args.reject { |arg| arg.name == :replace_class } %}
      {% end %}

      nargs = @named_args{% if named_args %}.merge({{ named_args.splat }})

      # If there is no default class and we want to append/replace one, then
      # the compiler blows up because the @named_args type is a Union. Where
      # one type has the 'class' key and the other doesn't.
      #
      # We fix that by making sure there is always a class key if we try to
      # append/replace a class.
      {% if appended_class_arg || replace_class_arg %}
        nargs = nargs.merge(class: "")
      {% end %}

      if overridden_html_class
        nargs = nargs.merge(class: overridden_html_class)
      end
      {% end %}

      args = Tuple.new({% if call.args %}
        {% for arg in call.args %}
          {{ arg }},
        {% end %}
      {% end %})

      @page_context.{{ call.name }} *args, **nargs  {{ call.block }}
    end
  end
end
