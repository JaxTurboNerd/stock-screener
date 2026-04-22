class DebtAnalysisController < ApplicationController
  def index
  end

  def analyze
    ticker = params[:ticker].to_s.strip.upcase

    if ticker.blank?
      flash.now[:alert] = "Please enter a ticker symbol."
      return render :index
    end

    @ticker   = ticker
    metrics   = Rails.cache.fetch("debt_analysis/fmp/#{ticker}", expires_in: 24.hours) do
                  FmpService.new.fetch_debt_metrics(ticker)
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
      "profit_margin_rating"  => narrative["profit_margin_rating"],
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
