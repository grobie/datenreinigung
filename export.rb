# dependencies
require "rubygems"
require "activerecord"

require "cleaner"
require "kunde"
require "versand"
require "marketing"
require "webshop"
require "key"
require "match"


ActiveRecord::Base.establish_connection(Datenreinigung::Config['database']["postgresql"].merge(:adapter => "postgresql"))

classes = [Kunde, Marketing, Versand, Webshop, Key, Match]
classes.each do |klass|
  klass.table_name
  klass.columns
end

ActiveRecord::Base.establish_connection(Datenreinigung::Config['database']["mysql"].merge(:adapter => "mysql"))

classes.each do |klass|
  # drop table
  ActiveRecord::Migration.drop_table klass.table_name rescue ActiveRecord::StatementInvalid
  # create table
  ActiveRecord::Migration.create_table klass.table_name, :options => 'engine=MyISAM DEFAULT CHARSET=utf8' do |table|
    klass.columns.each do |column|
      next if column.name == "id"
      table.column column.name, column.sql_type == 'bigint' ? column.sql_type : column.type
    end
  end
end