require "test_helper"

class CarPoolingControllerTest < ActionController::TestCase
  def setup
    @controller = Api::V1::CarPoolingController.new
  end

  test "status" do
    # When the service is ready to receive requests
    get(:status)
    assert_response 200
  end

  test "load_cars" do
    # Load the list of available cars
    put(:load_cars, params: { cars: [{ id: 1, seats: 4 }, { id: 2, seats: 6 }] })
    assert_response 200

    # When there is a failure in the request
    put(:load_cars, params: { cars: [{ id: 1, seats: 4 }, { id: 2, seats: -6 }] })
    assert_response 400
  end

  test "perform_journey" do
    put(:load_cars, params: { cars: [{ id: 1, seats: 4 }, { id: 2, seats: 6 }] })

    # When the group is registered correctly
    post(:perform_journey, params: { id: 1, people: 4 })
    assert_response 200

    # When there is a failure in the request
    post(:perform_journey, params: { id: 1 })
    assert_response 400
  end

  test "dropoff_group" do
    put(:load_cars, params: { cars: [{ id: 1, seats: 4 }, { id: 2, seats: 6 }] })
    post(:perform_journey, params: { id: 1, people: 4 })

    # When the group is unregistered correctly
    post(:dropoff_group, params: { id: 1 })
    assert_response 200

    # When the group is not to be found
    post(:dropoff_group, params: { id: 2 })
    assert_response 404

    # When there is a failure in the request
    post(:dropoff_group, params: {})
    assert_response 400
  end

  test "locate_group" do
    put(:load_cars, params: { cars: [{ id: 1, seats: 4 }, { id: 2, seats: 6 }] })
    post(:perform_journey, params: { id: 1, people: 4 })
    post(:perform_journey, params: { id: 2, people: 5 })
    post(:perform_journey, params: { id: 3, people: 3 })

    # Return car data when the group is assigned to a car
    post(:locate_group, params: { id: 1 })
    assert_response 200
    car = JSON.parse(@response.body)
    assert_equal(1, car['id'])
    assert_equal(4, car['seats'])

    # When the group is waiting to be assigned to a car
    post(:locate_group, params: { id: 3 })
    assert_response 204

    # When the group is not to be found
    post(:locate_group, params: { id: 4 })
    assert_response 404

    # When there is a failure in the request
    post(:locate_group, params: {})
    assert_response 400
  end
end
