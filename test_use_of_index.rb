# cria duas tabelas de dia, m^s e ano,
# uma sem indexes e outra com e
# preenche com todos os dias de 2000 até 2020 (7671 dias)
require 'sequel'

db = Sequel.mysql2(host: 'localhost', user: 'root', password: '', database: 'test')

db.create_table! :dates do
  int :year
  int :month
  int :day
end

db.create_table! :dates_index do
  int :year, index: true
  int :month, index: true
  int :day, index: true
  index [:year, :month]
  index [:year, :month, :day]
end

start = Date.new(2000, 1, 1)
finish = Date.new(2020, 12, 31)

db.transaction do
  (start..finish).each do |date|
    db[:dates].insert(year: date.year, month: date.month, day: date.day)
    db[:dates_index].insert(year: date.year, month: date.month, day: date.day)
  end
end

=begin

# query days between 2015-06 and 2016-05 (check and return 366 rows)
EXPLAIN SELECT * FROM dates_index
WHERE
  (year = 2015 AND month >= 6)
  OR
  (year > 2015 AND year < 2016)
  OR
  (year = 2016 AND month <= 5)
ORDER BY year, month;

# query days between 2015-06 and 2016-05  (check 730 rows but returns 366 rows)
EXPLAIN SELECT * FROM dates_index
WHERE
  year BETWEEN 2015 and 2016
  AND
  100 * year + month
    BETWEEN 100 * 2015 + 6
        AND 100 * 2016 + 5

ORDER BY year, month;

=end
