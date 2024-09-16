Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  apipie
  scope module: 'api/v1', defaults: { format: :json } do
    get 'status', to: 'car_pooling#status'
  end
end
