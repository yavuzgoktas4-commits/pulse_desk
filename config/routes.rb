Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "tickets#index"

  post "telegram/webhook", to: "telegram_webhooks#receive"

  resources :tickets, only: %i[index show new create] do
    member do
      patch :mark_as_open
      patch :mark_as_solved
    end
  end
end
