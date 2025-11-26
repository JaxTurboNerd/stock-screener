require 'yfinance'

class YFinanceApiService
  def initialize
    @client = YFinance::Client.new
  end

  def get_price(symbol)
    @client.get_price(symbol)
  end

  def screen(params)
    # Build screener query based on parameters
    # Note: The yfinance gem may have different methods for screening
    # This is a placeholder that should be adapted based on the actual gem API
    
    begin
      # Attempt to use the screener functionality
      # The exact implementation depends on the yfinance gem's API
      if @client.respond_to?(:screen)
        @client.screen(build_screener_query(params))
      elsif @client.respond_to?(:screener)
        @client.screener(build_screener_query(params))
      else
        # Fallback: Use HTTParty to call Yahoo Finance screener API directly
        call_screener_api(params)
      end
    rescue StandardError => e
      Rails.logger.error "Screener error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end

  private

  def build_screener_query(params)
    # Build query parameters for the screener
    # This structure should match what the yfinance API expects
    query = {}
    
    # Market Segment
    query[:sector] = params[:sector] if params[:sector].present?
    query[:market_cap] = params[:market_cap] if params[:market_cap].present?
    
    # Price and Volume
    query[:price_min] = params[:share_price_greater_than] if params[:share_price_greater_than].present?
    query[:price_max] = params[:share_price_less_than] if params[:share_price_less_than].present?
    query[:price_performance] = params[:price_performance] if params[:price_performance].present?
    
    # Fundamentals
    query[:pe_ratio] = params[:pe_ratio] if params[:pe_ratio].present?
    query[:peg_ratio] = params[:peg_ratio] if params[:peg_ratio].present?
    query[:profit_margin] = params[:profit_margin] if params[:profit_margin].present?
    query[:price_sales] = params[:price_sales_ratio] if params[:price_sales_ratio].present?
    query[:price_cash_flow] = params[:price_cash_flow] if params[:price_cash_flow].present?
    query[:return_on_equity] = params[:return_on_equity] if params[:return_on_equity].present?
    
    # Earnings and Dividends
    query[:eps_growth] = params[:eps_annual_growth] if params[:eps_annual_growth].present?
    query[:revenue_growth] = params[:annual_revenue_growth] if params[:annual_revenue_growth].present?
    query[:dividend_growth] = params[:dividend_growth_5_year] if params[:dividend_growth_5_year].present?
    query[:dividend_yield] = params[:dividend_yield] if params[:dividend_yield].present?
    query[:dividend_min] = params[:annual_dividend_min] if params[:annual_dividend_min].present?
    query[:dividend_max] = params[:annual_dividend_max] if params[:annual_dividend_max].present?
    
    # Debt
    query[:current_ratio] = params[:current_ratio] if params[:current_ratio].present?
    query[:debt_ratio] = params[:debt_ratio] if params[:debt_ratio].present?
    query[:debt_equity] = params[:debt_equity_ratio] if params[:debt_equity_ratio].present?
    query[:interest_coverage] = params[:interest_coverage_ratio] if params[:interest_coverage_ratio].present?
    
    query
  end

  def call_screener_api(params)
    # Fallback method to call Yahoo Finance screener API directly
    # This uses HTTParty similar to FinanceApiService
    require 'httparty'
    
    headers = {
      "x-rapidapi-key" => ENV.fetch("RAPIDAPI_KEY", Rails.application.credentials.dig(:rapidapi, :key)),
      "x-rapidapi-host" => "yahoo-finance166.p.rapidapi.com",
      "Content-Type" => "application/json"
    }
    
    query_params = build_screener_query(params)
    
    response = HTTParty.post(
      "https://yahoo-finance166.p.rapidapi.com/api/screener",
      headers: headers,
      body: query_params.to_json,
      format: :json
    )
    
    if response.success?
      response.parsed_response
    else
      Rails.logger.error "Screener API error: #{response.code} - #{response.body}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "Screener API call error: #{e.message}"
    nil
  end
end