module MapHelper
  def pass_badge_class(pass_type)
    case pass_type.to_s
    when /ikon/i then "pass-badge pass-badge--ikon"
    when /epic/i then "pass-badge pass-badge--epic"
    else "pass-badge pass-badge--none"
    end
  end

  def condition_marker_class(quality)
    "map-marker map-marker--#{quality.presence || 'poor'}"
  end

  def condition_label(quality)
    case quality.to_s
    when "excellent" then "Excellent"
    when "good" then "Good"
    when "marginal" then "Marginal"
    else "Limited data"
    end
  end

  def resort_map_json(resorts)
    json_escape(resorts.to_json)
  end
end
