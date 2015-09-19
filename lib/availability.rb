class Availability
  def initialize(db)
    @db = db
  end

  def available_between?(checkin, checkout)
    checkout = checkout.prev_day # the checkout day is not considered
    months_days = months_between(checkin, checkout).select_map(:days)
    prepare_array_of_months_days(months_days, checkin.day, checkout.day)
    available?(months_days.join)
  end

  private

  # slice begin and truncate last month
  def prepare_array_of_months_days(months_days, checkin_day, checkout_day)
    checkin_month = 0 # checkin month is always the first month in array
    checkout_month = -1 # checkout month is always the last month in array
    months_days[checkin_month] = slice_checkin_month months_days[checkin_month], checkin_day
    months_days[checkout_month] = truncate_checkout_month months_days[checkout_month], checkout_day
  end

  def available?(months_days)
    !! months_days.match(/^0+$/)
  end

  # we only need the days from checkin and up
  def slice_checkin_month(days, checkin_day)
    start_index = checkin_day - 1 # string starts at index zero
    days[start_index..-1] # slice from index till end
  end

  # we only need the days till checkout day
  def truncate_checkout_month(days, checkout_day)
    days[0...checkout_day] # 3 dots so checkout_day is not included (string starts at index zero)
  end

  # returns only the records between the dates
  def months_between(checkin, checkout)
    start  = checkin.year  * 100 + checkin.month
    finish = checkout.year * 100 + checkout.month
    table.where{year * 100 + month >= start}
         .where{year * 100 + month <= finish}
  end

  def table
    @db[:availabilities]
  end
end
