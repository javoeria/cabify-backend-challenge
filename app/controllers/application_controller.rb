class ApplicationController < ActionController::API
  rescue_from Apipie::ParamError do
    head :bad_request
  end

  def method_not_allowed
    head :method_not_allowed
  end
end
