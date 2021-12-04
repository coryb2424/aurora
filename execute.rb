# frozen_string_literal: true

require_relative 'lib/work_scheduler'

WorkScheduler.schedule(buildings_csv_path: 'inputs/buildings.csv', employees_csv_path: 'inputs/employees.csv')
