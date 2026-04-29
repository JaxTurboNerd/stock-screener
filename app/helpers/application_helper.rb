module ApplicationHelper
  CHART_COLORS = %w[
    #3B82F6 #10B981 #F59E0B #EF4444 #8B5CF6
    #06B6D4 #F97316 #84CC16 #EC4899 #6B7280 #14B8A6
  ].freeze

  def chart_color(index)
    CHART_COLORS[index % CHART_COLORS.length]
  end
end
