module Api::V1
  class CarPoolingController < ApplicationController
    api :GET, '/status', 'Indicate the service has started up correctly and is ready to accept requests'
    def status
      head :ok
    end

    api :PUT, '/cars', 'Load the list of available cars in the service and remove all previous data'
    param :cars, Array do
      param :id, :number, required: true
      param :seats, :number, required: true
    end
    def load_cars
      return head :bad_request if request.content_type != 'application/json'

      cars = params[:cars] || JSON.parse(request.raw_post, symbolize_names: true)
      car_pooling_service.load_cars(cars)
      head :ok
    end

    api :POST, '/journey', 'A group of people requests to perform a journey'
    param :id, :number, required: true
    param :people, :number, required: true
    def perform_journey
      return head :bad_request if request.content_type != 'application/json'

      car_pooling_service.add_group(params[:id].to_i, params[:people].to_i)
      head :ok
    end

    api :POST, '/dropoff', 'A group of people requests to be dropped off'
    param :ID, :number, required: true
    def dropoff_group
      return head :bad_request if request.content_type != 'application/x-www-form-urlencoded'

      group_id = params[:ID].to_i
      if car_pooling_service.dropoff_group(group_id)
        head :ok
      else
        head :not_found
      end
    end

    api :POST, '/locate', 'Return the car the group is traveling with'
    param :ID, :number, required: true
    def locate_group
      return head :bad_request if request.content_type != 'application/x-www-form-urlencoded'

      group_id = params[:ID].to_i
      car = car_pooling_service.locate_group(group_id)
      if car.present?
        render json: car, status: :ok
      elsif car_pooling_service.group_waiting?(group_id)
        head :no_content
      else
        head :not_found
      end
    end

    private

    def car_pooling_service
      @@car_pooling_service ||= CarPoolingService.new
    end
  end
end
