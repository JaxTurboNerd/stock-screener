class FinanceApiService
  include HTTParty
  base_uri "https://yahoo-finance166.p.rapidapi.com/api/stock"

  def initialize
    @headers = {
      "x-rapidapi-key" => "e752b021f3msh2df98efe31171b5p1c8c0ajsnf5b9d468fad4", # <-- Store your key securely in .env or credentials
      "x-rapidapi-host" => "yahoo-finance166.p.rapidapi.com"
    }
  end

  def get_price(symbol, region = "US")
    response = self.class.get(
      "/get-price",
      headers: @headers,
      query: { region: region, symbol: symbol }
    )

    if response.success?
      # puts "Current price for #{symbol.upcase} (#{region}): #{response.parsed_response}"
      data = response.parsed_response
      regular_market_price = data.dig("quoteSummary", "result", 0, "price", "regularMarketPrice", "raw")
      if regular_market_price
        puts "Current Regular Market Price for #{symbol.upcase} (#{region}): $#{regular_market_price}"
        regular_market_price
      else
        puts "Price not found in response."
        nil
      end
    else
      puts "Error: #{response.code} - #{response.body}"
      nil
    end
  end
end
