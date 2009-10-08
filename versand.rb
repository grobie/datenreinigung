class Versand < ActiveRecord::Base
  set_table_name "versand"
  include Cleaner
  
  def anrede
    self[:anrede] = self[:anrede].strip
    self[:anrede].blank? ? super : self[:anrede]
  end
  
  def titel
    self[:titel] = self[:titel].strip
    self[:titel].blank? ? super : self[:titel]
  end
  
end