class CarPoolingService
  attr_reader :cars, :groups

  def initialize
    @cars = {}         # Hash map car_id => { seats: int, available_seats: int }
    @groups = {}       # Hash map group_id => { people: int, car_id: int or nil }
    @mutex = Mutex.new # Mutex for thread safety
  end

  def load_cars(car_list)
    @mutex.synchronize do
      @cars.clear
      @groups.clear

      car_list.each do |car|
        seats = car[:seats].to_i
        next if seats < 4 || seats > 6

        @cars[car[:id].to_i] = { id: car[:id].to_i, seats: seats, available_seats: seats }
      end
    end
  end

  def add_group(group_id, people_count)
    @mutex.synchronize do
      return false if people_count < 1 || people_count > 6 || @groups.key?(group_id)

      group = { id: group_id, people: people_count }
      assign_group_to_car(group)
      true
    end
  end

  def dropoff_group(group_id)
    @mutex.synchronize do
      group = @groups.delete(group_id)
      if group.present?
        if group[:car_id].present?
          @cars[group[:car_id]][:available_seats] += group[:people]
          @groups.each_value { |wgroup| assign_group_to_car(wgroup) if wgroup[:car_id].nil? }
        end
        true
      else
        false
      end
    end
  end

  def locate_group(group_id)
    @mutex.synchronize do
      group = @groups[group_id]
      @cars[group[:car_id]] if group.present? && group[:car_id].present?
    end
  end

  def group_waiting?(group_id)
    @mutex.synchronize do
      @groups.key?(group_id) && @groups[group_id][:car_id].nil?
    end
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
