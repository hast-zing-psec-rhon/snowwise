module SnowReports
  class HtmlTextExtractor
    MAX_CHARACTERS = 20_000

    def call(raw_text:)
      raw_text
        .to_s
        .gsub(/<script.*?<\/script>/mi, " ")
        .gsub(/<style.*?<\/style>/mi, " ")
        .gsub(/<noscript.*?<\/noscript>/mi, " ")
        .gsub(/<!--.*?-->/m, " ")
        .gsub(/<[^>]+>/, " ")
        .gsub("&nbsp;", " ")
        .gsub("&amp;", "&")
        .squish
        .first(MAX_CHARACTERS)
    end
  end
end
