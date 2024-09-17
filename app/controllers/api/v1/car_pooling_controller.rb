module Api::V1
  class CarPoolingController < ApplicationController
    api :GET, '/status', 'Indicate the service has started up correctly and is ready to accept requests'
    def status
      render json: { message: 'OK' }, status: :ok
    end

    api :PUT, '/cars', 'Load the list of available cars in the service and remove all previous data'
    param :cars, Array do
      param :id, :number, required: true
      param :seats, :number, required: true
    end
    def load_cars
      cars = params[:cars] || request.raw_post
      car_pooling_service.load_cars(cars)
      render json: { message: 'Cars loaded' }, status: :ok
    end

    api :POST, '/journey', 'A group of people requests to perform a journey'
    param :id, :number, required: true
    param :people, :number, required: true
    def perform_journey
      car_pooling_service.add_group(params[:id].to_i, params[:people].to_i)
      render json: { message: 'Group registered' }, status: :ok
    end

    api :POST, '/dropoff', 'A group of people requests to be dropped off'
    param :id, :number, required: true
    def dropoff_group
      group_id = params[:id].to_i
      if car_pooling_service.dropoff_group(group_id)
        render json: { message: 'Group unregistered' }, status: :ok
      else
        render json: { error: 'Group not found' }, status: :not_found
      end
    end

    api :POST, '/locate', 'Return the car the group is traveling with'
    param :id, :number, required: true
    def locate_group
      group_id = params[:id].to_i
      car = car_pooling_service.locate_group(group_id)
      if car.present?
        render json: car, status: :ok
      elsif car_pooling_service.group_waiting?(group_id)
        render json: { message: 'Group waiting for car' }, status: :no_content
      else
        render json: { error: 'Group not found' }, status: :not_found
      end
    end

    private

    def car_pooling_service
      @@car_pooling_service ||= CarPoolingService.new
    end
  end
end
