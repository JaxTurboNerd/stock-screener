class PerplexityService
  API_URL = "https://api.perplexity.ai/chat/completions"
  MODEL   = "sonar-pro"

  SECTOR_NAMES = [
    "Technology", "Healthcare", "Financial Services", "Consumer Cyclical",
    "Consumer Defensive", "Energy", "Industrials", "Materials",
    "Real Estate", "Utilities", "Communication Services"
  ].freeze

  def analyze_portfolio(holdings)
    total = holdings.sum { |h| h[:value] }
    holdings_text = holdings.map { |h| "#{h[:ticker]}: $#{format('%.2f', h[:value])}" }.join("\n")

    prompt = <<~PROMPT
      You are a financial analyst. Classify each stock in this portfolio by market sector and analyze diversity.

      Portfolio holdings (ticker: market value):
      #{holdings_text}
      Total portfolio value: $#{format('%.2f', total)}

      Respond with ONLY valid JSON — no markdown fences, no extra text:
      {
        "sectors": [
          {
            "name": "Technology",
            "percentage": 45.2,
            "value": 25000.00,
            "holdings": ["AAPL", "MSFT"]
          }
        ],
        "concentration_alerts": [
          {
            "sector": "Technology",
            "percentage": 45.2,
            "threshold": 25.0,
            "severity": "high"
          }
        ],
        "recommendations": [
          "Consider adding exposure to Healthcare or Consumer Defensive sectors to reduce Technology concentration.",
          "Diversify within Technology by adding international tech ETFs.",
          "Add bond or fixed-income ETFs to reduce overall equity concentration risk."
        ],
        "analysis": "2-3 paragraph narrative about portfolio diversity, concentration risks, and recommendations."
      }

      Rules:
      - Use only these sector names: #{SECTOR_NAMES.join(', ')}
      - Percentages must sum to exactly 100
      - Values must sum to the total portfolio value
      - Every ticker must appear in exactly one sector
      - concentration_alerts: include any sector exceeding 25% (industry standard overweight threshold). severity is "high" if >40%, "medium" if 25-40%. Return empty array [] if no sectors exceed 25%.
      - recommendations: provide 1-3 specific, actionable recommendations to reduce concentration risk. If no alerts exist, return [] (empty array).
    PROMPT

    response = HTTParty.post(
      API_URL,
      headers: {
        "Authorization" => "Bearer #{ENV['PPL_API_KEY']}",
        "Content-Type"  => "application/json"
      },
      body: {
        model: MODEL,
        messages: [ { role: "user", content: prompt } ],
        temperature: 0.1
      }.to_json,
      timeout: 30
    )

    raise "Perplexity API error (#{response.code}): #{response.message}" unless response.success?

    content = response.parsed_response.dig("choices", 0, "message", "content").to_s
    parse_json(content)
  end

  def analyze_debt_narrative(ticker, metrics)
    m = metrics[:metrics]
    prompt = <<~PROMPT
      You are a financial analyst. Write a narrative analysis of the debt profile and profitability of #{ticker.upcase}.

      Use these verified financial figures (do not contradict them):
      - Total Debt: #{m[:total_debt]}
      - Net Income (TTM): #{m[:net_income]}
      - Gross Profit Margin (TTM): #{m[:gross_profit_margin]}
      - Operating Profit Margin (TTM): #{m[:operating_profit_margin]}
      - Net Profit Margin (TTM): #{m[:net_profit_margin]}
      - Cash Flow Margin (TTM): #{m[:cash_flow_margin]}
      - Return on Equity (TTM): #{m[:return_on_equity]}
      - Debt / Equity: #{m[:debt_to_equity]}
      - Current Ratio (MRQ): #{m[:current_ratio]}
      - Free Cash Flow (TTM): #{m[:free_cash_flow]}
      - Profitable: #{metrics[:profitable]}

      Respond with ONLY valid JSON — no markdown fences, no extra text:
      {
        "company_name": "Full Company Name",
        "profitability_summary": "One sentence on whether the company is profitable and why.",
        "debt_rating": "Investment Grade / Speculative / Not Rated",
        "net_profit_margin_rating": "good / average / bad",
        "sector": "GICS sector name (e.g. Technology, Healthcare, Industrials)",
        "analysis": "2-3 paragraph narrative covering debt structure, ability to service debt, profitability trends, and key risks."
      }

      Rules:
      - net_profit_margin_rating: Rate the net profit margin as "good", "average", or "bad" relative to industry peers and sector norms. Use exactly one of those three words.
      - sector: Use the standard GICS sector name the company belongs to.
    PROMPT

    response = HTTParty.post(
      API_URL,
      headers: {
        "Authorization" => "Bearer #{ENV['PPL_API_KEY']}",
        "Content-Type"  => "application/json"
      },
      body: {
        model: MODEL,
        messages: [ { role: "user", content: prompt } ],
        temperature: 0.2
      }.to_json,
      timeout: 30
    )

    raise "Perplexity API error (#{response.code}): #{response.message}" unless response.success?

    content = response.parsed_response.dig("choices", 0, "message", "content").to_s
    parse_json(content)
  end

  private

  def parse_json(content)
    cleaned = content.gsub(/\A```(?:json)?\s*/i, "").gsub(/\s*```\z/, "").strip
    JSON.parse(cleaned)
  rescue JSON::ParserError
    match = cleaned.match(/\{[\s\S]*\}/)
    raise "Could not parse AI response as JSON. Raw response: #{cleaned[0..300]}" unless match
    JSON.parse(match[0])
  end
end
