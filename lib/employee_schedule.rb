class EmployeeSchedule
  attr_accessor :schedule

  def initialize(employees_csv)
    @employees_csv = employees_csv
    @schedule = build_employees_hash_table
  end

  def schedule_employees(amount: 1, day:, employee_type: 'all')
    if employee_type == 'all'
      all_workers = @schedule[day]['cert'] + @schedule[day]['pcert'] + @schedule[day]['labr']
      employee_ids_to_schedule = all_workers[0...amount]

      @schedule[day]['cert'] -= employee_ids_to_schedule
      @schedule[day]['pcert'] -= employee_ids_to_schedule
      @schedule[day]['labr'] -= employee_ids_to_schedule

      return employee_ids_to_schedule
    end

    return @schedule[day][employee_type].shift(amount)
  end

  def employees_available_to_work?(amount: 1, day:, employee_type: 'all')
    return total_employees_working_today(day) >= amount if employee_type == 'all'

    @schedule[day][employee_type].count >= amount
  end

  private def build_employees_hash_table
    table = initialize_employees_table
    @employees_csv.each do |employee|
      table['mon'][employee['type']] << employee['id'] if employee['mon'] == 'true'
      table['tue'][employee['type']] << employee['id'] if employee['tue'] == 'true'
      table['wed'][employee['type']] << employee['id'] if employee['wed'] == 'true'
      table['thur'][employee['type']] << employee['id'] if employee['thur'] == 'true'
      table['fri'][employee['type']] << employee['id'] if employee['fri'] == 'true'
    end
    table
  end

  private def initialize_employees_table
    {
      'mon' => {
        'cert' => [],
        'pcert' => [],
        'labr' => []
      },
      'tue' => {
        'cert' => [],
        'pcert' => [],
        'labr' => []
      },
      'wed' => {
        'cert' => [],
        'pcert' => [],
        'labr' => []
      },
      'thur' => {
        'cert' => [],
        'pcert' => [],
        'labr' => []
      },
      'fri' => {
        'cert' => [],
        'pcert' => [],
        'labr' => []
      }
    }
  end

  private def total_employees_working_today(day)
    total_employee_type_working_today(day: day, employee_type: 'cert') +
    total_employee_type_working_today(day: day, employee_type: 'pcert') +
    total_employee_type_working_today(day: day, employee_type: 'labr')
  end

  private def total_employee_type_working_today(day:, employee_type:)
    @schedule[day][employee_type].count
  end
end
