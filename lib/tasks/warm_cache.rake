namespace :cache do
  WATCH_LIST = %w[
    AAPL MSFT GOOGL AMZN META
    NVDA TSLA JPM JNJ UNH
    V MA HD PG KO
    PEP WMT DIS BA GE
    XOM CVX AMD INTC NFLX
  ].freeze

  desc "Pre-warm debt analysis cache for #{WATCH_LIST.size} companies (skips already-cached tickers)"
  task warm_debt_analysis: :environment do
    total   = WATCH_LIST.size
    skipped = 0
    fetched = 0
    failed  = []

    WATCH_LIST.each_with_index do |ticker, i|
      fmp_key = "debt_analysis/fmp/#{ticker}"
      ppl_key = "debt_analysis/perplexity/#{ticker}"

      if Rails.cache.exist?(fmp_key) && Rails.cache.exist?(ppl_key)
        puts "[#{i + 1}/#{total}] #{ticker} — already cached, skipping"
        skipped += 1
        next
      end

      print "[#{i + 1}/#{total}] #{ticker} — fetching..."

      begin
        metrics = Rails.cache.fetch(fmp_key, expires_in: 48.hours) do
          FmpService.new.fetch_debt_metrics(ticker)
        end
        Rails.cache.fetch(ppl_key, expires_in: 7.days) do
          PerplexityService.new.analyze_debt_narrative(ticker, metrics)
        end
        puts " done"
        fetched += 1
      rescue => e
        puts " FAILED: #{e.message}"
        failed << ticker
      end

      sleep 1 unless i == total - 1
    end

    puts "\nCache warm complete — #{fetched} fetched, #{skipped} skipped, #{failed.size} failed"
    puts "Failed tickers: #{failed.join(', ')}" if failed.any?
  end

  desc "Clear all cached debt analysis data"
  task clear_debt_analysis: :environment do
    WATCH_LIST.each do |ticker|
      Rails.cache.delete("debt_analysis/fmp/#{ticker}")
      Rails.cache.delete("debt_analysis/perplexity/#{ticker}")
    end
    puts "Cleared debt analysis cache for #{WATCH_LIST.size} tickers"
  end
end
