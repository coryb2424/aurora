# frozen_string_literal: true

require 'csv'
require 'pry'
require_relative 'day_tracker'
require_relative 'employee_schedule'

class WorkScheduler
  def self.schedule(buildings_csv_path:, employees_csv_path:)
    buildings_csv = CSV.open(buildings_csv_path, headers: true)
    employees_csv = CSV.open(employees_csv_path, headers: true)
    work_schedule_csv = initialize_work_schedule_csv

    new(buildings_csv, employees_csv, work_schedule_csv).schedule
    work_schedule_csv.close
  end

  def initialize(buildings_csv, employees_csv, work_schedule_csv)
    @buildings = buildings_csv
    @crew = []
    @work_schedule_csv = work_schedule_csv

    @day_tracker = DayTracker.new
    @employees_schedule = EmployeeSchedule.new(employees_csv)
  end

  def schedule
    @buildings.each do |building|
      case building['type']
      when 'ssh'
        schedule_crew_for_ssh
      when 'tsh'
        schedule_crew_for_tsh
      when 'cb'
        schedule_crew_for_cb
      end

      save_crew_to_work_schedule(building_id: building['id'])
      @day_tracker.reset
      @crew = []
    end
  end

  private_class_method def self.initialize_work_schedule_csv
    timestamp = Time.now.strftime "%Y-%m-%d_%H:%M%z"
    csv = CSV.open("outputs/work_schedule_#{timestamp}.csv", 'w', headers: true)
    csv << %w[building_id employee_id day]
    csv
  end

  private def schedule_crew_for_ssh
    while @day_tracker.day != 'n/a'
      if @employees_schedule.employees_available_to_work?(day: @day_tracker.day, employee_type: 'cert')
        @crew += @employees_schedule.schedule_employees(day: @day_tracker.day, employee_type: 'cert')
        break
      end

      @day_tracker.next
    end
  end

  private def schedule_crew_for_tsh
    while @day_tracker.day != 'n/a'
      if @employees_schedule.employees_available_to_work?(day: @day_tracker.day, employee_type: 'cert') && @employees_schedule.employees_available_to_work?(day: @day_tracker.day, employee_type: 'pcert')
        @crew += @employees_schedule.schedule_employees(day: @day_tracker.day, employee_type: 'cert')
        @crew += @employees_schedule.schedule_employees(day: @day_tracker.day, employee_type: 'pcert')
        break
      elsif @employees_schedule.employees_available_to_work?(day: @day_tracker.day, employee_type: 'cert') && @employees_schedule.employees_available_to_work?(day: @day_tracker.day, employee_type: 'labr')
        @crew += @employees_schedule.schedule_employees(day: @day_tracker.day, employee_type: 'cert')
        @crew += @employees_schedule.schedule_employees(day: @day_tracker.day, employee_type: 'labr')
        break
      end

      @day_tracker.next
    end
  end

  private def schedule_crew_for_cb
    temp_employees = @employees_schedule.schedule
    while @day_tracker.day != 'n/a'
      if @employees_schedule.employees_available_to_work?(amount: 2, day: @day_tracker.day, employee_type: 'cert') && @employees_schedule.employees_available_to_work?(amount: 2, day: @day_tracker.day, employee_type: 'pcert')
        @crew += @employees_schedule.schedule_employees(amount: 2, day: @day_tracker.day, employee_type: 'cert')
        @crew += @employees_schedule.schedule_employees(amount: 2, day: @day_tracker.day, employee_type: 'pcert')
      else
        @day_tracker.next
        next
      end

      if @employees_schedule.employees_available_to_work?(day: @day_tracker.day, amount: 4)
        @crew += @employees_schedule.schedule_employees(amount: 4, day: @day_tracker.day)
        break
      else
        @day_tracker.next
        @employees_schedule.schedule = temp_employees
        @crew = []
      end
    end
  end

  private def save_crew_to_work_schedule(building_id:)
    @crew.each do |employee_id|
      @work_schedule_csv << [building_id, employee_id, @day_tracker.day]
    end
    @work_schedule_csv << [building_id, 'n/a', 'n/a'] if @crew.empty?
  end
end
