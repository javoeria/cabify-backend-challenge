require 'test_helper'

class CarPoolingServiceTest < ActiveSupport::TestCase
  def setup
    @service = CarPoolingService.new
    @service.load_cars([{ id: 1, seats: 4 }, { id: 2, seats: 6 }])
  end

  test 'reset application state' do
    assert_equal(true, @service.add_group(1, 4))
    assert_equal(2, @service.cars.size)
    assert_equal(1, @service.groups.size)

    @service.load_cars([{ id: 1, seats: 4 }, { id: 2, seats: 6 }, { id: 3, seats: 5 }])
    assert_equal(3, @service.cars.size)
    assert_equal(0, @service.groups.size)
  end

  test 'assign different groups to same car' do
    assert_equal(true, @service.add_group(1, 2))
    assert_equal({ id: 1, seats: 4, available_seats: 2 }, @service.cars[1])
    assert_equal({ id: 1, people: 2, car_id: 1 }, @service.groups[1])

    assert_equal(true, @service.add_group(2, 2))
    assert_equal({ id: 1, seats: 4, available_seats: 0 }, @service.cars[1])
    assert_equal({ id: 2, people: 2, car_id: 1 }, @service.groups[2])
  end

  test 'waiting group gets car at dropoff' do
    assert_equal(true, @service.add_group(1, 4))
    assert_equal(true, @service.add_group(2, 5))
    assert_equal(true, @service.add_group(3, 3))

    assert_equal({ id: 3, people: 3 }, @service.groups[3])
    assert_equal(true, @service.group_waiting?(3))
    assert_equal(true, @service.dropoff_group(1))
    assert_equal(false, @service.group_waiting?(3))
    assert_equal({ id: 3, people: 3, car_id: 1 }, @service.groups[3])
  end

  test 'add and remove group correctly' do
    assert_equal(true, @service.add_group(1, 4))
    assert_equal(false, @service.add_group(1, 4))
    assert_equal(@service.cars[1], @service.locate_group(1))

    assert_equal(true, @service.dropoff_group(1))
    assert_equal(false, @service.dropoff_group(1))

    assert_equal(false, @service.add_group(2, 7))
    assert_nil(@service.locate_group(2))
  end

  test 'service with thread safety' do
    car_list = (1..10_000).map { |id| { id: id, seats: rand(4..6) } }
    @service.load_cars(car_list)

    threads = []
    10.times do
      threads << Thread.new do
        10_000.times { |id| @service.add_group(id, rand(1..6)) }
      end
    end
    threads.each(&:join)
    assert_equal(10_000, @service.groups.size)

    sum_seats = @service.cars.values.map { |c| c[:seats] - c[:available_seats] }.sum
    sum_people = @service.groups.values.map { |g| g[:car_id] ? g[:people] : 0 }.sum
    assert_equal(sum_seats, sum_people)
  end
end
