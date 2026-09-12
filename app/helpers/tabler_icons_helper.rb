# frozen_string_literal: true

module TablerIconsHelper
  def tabler_icon(name, size: 16, **options)
    css_class = options.delete(:class)
    style = "font-size: #{size}px; line-height: 1; display: inline-flex; align-items: center; justify-content: center;"
    style = "#{style} #{options.delete(:style)}" if options[:style]

    tag.i(
      "",
      class: [ "ti", "ti-#{name}", css_class ].compact.join(" "),
      style: style,
      "aria-hidden": "true",
      **options
    )
  end
end
