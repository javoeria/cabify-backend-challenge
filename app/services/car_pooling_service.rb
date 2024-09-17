class CarPoolingService
  attr_reader :cars, :groups

  def initialize
    @cars = {}   # Hash table for cars: car_id => { seats: int, available_seats: int }
    @groups = {} # Hash table for groups: group_id => { people: int, car_id: int or nil }
  end

  def load_cars(car_list)
    @cars.clear
    @groups.clear

    car_list.each { |car| @cars[car[:id].to_i] = { id: car[:id].to_i, seats: car[:seats].to_i, available_seats: car[:seats].to_i } }
  end

  def add_group(group_id, people_count)
    return false if people_count < 1 || people_count > 6 || @groups.key?(group_id)

    group = { id: group_id, people: people_count }
    assign_group_to_car(group)
    true
  end

  def dropoff_group(group_id)
    group = @groups.delete(group_id)
    if group.present?
      if group[:car_id].present?
        @cars[group[:car_id]][:available_seats] += group[:people]
        @groups.each_value { |group| assign_group_to_car(group) if group[:car_id].nil? }
      end
      true
    else
      false
    end
  end

  def locate_group(group_id)
    group = @groups[group_id]
    @cars[group[:car_id]] if group.present? && group[:car_id].present?
  end

  def group_waiting?(group_id)
    @groups[group_id] && @groups[group_id][:car_id].nil?
  end

  private

  def assign_group_to_car(group)
    available_car = @cars.values.find { |car| car[:available_seats] >= group[:people] }
    if available_car.present?
      available_car[:available_seats] -= group[:people]
      @groups[group[:id]] = group.merge(car_id: available_car[:id])
    else
      @groups[group[:id]] = group
    end
  end
end
