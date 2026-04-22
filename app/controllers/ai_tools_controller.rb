class AiToolsController < ApplicationController
  def index
  end

  # Example method showing how to format screener params for Perplexity API
  def format_screener_for_llm(screener_params)
    formatter = ScreenerFormatterService.new(screener_params)
    formatter.format_for_llm
  end

  private

  # Extract all screener parameters from the form (same as StocksController)
  def extract_screener_params
    {
      # Market Segment
      sector: params[:sector],
      market_cap: params[:market_cap] || [],

      # Price and Volume
      share_price_greater_than: params[:share_price_greater_than],
      share_price_less_than: params[:share_price_less_than],
      price_performance: params[:price_performance] || [],

      # Fundamentals
      pe_ratio: params[:pe_ratio] || [],
      peg_ratio: params[:peg_ratio],
      profit_margin: params[:profit_margin],
      price_sales_ratio: params[:price_sales_ratio],
      price_cash_flow: params[:price_cash_flow],
      return_on_equity: params[:return_on_equity],

      # Earnings and Dividends
      eps_annual_growth: params[:eps_annual_growth] || [],
      annual_revenue_growth: params[:annual_revenue_growth] || [],
      dividend_growth_5_year: params[:dividend_growth_5_year] || [],
      dividend_yield: params[:dividend_yield] || [],
      annual_dividend_min: params[:annual_dividend_min],
      annual_dividend_max: params[:annual_dividend_max],

      # Debt
      current_ratio: params[:current_ratio] || [],
      debt_ratio: params[:debt_ratio] || [],
      debt_equity_ratio: params[:debt_equity_ratio] || [],
      interest_coverage_ratio: params[:interest_coverage_ratio] || []
    }
  end
end
