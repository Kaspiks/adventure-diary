# frozen_string_literal: true

module IconHelper
  def render_svg_icons
    Rails.cache.fetch("asset_helper_svg_icons", expires_in: 1.hour) do
      icon_path = Rails.root.join("vendor/assets/images/icons.svg")
      return "" unless File.exist?(icon_path)

      raw(File.read(icon_path)) # rubocop:disable Rails/OutputSafety
    end
  end

  def icon(name, types: [], width: 24, height: 24, color: nil, **options)
    use_tag = tag.use(nil, href: "##{name}")
    svg_classes = ["icon"] + types.map { |type| "icon--#{type}" }
    svg_classes += Array(options.delete(:class)) if options[:class]

    tag.svg(
      use_tag,
      viewBox: "0 0 #{width} #{height}",
      class: svg_classes,
      style: color ? "color: #{color}" : nil,
      **options
    )
  end

  def icon_sm(name, **options)
    icon(name, width: 16, height: 16, types: [:sm], **options)
  end

  def icon_lg(name, **options)
    icon(name, width: 32, height: 32, types: [:lg], **options)
  end
end
