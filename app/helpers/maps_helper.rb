module MapsHelper
  def resort_map_json(resorts)
    json_escape(resorts.to_json)
  end

  def map_summary_name(summary, key)
    summary.dig(key, :name) || "-"
  end
end
