require 'yfinance'

class YFinanceApiService
  def initialize
    @client = YFinance::Client.new
  end

  def get_price(symbol)
    @client.get_price(symbol)
  end
end