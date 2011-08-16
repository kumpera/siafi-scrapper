#Baixa páginas contendo o sumário de diárias por pessoa. A relação de documentos por pessoa depende de outra consulta.
#Por enquanto os valores são fixos e não existe suporte nem para continuar um download ou baixar um intervalo.

require 'open-uri'


LAST=9400
YEAR=2011
DIR="sumario_diarias"

1.upto(LAST) do |page_number|
  url = "http://www.portaltransparencia.gov.br/PortalComprasDiretasFavorecidosDiarias.asp?Ano=#{YEAR}&Pagina=#{page_number}"
  file = File.new "#{DIR}/diarias_#{page_number}.txt", "w"
  open(url).each_line do |line|
    file << line + "\n"
  end
  file.close
  print "."
  puts "" if page_number % 40 == 0
end

