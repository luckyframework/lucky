annotation Lucky::SvgInliner::Path
end
annotation Lucky::SvgInliner::StripRegex
end

@[Lucky::SvgInliner::Path("src/svgs")]
@[Lucky::SvgInliner::StripRegex(/(class|fill|stroke|stroke-width|style)="[^"]+" ?/)]
module Lucky::SvgInliner
  macro inline_svg(path, strip_styling = true, **named_args)
    {%
      svgs_path = Lucky::SvgInliner.annotation(Lucky::SvgInliner::Path).args.first
      regex = Lucky::SvgInliner.annotation(Lucky::SvgInliner::StripRegex).args.first
      full_path = "#{svgs_path.id}/#{path.id}"

      raise "SVG file #{full_path.id} is missing" unless file_exists?(full_path)

      # Strip the XML declaration, comments, and whitespace
      svg = read_file(full_path)
        .gsub(/<\?xml[^>]+>/, "")
        .gsub(/<!--[^>]+>/, "")
        .gsub(/\n\s*/, " ")
        .strip

      # Strip styling using the given regex, if required
      svg = svg.gsub(regex, "") if strip_styling
      modifier = strip_styling ? "" : "-styled"

      # Build new attributes for svg tag
      attributes = [%(data-inline-svg#{modifier.id}="#{path.id}")]
      named_args.each do |name, value|
        attributes << %(#{name.stringify.gsub(/_/, "-").id}="#{value.id}")
      end
    %}

    raw {{svg.gsub(/<svg/, %(<svg #{attributes.join(" ").id}))}}
  end
end
