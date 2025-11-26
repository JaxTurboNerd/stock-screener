class StocksController < ApplicationController
  before_action :set_stock, only: %i[ show edit update destroy ]

  # GET /stocks or /stocks.json
  def index
    @stocks = Stock.all
    service = FinanceApiService.new
    # @result = service.get_price("AAPL")

    # if @result
    #   render json: @result
    # else
    #   render json: { error: "Unable to fetch stock price for Apple" }, status: :bad_request
    # end
  end

  # GET /stocks/1 or /stocks/1.json
  def show
  end

  # GET /stocks/new
  def new
    @stock = Stock.new
  end

  # GET /stocks/1/edit
  def edit
  end

  # POST /stocks or /stocks.json
  def create
    @stock = Stock.new(stock_params)

    respond_to do |format|
      if @stock.save
        format.html { redirect_to @stock, notice: "Stock was successfully created." }
        format.json { render :show, status: :created, location: @stock }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stocks/1 or /stocks/1.json
  def update
    respond_to do |format|
      if @stock.update(stock_params)
        format.html { redirect_to @stock, notice: "Stock was successfully updated." }
        format.json { render :show, status: :ok, location: @stock }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stocks/1 or /stocks/1.json
  def destroy
    @stock.destroy!

    respond_to do |format|
      format.html { redirect_to stocks_path, status: :see_other, notice: "Stock was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # POST /stocks/search
  def search
    screener_params = extract_screener_params
    service = YFinanceApiService.new
    @results = service.screen(screener_params)

    respond_to do |format|
      if @results
        format.html { render :search_results }
        format.json { render json: @results }
      else
        format.html { redirect_to root_path, alert: "Unable to perform stock screening. Please try again." }
        format.json { render json: { error: "Unable to perform stock screening" }, status: :bad_request }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_stock
    @stock = Stock.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def stock_params
    params.fetch(:stock, {})
  end

  # Extract all screener parameters from the form
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

  # This function is used to get the AAPL stock.
  def price
    service = FinanceApiService.new
    result = service.get_price("AAPL")

    if result
      render json: result
    else
      render json: { error: "Unable to fetch stock price for Apple" }, status: :bad_request
    end
  end
end
