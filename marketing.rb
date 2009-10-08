class Marketing < ActiveRecord::Base
  set_table_name "marketing"
  include Cleaner
  
  def anrede
    self[:anrede] = self[:anrede].strip
    
    if self[:anrede] =~ /(Herr|Frau)* *(Dipl\. Ing\.|Dr\.|Prof\.|Dr\. Prof\.|Prof\. Dr\.)*/
      @anrede = $1 || @anrede
      @titel = $2 || @titel
      self[:anrede] = nil
    end
    
    @anrede || self[:anrede] || super
  end
  
end