Rails.application.routes.draw do
  resources :stocks do
    collection do
      post :search
    end
  end

  # Defined Routes:
  root to: "portfolio_analysis#index" # Same as "/"
  get "ai_tool", to: "ai_tools#index", as: :ai_tool
  get "portfolio_analysis", to: "portfolio_analysis#index", as: :portfolio_analysis
  get  "debt_analysis",         to: "debt_analysis#index",   as: :debt_analysis
  post "debt_analysis/analyze", to: "debt_analysis#analyze", as: :debt_analysis_analyze
  post "portfolio_analysis/upload", to: "portfolio_analysis#upload", as: :portfolio_analysis_upload

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
