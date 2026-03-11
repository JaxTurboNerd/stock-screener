class PortfolioAnalysisController < ApplicationController
  def index
  end

  def upload
    file = params[:portfolio_file]
    if file.present?
      # TODO: perform portfolio analysis with uploaded file
      flash[:notice] = "File \"#{file.original_filename}\" received. Portfolio analysis will use this file."
    else
      flash[:alert] = "Please select or drop a file to analyze."
    end
    redirect_to portfolio_analysis_path
  end
end
