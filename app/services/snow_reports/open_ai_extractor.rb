require "json"
require "http"

module SnowReports
  class OpenAiExtractor
    DEFAULT_API_URL = "https://api.openai.com/v1/responses"

    def initialize(
      api_key: ENV.fetch("OPENAI_API_KEY"),
      model: ENV.fetch("OPENAI_MODEL"),
      reasoning_effort: ENV.fetch("OPENAI_REASONING_EFFORT"),
      api_url: ENV.fetch("OPENAI_API_URL", DEFAULT_API_URL)
    )

      @api_key = api_key
      @model = model
      @reasoning_effort = reasoning_effort
      @api_url = api_url
    end

    def call(resort_name:, source_name:, source_url:, source_type:, queried_at:, source_text:)
      response = HTTP
        .headers(
          "Authorization" => "Bearer #{@api_key}",
          "Content-Type" => "application/json"
        )
        .timeout(connect: 5, read: 60)
        .post(@api_url, json: request_body(
          resort_name: resort_name,
          source_name: source_name,
          source_url: source_url,
          source_type: source_type,
          queried_at: queried_at,
          source_text: source_text
        ))

      unless response.status.success?
        raise "OpenAI extraction failed: #{response.status}"
      end

      JSON.parse(extract_output_text(JSON.parse(response.body.to_s)))
    end

    private

    def request_body(resort_name:, source_name:, source_url:, source_type:, queried_at:, source_text:)
      {
        model: @model,
        reasoning: {
          effort: @reasoning_effort
        },
        instructions: instructions,
        input: input_text(
          resort_name: resort_name,
          source_name: source_name,
          source_url: source_url,
          source_type: source_type,
          queried_at: queried_at,
          source_text: source_text
        ),
        text: {
          format: {
            type: "json_schema",
            name: "snow_observation_extraction",
            strict: true,
            schema: response_schema
          }
        }
      }
    end

    def instructions
      <<~TEXT
        Extract ski resort snow report data from the provided source text.

        Rules:
        - Do not browse or use outside knowledge.
        - Use null for missing numeric values.
        - Do not infer 0 from a missing value.
        - base_depth_inches may be 0 only if the source explicitly reports zero, no snow, closed, pre-season, off-season, or summer operations.
        - If the source reports a nonzero snow depth for a closed resort, preserve the nonzero depth and mark operating_status as closed.
        - Convert centimeters to inches using cm / 2.54.
        - Include short source_evidence explaining the extraction.
      TEXT
    end

    def input_text(resort_name:, source_name:, source_url:, source_type:, queried_at:, source_text:)
      <<~TEXT
        Resort name: #{resort_name}
        Source name: #{source_name}
        Source URL: #{source_url}
        Source type: #{source_type}
        Queried at: #{queried_at}

        Source text:
        #{source_text}
      TEXT
    end

    def response_schema
      {
        type: "object",
        additionalProperties: false,
        required: [
          "resort_name",
          "observed_at",
          "base_depth_inches",
          "mid_depth_inches",
          "upper_depth_inches",
          "new_snow_24h_inches",
          "new_snow_48h_inches",
          "new_snow_7d_inches",
          "operating_status",
          "zero_depth_reason",
          "surface_condition",
          "source_evidence",
          "confidence"
        ],
        properties: {
          resort_name: { type: "string" },
          observed_at: { type: ["string", "null"] },
          base_depth_inches: { type: ["number", "null"] },
          mid_depth_inches: { type: ["number", "null"] },
          upper_depth_inches: { type: ["number", "null"] },
          new_snow_24h_inches: { type: ["number", "null"] },
          new_snow_48h_inches: { type: ["number", "null"] },
          new_snow_7d_inches: { type: ["number", "null"] },
          operating_status: {
            type: "string",
            enum: ["open", "closed", "preseason", "offseason", "summer_operations", "unknown"]
          },
          zero_depth_reason: {
            type: ["string", "null"],
            enum: ["explicit_zero", "closed", "preseason", "offseason", "summer_operations", "no_snow", nil]
          },
          surface_condition: { type: ["string", "null"] },
          source_evidence: { type: "string" },
          confidence: {
            type: "string",
            enum: ["high", "medium", "low"]
          }
        }
      }
    end

    def extract_output_text(response_body)
      response_body.fetch("output").each do |output_item|
        next unless output_item["type"] == "message"

        output_item.fetch("content").each do |content_item|
          return content_item["text"] if content_item["type"] == "output_text"
        end
      end

      raise "OpenAI response did not include output text"
    end
  end
end
