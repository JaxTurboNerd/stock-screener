require "csv"

class PortfolioParserService
  TICKER_HEADERS = %w[stock ticker symbol].freeze
  VALUE_HEADERS  = %w[value amount total market_value marketvalue].freeze
  SHARES_HEADERS = %w[shares quantity qty].freeze
  PRICE_HEADERS  = %w[current_price price last_price lastprice currentprice].freeze

  def initialize(file)
    @file = file
  end

  def parse
    ext = File.extname(@file.original_filename).downcase
    case ext
    when ".csv"  then parse_csv
    when ".xlsx" then parse_excel(Roo::Excelx.new(@file.path))
    when ".xls"  then parse_excel(Roo::Excel.new(@file.path))
    else raise "Unsupported file format: #{ext}. Please upload CSV, XLS, or XLSX."
    end
  end

  private

  def normalize(h)
    h.to_s.strip.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_|_\z/, "")
  end

  def parse_csv
    raw = @file.read.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace)
    raw.sub!(/\A\xEF\xBB\xBF/, "") # strip UTF-8 BOM

    all_rows = CSV.parse(raw, skip_blanks: true)
    raise "File appears to be empty." if all_rows.empty?

    headers_raw  = all_rows[0]
    headers_norm = headers_raw.map { |h| normalize(h) }
    data_rows    = all_rows[1..]

    extract_holdings(headers_norm, data_rows)
  end

  def parse_excel(spreadsheet)
    sheet = spreadsheet.sheet(0)
    headers_raw  = sheet.row(1).map { |h| h.to_s }
    headers_norm = headers_raw.map { |h| normalize(h) }
    data_rows    = (2..sheet.last_row).map { |i| sheet.row(i).map(&:to_s) }

    extract_holdings(headers_norm, data_rows)
  end

  # Uses column indices so there is no header-key ambiguity.
  def extract_holdings(headers_norm, data_rows)
    ticker_idx = headers_norm.index { |h| TICKER_HEADERS.include?(h) }
    value_idx  = headers_norm.index { |h| VALUE_HEADERS.include?(h) }
    shares_idx = headers_norm.index { |h| SHARES_HEADERS.include?(h) }
    price_idx  = headers_norm.index { |h| PRICE_HEADERS.include?(h) }

    unless ticker_idx
      raise "Could not find a ticker/symbol column. " \
            "Found: [#{headers_norm.join(', ')}]. " \
            "Expected a column named 'Ticker', 'Stock', or 'Symbol'."
    end

    unless value_idx || (shares_idx && price_idx)
      raise "Could not find value columns. " \
            "Found: [#{headers_norm.join(', ')}]. " \
            "Expected 'Shares' and 'Current Price' columns (or a 'Value' column)."
    end

    results = data_rows.filter_map do |row|
      ticker = row[ticker_idx].to_s.strip.upcase
      next if ticker.empty?

      value = if value_idx && row[value_idx].to_s.strip.present?
        parse_number(row[value_idx])
      elsif shares_idx && price_idx
        shares = parse_number(row[shares_idx])
        price  = parse_number(row[price_idx])
        shares && price ? shares * price : nil
      end

      next if value.nil? || value <= 0
      { ticker: ticker, value: value }
    end

    if results.empty? && data_rows.any?
      all_zero_shares = shares_idx && data_rows.all? { |r| r[shares_idx].to_s.strip == "0" }
      raise "All rows have 0 shares. Please enter the number of shares you hold for each stock." if all_zero_shares
      raise "Rows found but none produced a valid value. Check that Shares and Current Price columns contain numbers."
    end

    results
  end

  def parse_number(val)
    return nil if val.nil?
    cleaned = val.to_s.gsub(/[$,\s]/, "").strip
    return nil if cleaned.empty?
    cleaned.to_f
  end
end
