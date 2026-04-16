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
    @analysis = PerplexityService.new.analyze_debt(ticker)
    render :index
  rescue => e
    flash.now[:alert] = "Analysis failed: #{e.message}"
    render :index
  end
end
