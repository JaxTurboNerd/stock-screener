class AnalysisController < ApplicationController
  def index
  end

  def ticker_search
    query = params[:q].to_s.strip
    return render json: [] if query.length < 1

    results = Rails.cache.fetch("ticker_search/#{query.upcase}", expires_in: 1.hour) do
      response = HTTParty.get(
        "https://yahoo-finance166.p.rapidapi.com/api/autocomplete",
        query: { query: query, region: "US" },
        headers: {
          "x-rapidapi-key"  => ENV.fetch("RAPIDAPI_KEY", Rails.application.credentials.dig(:rapidapi, :key)),
          "x-rapidapi-host" => "yahoo-finance166.p.rapidapi.com"
        }
      )
      if response.success?
        quotes = response.parsed_response["quotes"] || []
        quotes.map { |q| { symbol: q["symbol"], name: q["shortname"] || q["longname"] } }
      else
        []
      end
    end

    render json: results
  end

  def analyze
    ticker = params[:ticker].to_s.strip.upcase

    if ticker.blank?
      flash.now[:alert] = "Please enter a ticker symbol."
      return render :index
    end

    @ticker   = ticker
    metrics   = Rails.cache.fetch("debt_analysis/yahoo_finance/v3/#{ticker}", expires_in: 24.hours) do
                  YahooFinanceService.new.fetch_debt_metrics(ticker)
                end
    narrative = Rails.cache.fetch("debt_analysis/perplexity/#{ticker}", expires_in: 7.days) do
                  PerplexityService.new.analyze_debt_narrative(ticker, metrics)
                end

    @analysis = {
      "company_name"        => narrative["company_name"],
      "ticker"              => ticker,
      "profitable"          => metrics[:profitable],
      "data_period"         => metrics[:data_period],
      "debt_rating"           => narrative["debt_rating"],
      "net_profit_margin_rating" => narrative["net_profit_margin_rating"],
      "sector"                => narrative["sector"],
      "profitability_summary" => narrative["profitability_summary"],
      "analysis"            => narrative["analysis"],
      "metrics"             => metrics[:metrics].transform_keys(&:to_s)
    }

    render :index
  rescue => e
    flash.now[:alert] = "Analysis failed: #{e.message}"
    render :index
  end
end
