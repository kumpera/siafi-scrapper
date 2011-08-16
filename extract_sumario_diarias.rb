#Processa as páginas com o sumário de diárias e faz a carga em diarias.db::diaria
#Dado que essa tabela possui dados sumarizados, apagamos ela toda fez.
#TODO descobrir como fazer bulk insert com AR.

require "rubygems"
require "hpricot"
require "active_record"

DIR="sumario_diarias"

class Diaria < ActiveRecord::Base
  
  establish_connection :adapter => 'sqlite3', :database => 'diarias.db'
  connection.create_table table_name, :force => true do |t|
    t.integer :idFavorecido
    t.string :TipoFavorecido
    t.string :numCodigoOrgao
    t.string :numCodigoUnidadeGestora
    t.string :NomeFavorecido
    t.string :orgaoSuperior
    t.string :orgao
    t.string :unidadeGestora
    t.integer :valor
  end
end

def process_url hash, url
  params = url.split("\"")[1].split("&")
  params.each do |p|
    next if not p =~ /^idFavorecido|^TipoFavorecido|^numCodigoOrgao|^numCodigoUnidadeGestora|^NomeFavorecido/
    kv = p.split "="
    hash[kv[0]] = kv[1]
  end
end

def process_file file_name
  puts file_name
  doc = Hpricot(open file_name)
  tb = doc.search("table").last
  fixed_columns = ["orgaoSuperior", "orgao", "unidadeGestora", "valor"]
  trs = tb.search("tr")
  rows = []
  trs.each_with_index do |tr, index|
    next if index == 0
    vars = {}
    i = 0
    tr.search("td").each do |td|
      if td.inner_html =~ /<a href/
        process_url vars, td.inner_html
      else
        text = td.inner_html
        text = text.delete(",").delete(".") if fixed_columns[i] == "valor"
        vars[fixed_columns[i]] = text
        i = i + 1
      end
    end
    rows << vars
  end
  rows.each do |r|
    Diaria.new(r).save
  end
end


Dir.new("#{DIR}").each do |file|
  next if file == "."
  next if file == ".."

  puts file
  begin
    process_file "#{DIR}/" + file
    puts file
  rescue
    puts "Failhou com #{file}"
  end
end

