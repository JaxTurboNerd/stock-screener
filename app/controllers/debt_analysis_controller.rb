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
    metrics   = FmpService.new.fetch_debt_metrics(ticker)
    narrative = PerplexityService.new.analyze_debt_narrative(ticker, metrics)

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
