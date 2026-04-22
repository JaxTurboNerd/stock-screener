class ScreenerFormatterService
  SECTOR_NAMES = {
    "basic-materials" => "Basic Materials",
    "consumer-discretionary" => "Consumer Discretionary",
    "consumer-staples" => "Consumer Staples",
    "energy" => "Energy",
    "financials" => "Financials",
    "health-care" => "Health Care",
    "industrials" => "Industrials",
    "real-estate" => "Real Estate",
    "technology" => "Technology",
    "utilities" => "Utilities"
  }.freeze

  MARKET_CAP_NAMES = {
    "micro_cap" => "Micro Cap",
    "small_cap" => "Small Cap",
    "mid_cap" => "Mid Cap",
    "large_cap" => "Large Cap",
    "mega_cap" => "Mega Cap"
  }.freeze

  PRICE_PERFORMANCE_NAMES = {
    "lt_40" => "less than -40%",
    "minus_40_to_minus_20" => "-40% to -20%",
    "minus_20_to_0" => "-20% to 0%",
    "zero_to_20" => "0% to 20%",
    "gt_40" => "greater than 40%"
  }.freeze

  def initialize(screener_params)
    @params = screener_params
  end

  def format_for_llm
    parts = []

    # Market Segment
    market_segment = format_market_segment
    parts << market_segment if market_segment.present?

    # Price and Volume
    price_volume = format_price_and_volume
    parts << price_volume if price_volume.present?

    # Fundamentals
    fundamentals = format_fundamentals
    parts << fundamentals if fundamentals.present?

    # Earnings and Dividends
    earnings_dividends = format_earnings_and_dividends
    parts << earnings_dividends if earnings_dividends.present?

    # Debt
    debt = format_debt
    parts << debt if debt.present?

    if parts.empty?
      "I am looking for stocks with no specific criteria."
    else
      "I am looking for stocks with the following criteria: #{parts.join(' ')}"
    end
  end

  private

  def format_market_segment
    parts = []

    if @params[:sector].present?
      sector_name = SECTOR_NAMES[@params[:sector]] || @params[:sector].humanize
      parts << "in the #{sector_name} sector"
    end

    if @params[:market_cap].present? && @params[:market_cap].any?
      market_caps = @params[:market_cap].map { |cap| MARKET_CAP_NAMES[cap] || cap.humanize }
      parts << "with market capitalization of #{market_caps.join(', ')}"
    end

    parts.any? ? parts.join(", ") : nil
  end

  def format_price_and_volume
    parts = []

    if @params[:share_price_greater_than].present? || @params[:share_price_less_than].present?
      price_range = []
      price_range << "greater than $#{@params[:share_price_greater_than]}" if @params[:share_price_greater_than].present?
      price_range << "less than $#{@params[:share_price_less_than]}" if @params[:share_price_less_than].present?
      parts << "with share price #{price_range.join(' and ')}"
    end

    if @params[:price_performance].present? && @params[:price_performance].any?
      performances = @params[:price_performance].map { |perf| PRICE_PERFORMANCE_NAMES[perf] || perf.humanize }
      parts << "with price performance versus industry of #{performances.join(', ')}"
    end

    parts.any? ? parts.join(", ") : nil
  end

  def format_fundamentals
    parts = []

    if @params[:pe_ratio].present? && @params[:pe_ratio].any?
      pe_ranges = @params[:pe_ratio].map { |pe| format_pe_ratio(pe) }
      parts << "with PE ratio of #{pe_ranges.join(' or ')}"
    end

    if @params[:peg_ratio].present?
      parts << "with PEG ratio #{format_peg_ratio(@params[:peg_ratio])}"
    end

    if @params[:profit_margin].present?
      parts << "with profit margin #{format_profit_margin(@params[:profit_margin])}"
    end

    if @params[:price_sales_ratio].present?
      parts << "with Price/Sales ratio #{format_price_sales_ratio(@params[:price_sales_ratio])}"
    end

    if @params[:price_cash_flow].present?
      parts << "with Price/Cash Flow ratio #{format_price_cash_flow(@params[:price_cash_flow])}"
    end

    if @params[:return_on_equity].present?
      parts << "with Return on Equity #{format_return_on_equity(@params[:return_on_equity])}"
    end

    parts.any? ? parts.join(", ") : nil
  end

  def format_earnings_and_dividends
    parts = []

    if @params[:eps_annual_growth].present? && @params[:eps_annual_growth].any?
      eps_ranges = @params[:eps_annual_growth].map { |eps| format_percentage_range(eps, "%") }
      parts << "with EPS annual growth of #{eps_ranges.join(' or ')}"
    end

    if @params[:annual_revenue_growth].present? && @params[:annual_revenue_growth].any?
      revenue_ranges = @params[:annual_revenue_growth].map { |rev| format_percentage_range(rev, "%") }
      parts << "with annual revenue growth of #{revenue_ranges.join(' or ')}"
    end

    if @params[:dividend_growth_5_year].present? && @params[:dividend_growth_5_year].any?
      div_growth = @params[:dividend_growth_5_year].map { |dg| format_percentage_range(dg, "%") }
      parts << "with 5-year dividend growth of #{div_growth.join(' or ')}"
    end

    if @params[:dividend_yield].present? && @params[:dividend_yield].any?
      yields = @params[:dividend_yield].map { |dy| format_percentage_range(dy, "%") }
      parts << "with dividend yield of #{yields.join(' or ')}"
    end

    if @params[:annual_dividend_min].present? || @params[:annual_dividend_max].present?
      div_range = []
      div_range << "greater than $#{@params[:annual_dividend_min]}" if @params[:annual_dividend_min].present?
      div_range << "less than $#{@params[:annual_dividend_max]}" if @params[:annual_dividend_max].present?
      parts << "with annual dividend #{div_range.join(' and ')}"
    end

    parts.any? ? parts.join(", ") : nil
  end

  def format_debt
    parts = []

    if @params[:current_ratio].present? && @params[:current_ratio].any?
      ratios = @params[:current_ratio].map { |cr| format_current_ratio(cr) }
      parts << "with current ratio of #{ratios.join(' or ')}"
    end

    if @params[:debt_ratio].present? && @params[:debt_ratio].any?
      ratios = @params[:debt_ratio].map { |dr| format_debt_ratio(dr) }
      parts << "with debt ratio of #{ratios.join(' or ')}"
    end

    if @params[:debt_equity_ratio].present? && @params[:debt_equity_ratio].any?
      ratios = @params[:debt_equity_ratio].map { |der| format_debt_equity_ratio(der) }
      parts << "with debt-to-equity ratio of #{ratios.join(' or ')}"
    end

    if @params[:interest_coverage_ratio].present? && @params[:interest_coverage_ratio].any?
      ratios = @params[:interest_coverage_ratio].map { |icr| format_interest_coverage_ratio(icr) }
      parts << "with interest coverage ratio of #{ratios.join(' or ')}"
    end

    parts.any? ? parts.join(", ") : nil
  end

  def format_pe_ratio(value)
    case value
    when "0_15" then "0-15x"
    when "15_25" then "15-25x"
    when "25_50" then "25-50x"
    when "50_100" then "50-100x"
    else value.humanize
    end
  end

  def format_peg_ratio(value)
    case value
    when "lt_1" then "less than 1"
    when "1_2" then "between 1 and 2"
    when "2_3" then "between 2 and 3"
    when "3_4" then "between 3 and 4"
    when "gt_4" then "greater than 4"
    else value.humanize
    end
  end

  def format_profit_margin(value)
    case value
    when "negative" then "negative"
    when "0_5" then "between 0% and 5%"
    when "5_10" then "between 5% and 10%"
    when "10_20" then "between 10% and 20%"
    when "gt_20" then "greater than 20%"
    else value.humanize
    end
  end

  def format_price_sales_ratio(value)
    case value
    when "lt_1" then "less than 1"
    when "1_2" then "between 1 and 2"
    when "2_4" then "between 2 and 4"
    when "4_6" then "between 4 and 6"
    when "gt_6" then "greater than 6"
    else value.humanize
    end
  end

  def format_price_cash_flow(value)
    case value
    when "lt_10" then "less than 10"
    when "10_20" then "between 10 and 20"
    when "20_30" then "between 20 and 30"
    when "30_40" then "between 30 and 40"
    when "gt_40" then "greater than 40"
    else value.humanize
    end
  end

  def format_return_on_equity(value)
    case value
    when "negative" then "negative"
    when "0_5" then "between 0% and 5%"
    when "5_10" then "between 5% and 10%"
    when "10_20" then "between 10% and 20%"
    when "gt_20" then "greater than 20%"
    else value.humanize
    end
  end

  def format_percentage_range(value, suffix = "")
    case value
    when "0_5" then "0-5#{suffix}"
    when "5_10" then "5-10#{suffix}"
    when "10_15" then "10-15#{suffix}"
    when "15_25" then "15-25#{suffix}"
    when "25_50" then "25-50#{suffix}"
    when "gt_50" then "greater than 50#{suffix}"
    when "gt_15" then "greater than 15#{suffix}"
    when "0_2" then "0-2#{suffix}"
    when "2_4" then "2-4#{suffix}"
    when "4_6" then "4-6#{suffix}"
    when "6_8" then "6-8#{suffix}"
    when "gt_8" then "greater than 8#{suffix}"
    else "#{value}#{suffix}"
    end
  end

  def format_current_ratio(value)
    case value
    when "lt_1_0" then "less than 1.0"
    when "1_0_2_0" then "between 1.0 and 2.0"
    when "2_0_3_0" then "between 2.0 and 3.0"
    when "gt_3_0" then "greater than 3.0"
    else value.humanize
    end
  end

  def format_debt_ratio(value)
    case value
    when "lt_0_3" then "less than 0.3"
    when "0_3_0_5" then "between 0.3 and 0.5"
    when "0_5_0_7" then "between 0.5 and 0.7"
    when "gt_0_7" then "greater than 0.7"
    else value.humanize
    end
  end

  def format_debt_equity_ratio(value)
    case value
    when "lt_1_0" then "less than 1.0"
    when "1_0_2_0" then "between 1.0 and 2.0"
    when "2_0_3_0" then "between 2.0 and 3.0"
    when "gt_3_0" then "greater than 3.0"
    else value.humanize
    end
  end

  def format_interest_coverage_ratio(value)
    case value
    when "lt_1_5" then "less than 1.5"
    when "1_5_2_5" then "between 1.5 and 2.5"
    when "2_5_5_0" then "between 2.5 and 5.0"
    when "gt_5_0" then "greater than 5.0"
    else value.humanize
    end
  end
end
