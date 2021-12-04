# frozen_string_literal: true

require 'work_scheduler'
require 'csv'

describe WorkScheduler do
  subject { WorkScheduler.schedule(buildings_csv_path: buildings_csv_file_path, employees_csv_path: employees_csv_file_path) }

  let(:buildings_csv_file_path) { 'spec/support/buildings.csv' }
  let(:employees_csv_file_path) { 'spec/support/employees.csv' }
  let(:work_schedule_array) { [] }

  before(:each) do
    allow(CSV).to receive(:open).and_call_original

    timestamp = Time.now.strftime "%Y-%m-%d_%H:%M%z"
    expect(CSV).to receive(:open).with("outputs/work_schedule_#{timestamp}.csv", 'w', headers: true).and_return(work_schedule_array)
    expect(work_schedule_array).to receive(:close).and_return(nil)
  end

  after(:each) do
    File.delete(buildings_csv_file_path)
    File.delete(employees_csv_file_path)
  end

  describe 'scheduling for single story houses (ssh)' do
    describe 'when there is 1 ssh buidling' do
      before(:each) do
        CSV.open('spec/support/buildings.csv', 'wb') do |csv|
          csv << %w[id type]
          csv << %w[1 ssh]
        end
      end

      describe 'when there is 1 cert employee available' do
        before(:each) do
          CSV.open('spec/support/employees.csv', 'wb') do |csv|
            csv << %w[id type mon tue wed thur fri]
            csv << %w[1 cert false false true false false]
          end
        end

        it 'outputs to work_schedule.csv the expected work schedule' do
          subject
          expect(work_schedule_array[1]).to eq(%w[1 1 wed])
        end
      end

      describe 'when there are no employees available' do
        before(:each) do
          CSV.open('spec/support/employees.csv', 'wb') do |csv|
            csv << %w[id type mon tue wed thur fri]
            csv << %w[1 cert false false false false false]
          end
        end

        it 'outputs to work_schedule.csv the expected work schedule' do
          subject
          expect(work_schedule_array[1]).to eq(['1', 'n/a', 'n/a'])
        end
      end
    end

    describe 'when there are 2 ssh buidlings' do
      before(:each) do
        CSV.open('spec/support/buildings.csv', 'wb') do |csv|
          csv << %w[id type]
          csv << %w[1 ssh]
          csv << %w[2 ssh]
        end
      end

      describe 'when there are 2 cert employees available' do
        before(:each) do
          CSV.open('spec/support/employees.csv', 'wb') do |csv|
            csv << %w[id type mon tue wed thur fri]
            csv << %w[1 cert true false false true false]
            csv << %w[2 cert false true true false true]
          end
        end

        it 'outputs to work_schedule.csv the expected work schedule' do
          subject
          expect(work_schedule_array[1]).to eq(%w[1 1 mon])
          expect(work_schedule_array[2]).to eq(%w[2 2 tue])
        end
      end
    end
  end

  describe 'scheduling for two story houses (tsh)' do
    describe 'when there is 1 tsh building' do
      before(:each) do
        CSV.open('spec/support/buildings.csv', 'wb') do |csv|
          csv << %w[id type]
          csv << %w[1 tsh]
        end
      end

      describe 'when there are a cert and a pcert employees available' do
        before(:each) do
          CSV.open('spec/support/employees.csv', 'wb') do |csv|
            csv << %w[id type mon tue wed thur fri]
            csv << %w[1 cert true false false false false]
            csv << %w[2 pcert true false false false false]
          end
        end

        it 'outputs to work_schedule.csv the expected work schedule' do
          subject
          expect(work_schedule_array[1]).to eq(%w[1 1 mon])
          expect(work_schedule_array[2]).to eq(%w[1 2 mon])
        end
      end

      describe 'when there are a cert and a labr employees available' do
        before(:each) do
          CSV.open('spec/support/employees.csv', 'wb') do |csv|
            csv << %w[id type mon tue wed thur fri]
            csv << %w[1 cert true true true true true]
            csv << %w[2 labr false false true false false]
          end
        end

        it 'outputs to work_schedule.csv the expected work schedule' do
          subject
          expect(work_schedule_array[1]).to eq(%w[1 1 wed])
          expect(work_schedule_array[2]).to eq(%w[1 2 wed])
        end
      end

      describe 'when there are no employees available' do
        before(:each) do
          CSV.open('spec/support/employees.csv', 'wb') do |csv|
            csv << %w[id type mon tue wed thur fri]
            csv << %w[1 cert false false false false false]
            csv << %w[2 pcert true false false false false]
          end
        end

        it 'outputs to work_schedule.csv the expected work schedule' do
          subject
          expect(work_schedule_array[1]).to eq(%w[1 n/a n/a])
        end
      end
    end

    describe 'when there are 2 tsh building' do
      before(:each) do
        CSV.open('spec/support/buildings.csv', 'wb') do |csv|
          csv << %w[id type]
          csv << %w[1 tsh]
          csv << %w[2 tsh]
        end
      end

      describe 'when there are a cert and a pcert employees available' do
        before(:each) do
          CSV.open('spec/support/employees.csv', 'wb') do |csv|
            csv << %w[id type mon tue wed thur fri]
            csv << %w[1 cert true false true false false]
            csv << %w[2 pcert true false true false false]
          end
        end

        it 'outputs to work_schedule.csv the expected work schedule' do
          subject
          expect(work_schedule_array[1]).to eq(%w[1 1 mon])
          expect(work_schedule_array[2]).to eq(%w[1 2 mon])
          expect(work_schedule_array[3]).to eq(%w[2 1 wed])
          expect(work_schedule_array[4]).to eq(%w[2 2 wed])
        end
      end

      describe 'when there are a cert, pcert, and labr employees available' do
        before(:each) do
          CSV.open('spec/support/employees.csv', 'wb') do |csv|
            csv << %w[id type mon tue wed thur fri]
            csv << %w[1 cert true false true false false]
            csv << %w[2 pcert true false false false false]
            csv << %w[3 labr true false true false false]
          end
        end

        it 'outputs to work_schedule.csv the expected work schedule' do
          subject
          expect(work_schedule_array[1]).to eq(%w[1 1 mon])
          expect(work_schedule_array[2]).to eq(%w[1 2 mon])
          expect(work_schedule_array[3]).to eq(%w[2 1 wed])
          expect(work_schedule_array[4]).to eq(%w[2 3 wed])
        end
      end

      describe "when one building can't be scheduled for" do
        before(:each) do
          CSV.open('spec/support/employees.csv', 'wb') do |csv|
            csv << %w[id type mon tue wed thur fri]
            csv << %w[1 cert false false true false false]
            csv << %w[2 pcert false false true false false]
          end
        end

        it 'outputs to work_schedule.csv the expected work schedule' do
          subject
          expect(work_schedule_array[1]).to eq(%w[1 1 wed])
          expect(work_schedule_array[2]).to eq(%w[1 2 wed])
          expect(work_schedule_array[3]).to eq(%w[2 n/a n/a])
        end
      end
    end
  end

  describe 'scheduling for commercial buildings (cb)' do
    describe 'when there is 1 cb' do
      before(:each) do
        CSV.open('spec/support/buildings.csv', 'wb') do |csv|
          csv << %w[id type]
          csv << %w[1 cb]
        end
      end

      describe 'when there are employees available' do
        before(:each) do
          CSV.open('spec/support/employees.csv', 'wb') do |csv|
            csv << %w[id type mon tue wed thur fri]
            csv << %w[1 cert true true false false false]
            csv << %w[2 cert true true false false false]
            csv << %w[3 pcert true true false false false]
            csv << %w[4 pcert true true false false false]
            csv << %w[5 cert false true false false false]
            csv << %w[6 pcert false true false false false]
            csv << %w[7 labr false true false false false]
            csv << %w[8 labr false true false false false]
          end
        end

        it 'outputs to work_schedule.csv the expected work schedule' do
          subject
          expect(work_schedule_array[1]).to eq(%w[1 1 tue])
          expect(work_schedule_array[2]).to eq(%w[1 2 tue])
          expect(work_schedule_array[3]).to eq(%w[1 3 tue])
          expect(work_schedule_array[4]).to eq(%w[1 4 tue])
          expect(work_schedule_array[5]).to eq(%w[1 5 tue])
          expect(work_schedule_array[6]).to eq(%w[1 6 tue])
          expect(work_schedule_array[7]).to eq(%w[1 7 tue])
          expect(work_schedule_array[8]).to eq(%w[1 8 tue])
        end
      end
    end

    describe 'when there is 2 cb' do
      before(:each) do
        CSV.open('spec/support/buildings.csv', 'wb') do |csv|
          csv << %w[id type]
          csv << %w[1 cb]
          csv << %w[2 cb]
        end
      end

      describe 'when there are employees available' do
        before(:each) do
          CSV.open('spec/support/employees.csv', 'wb') do |csv|
            csv << %w[id type mon tue wed thur fri]
            csv << %w[1 cert true true false true false]
            csv << %w[2 cert true true false true false]
            csv << %w[3 pcert true true false true false]
            csv << %w[4 pcert true true false true false]
            csv << %w[5 cert false true false true false]
            csv << %w[6 pcert false true false true false]
            csv << %w[7 labr false true false true false]
            csv << %w[8 labr false true false true false]
          end
        end

        it 'outputs to work_schedule.csv the expected work schedule' do
          subject
          expect(work_schedule_array[1]).to eq(%w[1 1 tue])
          expect(work_schedule_array[2]).to eq(%w[1 2 tue])
          expect(work_schedule_array[3]).to eq(%w[1 3 tue])
          expect(work_schedule_array[4]).to eq(%w[1 4 tue])
          expect(work_schedule_array[5]).to eq(%w[1 5 tue])
          expect(work_schedule_array[6]).to eq(%w[1 6 tue])
          expect(work_schedule_array[7]).to eq(%w[1 7 tue])
          expect(work_schedule_array[8]).to eq(%w[1 8 tue])
          expect(work_schedule_array[9]).to eq(%w[2 1 thur])
          expect(work_schedule_array[10]).to eq(%w[2 2 thur])
          expect(work_schedule_array[11]).to eq(%w[2 3 thur])
          expect(work_schedule_array[12]).to eq(%w[2 4 thur])
          expect(work_schedule_array[13]).to eq(%w[2 5 thur])
          expect(work_schedule_array[14]).to eq(%w[2 6 thur])
          expect(work_schedule_array[15]).to eq(%w[2 7 thur])
          expect(work_schedule_array[16]).to eq(%w[2 8 thur])
        end
      end
    end
  end

  describe 'scheduling for multiple types of buildings' do
    before(:each) do
      CSV.open('spec/support/buildings.csv', 'wb') do |csv|
        csv << %w[id type]
        csv << %w[1 ssh]
        csv << %w[2 ssh]
        csv << %w[3 cb]
        csv << %w[4 tsh]
        csv << %w[5 cb]
      end
    end

    describe 'when there are employees available to service all buildings' do
      before(:each) do
        CSV.open('spec/support/employees.csv', 'wb') do |csv|
          csv << %w[id type mon tue wed thur fri]
          csv << %w[1 cert true true true true true]
          csv << %w[2 cert true true true true true]
          csv << %w[3 pcert true true true true true]
          csv << %w[4 pcert true true true true true]
          csv << %w[5 labr true true true true true]
          csv << %w[6 labr true true true true true]
          csv << %w[7 labr true true true true true]
          csv << %w[8 labr true true true true true]
        end
      end

      it 'outputs to work_schedule.csv the expected work schedule' do
        subject
        expect(work_schedule_array[1]).to eq(%w[1 1 mon])
        expect(work_schedule_array[2]).to eq(%w[2 2 mon])
        expect(work_schedule_array[3]).to eq(%w[3 1 tue])
        expect(work_schedule_array[4]).to eq(%w[3 2 tue])
        expect(work_schedule_array[5]).to eq(%w[3 3 tue])
        expect(work_schedule_array[6]).to eq(%w[3 4 tue])
        expect(work_schedule_array[7]).to eq(%w[3 5 tue])
        expect(work_schedule_array[8]).to eq(%w[3 6 tue])
        expect(work_schedule_array[9]).to eq(%w[3 7 tue])
        expect(work_schedule_array[10]).to eq(%w[3 8 tue])
        expect(work_schedule_array[11]).to eq(%w[4 1 wed])
        expect(work_schedule_array[12]).to eq(%w[4 3 wed])
        expect(work_schedule_array[13]).to eq(%w[5 1 thur])
        expect(work_schedule_array[14]).to eq(%w[5 2 thur])
        expect(work_schedule_array[15]).to eq(%w[5 3 thur])
        expect(work_schedule_array[16]).to eq(%w[5 4 thur])
        expect(work_schedule_array[17]).to eq(%w[5 5 thur])
        expect(work_schedule_array[18]).to eq(%w[5 6 thur])
        expect(work_schedule_array[19]).to eq(%w[5 7 thur])
        expect(work_schedule_array[20]).to eq(%w[5 8 thur])
      end
    end

    describe 'when there are not employees available to service all buildings' do
      before(:each) do
        CSV.open('spec/support/employees.csv', 'wb') do |csv|
          csv << %w[id type mon tue wed thur fri]
          csv << %w[1 cert true true true false false]
          csv << %w[2 cert true true true false false]
          csv << %w[3 pcert true false true false false]
          csv << %w[4 pcert true true true false false]
          csv << %w[5 labr true true true false false]
          csv << %w[6 labr true false true false false]
          csv << %w[7 labr true true true false false]
          csv << %w[8 labr true true true false false]
        end
      end

      it 'outputs to work_schedule.csv the expected work schedule' do
        subject
        expect(work_schedule_array[1]).to eq(%w[1 1 mon])
        expect(work_schedule_array[2]).to eq(%w[2 2 mon])
        expect(work_schedule_array[3]).to eq(%w[3 1 wed])
        expect(work_schedule_array[4]).to eq(%w[3 2 wed])
        expect(work_schedule_array[5]).to eq(%w[3 3 wed])
        expect(work_schedule_array[6]).to eq(%w[3 4 wed])
        expect(work_schedule_array[7]).to eq(%w[3 5 wed])
        expect(work_schedule_array[8]).to eq(%w[3 6 wed])
        expect(work_schedule_array[9]).to eq(%w[3 7 wed])
        expect(work_schedule_array[10]).to eq(%w[3 8 wed])
        expect(work_schedule_array[11]).to eq(%w[4 1 tue])
        expect(work_schedule_array[12]).to eq(%w[4 4 tue])
        expect(work_schedule_array[13]).to eq(%w[5 n/a n/a])
      end
    end
  end
end
