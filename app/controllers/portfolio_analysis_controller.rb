class PortfolioAnalysisController < ApplicationController
  def index
  end

  def upload
    file = params[:portfolio_file]

    unless file.present?
      flash.now[:alert] = "Please select or drop a file to analyze."
      return render :index
    end

    @holdings = PortfolioParserService.new(file).parse

    if @holdings.empty?
      flash.now[:alert] = "No valid holdings found. Check that your file has Ticker and Value columns."
      return render :index
    end

    @total_value = @holdings.sum { |h| h[:value] }
    @analysis    = PerplexityService.new.analyze_portfolio(@holdings)
    render :index
  rescue => e
    flash.now[:alert] = "Analysis failed: #{e.message}"
    render :index
  end
end
