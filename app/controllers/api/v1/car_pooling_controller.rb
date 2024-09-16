module Api::V1
  class CarPoolingController < ApplicationController
    api :GET, '/status', 'Indicate the service has started up correctly and is ready to accept requests'
    def status
      render json: { message: 'OK' }, status: :ok
    end
  end
end
