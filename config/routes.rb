Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  apipie
  scope module: 'api/v1', defaults: { format: :json } do
    get 'status',   to: 'car_pooling#status'
    put 'cars',     to: 'car_pooling#load_cars'
    post 'journey', to: 'car_pooling#perform_journey'
    post 'dropoff', to: 'car_pooling#dropoff_group'
    post 'locate',  to: 'car_pooling#locate_group'
  end
end
