# Referências
https://gist.github.com/saulomendonca/ae2c8c7578a21f2917f9
https://gist.github.com/diegocharles/5c8eb5b556ef5a0096fe

# Descrição da Solução
Utilizaremos os seguintes dados como exemplo:

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

Para o seguinte teste:

    is_expected.to(
      be_available_between(
        Date.new(2015, 12, 26),
        Date.new(2016, 2, 2)))

A solução consiste em concatenar days de todos os meses no intervalo:        

    2015-12-26                     2016-01                        2016-02-02
    123456789012345678901234567890112345678901234567890123456789011234567890123456789012345678901
    000000000000000000011110000000000000000000000000000000000000000000000000000001000000000000000
                             ^                                    ^ dia anterior ao checkout

E verificar se contém apenas zeros no intervalo do dia do checkin até o dia do checkout -1, pois não conta conforme enunciado.