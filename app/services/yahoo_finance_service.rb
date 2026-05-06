class YahooFinanceService
  BASE_URL       = "https://yahoo-finance166.p.rapidapi.com/api/stock/get-financial-data"
  BASE_STATS_URL = "https://yahoo-finance166.p.rapidapi.com/api/stock/get-statistics"
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
    net_profit_margin = fd.dig("profitMargins",     "raw")
    gross_margin      = fd.dig("grossMargins",      "raw")
    operating_margin  = fd.dig("operatingMargins",  "raw")
    roe               = fd.dig("returnOnEquity",    "raw")
    de_raw        = fd.dig("debtToEquity",      "raw")
    current_ratio = fd.dig("currentRatio",      "raw")
    fcf               = fd.dig("freeCashflow",       "raw").to_f
    operating_cf      = fd.dig("operatingCashflow", "raw").to_f

    net_income = net_profit_margin && revenue > 0 ? net_profit_margin * revenue : fd.dig("netIncomeToCommon", "raw").to_f
    cash_flow_margin  = revenue > 0 && operating_cf != 0 ? operating_cf / revenue : nil

    ks, _sd = fetch_statistics(ticker)

    current_price      = fd.dig("currentPrice",      "raw").to_f
    trailing_eps       = ks.dig("trailingEps",        "raw")
    shares_outstanding = ks.dig("sharesOutstanding",  "raw").to_f

    pe_raw  = (current_price > 0 && trailing_eps && trailing_eps != 0) ? current_price / trailing_eps.to_f : nil
    peg_raw = ks.dig("pegRatio",    "raw")
    pb_raw  = ks.dig("priceToBook", "raw")

    market_cap = (current_price > 0 && shares_outstanding > 0) ? current_price * shares_outstanding : 0.0
    pcf_raw = (market_cap > 0 && operating_cf != 0) ? market_cap / operating_cf : nil

    {
      profitable:  net_income > 0,
      data_period: "TTM / MRQ (Yahoo Finance)",
      metrics: {
        total_debt:       fmt_currency(total_debt),
        net_income:       fmt_currency(net_income),
        net_profit_margin:   net_profit_margin ? "#{(net_profit_margin * 100).round(2)}%" : nil,
        gross_profit_margin:     gross_margin     ? "#{(gross_margin     * 100).round(2)}%" : nil,
        operating_profit_margin: operating_margin ? "#{(operating_margin * 100).round(2)}%" : nil,
        cash_flow_margin:        cash_flow_margin  ? "#{(cash_flow_margin  * 100).round(2)}%" : nil,
        return_on_equity: roe           ? "#{(roe * 100).round(2)}%"           : nil,
        debt_to_equity:   de_raw        ? (de_raw / 100.0).round(2).to_s       : nil,
        current_ratio:    current_ratio ? current_ratio.round(2).to_s          : nil,
        free_cash_flow:   fmt_currency(fcf),
        pe_ratio:           pe_raw  ? pe_raw.round(2).to_s  : nil,
        peg_ratio:          peg_raw ? peg_raw.round(2).to_s : nil,
        price_to_book:      pb_raw  ? pb_raw.round(2).to_s  : nil,
        price_to_cash_flow: pcf_raw ? pcf_raw.round(2).to_s : nil
      }
    }
  rescue => e
    raise "Financial data error: #{e.message}"
  end

  private

  def fetch_statistics(ticker)
    response = HTTParty.get(
      BASE_STATS_URL,
      query:   { symbol: ticker.upcase, region: "US" },
      headers: HEADERS,
      timeout: 15
    )
    return [ {}, {} ] unless response.success?

    sp = response.parsed_response
    ks = sp.dig("defaultKeyStatistics") ||
         sp.dig("quoteSummary", "result", 0, "defaultKeyStatistics") ||
         {}
    sd = sp.dig("summaryDetail") ||
         sp.dig("quoteSummary", "result", 0, "summaryDetail") ||
         {}
    [ ks, sd ]
  rescue
    [ {}, {} ]
  end

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
