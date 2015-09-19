db = Sequel.sqlite
db.create_table :availabilities do
  primary_key :id
  int :year
  int :month
  String :days
end

# When renting out accommodations one has to take care of the fact that
# they might not always be available. We have prepared a simple database
# schema to model this. One row in the database represents one month,
# the days of the month are encoded into a string. In this string, a "0"
# stands for "available" and a "1" for "not available". The first
# character is the first of the month. Your task is to implement a way
# of querying for the availability for a given check-in and check-out
# date. Note that it's totally fine for a guest to check in on the day
# another guest checks out. Therefore check-out dates are not marked as
# "not available" in the days string. Also, it's ok to check out on a
# day that's marked as "not available", which would be the day another
# guest is going to check in. When there's no entry in the database for
# a given month the accommodation is available for that time period.

describe Availability do
  before(:all) do
    db[:availabilities].insert(
      year: 2015, month: 1,
      #      1234567890123456789012345678901
      days: "1111111000000000000000000000000")
    db[:availabilities].insert(
      year: 2015, month: 6,
      #      123456789012345678901234567890
      days: "000000000000000000001111111100")
    db[:availabilities].insert(
      year: 2015, month: 7,
      #      1234567890123456789012345678901
      days: "0000111111100000100000000000000")
    db[:availabilities].insert(
      year: 2015, month: 12,
      #      1234567890123456789012345678901
      days: "0000000000000000000111100000000")
    db[:availabilities].insert(
      year: 2016, month: 1,
      #      1234567890123456789012345678901
      days: "0000000000000000000000000000000")
    db[:availabilities].insert(
      year: 2016, month: 2,
      #      1234567890123456789012345678901
      days: "0000000000000001000000000000000")
    db[:availabilities].insert(
      year: 2016, month: 3,
      #      1234567890123456789012345678901
      days: "0000000011111111111111111111111")
  end

  subject(:availability) { described_class.new(db) }

  describe "#available_between?" do
    it {
      is_expected.to(
        be_available_between(
          Date.new(2015, 6, 29),
          Date.new(2015, 7, 5)))
    }

    # checkin is blocked
    it {
      is_expected.to_not(
        be_available_between(
          Date.new(2015, 6, 28),
          Date.new(2015, 7, 5)))
    }

    # checkout is blocked
    it {
      is_expected.to_not(
        be_available_between(
          Date.new(2015, 6, 29),
          Date.new(2015, 7, 6)))
    }

    # blocked as 2015-07-17 is taken
    it('', focus: true) {
      is_expected.to_not(
        be_available_between(
          Date.new(2015, 7, 15),
          Date.new(2015, 7, 19)))
    }

    # rolls over to new year
    it {
      is_expected.to(
        be_available_between(
          Date.new(2015, 12, 24),
          Date.new(2016, 1, 2)))
    }

    # checkin is blocked
    it {
      is_expected.to_not(
        be_available_between(
          Date.new(2015, 12, 22),
          Date.new(2016, 1, 2)))
    }

    it {
      is_expected.to(
        be_available_between(
          Date.new(2015, 12, 26),
          Date.new(2016, 2, 2)))
    }

    # blocked by 2016-02-16
    it {
      is_expected.to_not(
        be_available_between(
          Date.new(2016, 1, 27),
          Date.new(2016, 3, 5)))
    }

    # takes year between checkin and checkout into account
    it {
      is_expected.to_not(
        be_available_between(
          Date.new(2014, 11, 15),
          Date.new(2017, 1, 15)))
    }

    # no DB entry for 2015-08, considered to be all available
    it {
      is_expected.to(
        be_available_between(
          Date.new(2015, 7, 18),
          Date.new(2015, 8, 2)))
    }

    # checkin is blocked
    it {
      is_expected.to_not(
        be_available_between(
          Date.new(2015, 7, 17),
          Date.new(2015, 8, 2)))
    }
  end

  # 2015: 1 6 7 12 1 2 3
  describe '#months_between', :private do
    def months_between(checkin, checkout, count)
      result = subject.months_between(checkin, checkout)
      expect(result.count).to eq(count)
    end

    it { months_between(Date.new(2015, 1, 1), Date.new(2015, 12, 2), 4) }
    it { months_between(Date.new(2015, 12, 1), Date.new(2016, 1, 2), 2) }
    it { months_between(Date.new(2014, 1, 1), Date.new(2017, 1, 2), 7) }
  end

  describe '#slice_checkin_month', :private do
    it {
      expect(subject.slice_checkin_month('12345', 4)).to eq('45')
    }
  end

  describe '#truncate_checkout_month', :private do
    it {
      expect(subject.truncate_checkout_month('12345', 4)).to eq('1234')
    }
  end

  describe '#prepare_array_of_months_days', :private do
    it {
      array_of_months = %w(123 4 567)
      subject.prepare_array_of_months_days(array_of_months, 3, 1)
      expect(array_of_months).to eq(%w(3 4 5))
    }
  end

  describe '#available?', :private do
    it 'should match the whole string, no part of it' do
      expect( subject.available?('1001') ).to be false
    end
  end
end
