# Project Definition

## Problem:

Build a small program which helps solar installers prioritize and manage installation crews, given a list of buildings that need to be have PV systems installed.

## Solution

A work schedule detailing which employee(s) work on what building for each day.

- Work schedule is 5 days: `Monday - Friday`
- Employees work full days
- All installations are done in 1 day
- Employees can be unavailable; represented as a `true/false` value in the specific day column(s)
- Buildings are allocated employees in order of their position in the `buildings.csv` files. If there are insufficient employees for a building on a certain day, the scheduler will iterate over the next days until a day is found that all needed employees are available.

## How To Run

- Inputs to the program are made in the `building.csv` and `employees.csv` files located in the _inputs_ folder

  - `building.csv`: Contains a list of buildings that need PV installation for the week. The order in the list determines the priority.
    - `id`: A unique number attributed to each building in the list.
    - `type`: What type of building this is, see [specs](#definitions-and-specifications) for information on the symbols used.
  - `employees.csv`: Contains a list of employees that are able to work on instalations.
    - `id`: A unique number attributed to each employee in the list.
    - `type`: Specifies what kind of job the employee has, see [specs](#definitions-and-specifications) for information on the symbols used.
    - `mon...fri`: Represents the days of the week that each employee is available, enter `false` if they are unable to work that day.

- Outputs of the program are created in the _outputs_ folder, timestamped
  - `work_schedule_<datetime>.csv`: The generated schedule based on the inputs provided. Each row specifies an employee that's part of a crew working on a specific building on a specific day
    - `building_id`: The ID of the building being worked on
    - `employee_id`: The ID of the employee who will be part of the crew working on the building
    - `day`: What day of the week the building will be worked on
  - Buildings that are unable to be scheduled for are instead output with `n/a` in the `employee_id` and `day` columns.
- Program is executed by running `ruby execute.rb`

## Definitions and Specifications

- Types of employees

  - Certified installers (`cert`)
  - Installers pending certification (`pcert`)
  - Laborers (`labr`)

- Types of buildings
  - Single story homes (`ssh`)
    - Requires: 1 `cert`
  - Two story homes (`tsh`)
    - Requires: 1 `cert` AND (1 `pcert` OR `labr`)
  - Commercial building (`cb`)
    - Requires: 2 `cert` AND 2 `pcert` AND 4 of any combination of (`cert`, `pcert`, `labr`)

## Notes

- Given more time I would add tests to `EmployeeScheduler` as well as add additional tests coverage to `WorkScheduler` and `DayTracker`.
- Additionally, while the scheduler does output correct solutions it is very dependant on the order of employees on the list. This causes employees further down the list to not get scheduled nearly as often as those at the top. A more intelligent way of picking employees to schedule would be to look at factors such as, how much has this employee worked this week and how long.
