class YahooFinanceService
  BASE_URL = "https://yahoo-finance166.p.rapidapi.com/api/stock/get-financial-data"
  HEADERS  = {
    "x-rapidapi-key"  => ENV["RAPIDAPI_KEY"],
    "x-rapidapi-host" => "yahoo-finance166.p.rapidapi.com"
  }.freeze

  def fetch_debt_metrics(ticker)
    response = HTTParty.get(
      BASE_URL,
      query:   { symbol: ticker.upcase, region: "US" },
      headers: HEADERS,
      timeout: 15
    )

    raise "Yahoo Finance request failed (#{response.code})" unless response.success?

    parsed = response.parsed_response
    fd = parsed.dig("financialData") ||
         parsed.dig("quoteSummary", "result", 0, "financialData") ||
         {}

    total_debt    = fd.dig("totalDebt",        "raw").to_f
    revenue       = fd.dig("totalRevenue",      "raw").to_f
    profit_margin = fd.dig("profitMargins",     "raw")
    roe           = fd.dig("returnOnEquity",    "raw")
    de_raw        = fd.dig("debtToEquity",      "raw")
    current_ratio = fd.dig("currentRatio",      "raw")
    fcf           = fd.dig("freeCashflow",       "raw").to_f

    net_income = profit_margin && revenue > 0 ? profit_margin * revenue : fd.dig("netIncomeToCommon", "raw").to_f

    {
      profitable:  net_income > 0,
      data_period: "TTM / MRQ (Yahoo Finance)",
      metrics: {
        total_debt:       fmt_currency(total_debt),
        net_income:       fmt_currency(net_income),
        profit_margin:    profit_margin ? "#{(profit_margin * 100).round(2)}%" : nil,
        return_on_equity: roe           ? "#{(roe * 100).round(2)}%"           : nil,
        debt_to_equity:   de_raw        ? (de_raw / 100.0).round(2).to_s       : nil,
        current_ratio:    current_ratio ? current_ratio.round(2).to_s          : nil,
        free_cash_flow:   fmt_currency(fcf)
      }
    }
  rescue => e
    raise "Financial data error: #{e.message}"
  end

  private

  def fmt_currency(val)
    abs  = val.abs
    sign = val < 0 ? "-" : ""
    if abs >= 1_000_000_000
      "#{sign}$#{(abs / 1_000_000_000.0).round(2)}B"
    else
      "#{sign}$#{(abs / 1_000_000.0).round(0).to_i}M"
    end
  end
end
