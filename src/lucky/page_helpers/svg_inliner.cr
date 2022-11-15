annotation Lucky::SvgInliner::Path
end
annotation Lucky::SvgInliner::StripRegex
end

@[Lucky::SvgInliner::Path("src/svgs")]
@[Lucky::SvgInliner::StripRegex(/(class|fill|stroke|stroke-width|style)="[^"]+" ?/)]
module Lucky::SvgInliner
  macro inline_svg(path, strip_styling = true)
    {%
      svgs_path = Lucky::SvgInliner.annotation(Lucky::SvgInliner::Path).args.first
      regex = Lucky::SvgInliner.annotation(Lucky::SvgInliner::StripRegex).args.first
      full_path = "#{svgs_path.id}/#{path.id}"

      raise "SVG file #{full_path.id} is missing" unless file_exists?(full_path)

      svg = read_file(full_path)
        .gsub(/<\?xml[^>]+>/, "")
        .gsub(/<!--[^>]+>/, "")
        .gsub(/\n\s*/, "")
      svg = svg.gsub(regex, "") if strip_styling
    %}

    raw {{svg.gsub(/<svg/, %(<svg data-inline-svg="#{path.id}"))}}
  end
end
