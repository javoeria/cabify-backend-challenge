class ApplicationController < ActionController::API
  rescue_from Apipie::ParamError do |e|
    render json: { error: e.message }, status: :bad_request
  end
end
