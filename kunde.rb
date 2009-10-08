class Kunde < ActiveRecord::Base
  set_table_name "kunden"
  has_one :key, :foreign_key => 'kunden_id'
  
  def telefon
    "#{self.vorwahl}#{self.telefonnummer}"
  end
  
  def hausnummer
    self.hausnummervon
  end
  
  def to_s
    # "#{vorname} #{nachname} #{strasse} #{ort} #{geburtsdatum.to_s}"
    "#{vorname} #{nachname}, #{strasse} #{hausnummer}, #{postleitzahl} #{ort}" 
  end
  
  def distance_to(other)
    distance = 0
    weights = 0
    [:vorname, :nachname, :strasse, :ort, :postleitzahl, :postfach, :telefonnummer, :geburtsdatum].each do |criterion|
      weight = Kunde.send("weight_#{criterion}", self, other)
      if weight > 0
        weights += weight
        distance += Kunde.send("distance_#{criterion}", self, other) * weight
      end
    end
    
    weights == 0 ? 1 : distance / weights
  end
  
  ### Weights ###
  
  def self.weight_vorname(k1, k2)
    k1.vorname && k2.vorname ? 5 : 0
  end
  
  def self.weight_nachname(k1, k2)
    k1.nachname && k2.nachname ? 10 : 0
  end
  
  def self.weight_strasse(k1, k2)
    k1.strasse && k2.strasse ? 5 : 0
  end
  
  def self.weight_hausnummer(k1, k2)
    k1.hausnummer && k2.hausnummer ? 3 : 0
  end
  
  def self.weight_ort(k1, k2)
    k1.ort && k2.ort ? 5 : 0
  end
  
  def self.weight_postleitzahl(k1, k2)
    k1.postleitzahl && k2.postleitzahl ? 3 : 0
  end
  
  def self.weight_postfach(k1, k2)
    k1.postfach && k2.postfach ? 3 : 0
  end
  
  def self.weight_telefonnummer(k1, k2)
    k1.telefonnummer && k2.telefonnummer ? 3 : 0
  end
  
  def self.weight_geburtsdatum(k1, k2)
    k1.geburtsdatum && k2.geburtsdatum ? 3 : 0
  end
  
  #### Distances ####
  
  def self.distance_vorname(k1, k2)
    Distance.edit_distance_initial(k1.vorname, k2.vorname)
  end
  
  def self.distance_nachname(k1, k2)
    Distance.edit_distance(k1.nachname, k2.nachname)
  end
  
  def self.distance_strasse(k1, k2)
    Distance.edit_distance(k1.strasse, k2.strasse)
  end
  
  def self.distance_hausnummer(k1, k2)
    if k1.hausnummer == k2.hausnummer || k1.hausnummervon.to_i == k2.hausnummerbis.to_i || k1.hausnummerbis.to_i == k2.hausnummervon.to_i
      0
    else
      1
    end
  end
  
  def self.distance_ort(k1, k2)
    Distance.edit_distance(k1.ort, k2.ort)
  end
  
  def self.distance_postleitzahl(k1, k2)
    if k1.postleitzahl == k2.postleitzahl
      0
    elsif k1.postleitzahl.size == k2.postleitzahl.size && k1.postleitzahl.size == 5
      Distance.edit_distance(k1.postleitzahl, k2.postleitzahl)
    else
      min = [k1.postleitzahl.size, k2.postleitzahl.size].min
      k1.postleitzahl[0,min] == k2.postleitzahl[0,min] ? 0.3 : 1
    end
  end
  
  def self.distance_postfach(k1, k2)
    if k1.postfach == k2.postfach
      0
    elsif k1.postfach.size == k2.postfach.size && k1.postfach.size > 2
      Distance.edit_distance(k1.postfach, k2.postfach)
    else
      min = [k1.postfach.size, k2.postfach.size].min
      k1.postfach[0,min] == k2.postfach[0,min] ? 0.3 : 1
    end
  end
  
  def self.distance_telefonnummer(k1, k2)
    if k1.telefon == k2.telefon || k1.telefonnummer == k2.telefonnummer
      0
    else
      Distance.edit_distance(k1.telefon, k2.telefon)
    end
  end
  
  def self.distance_geburtsdatum(k1, k2)
    if k1.geburtsdatum == k2.geburtsdatum
      0
    else
      day = k1.geburtsdatum.day == k2.geburtsdatum.day ? 1 : 0
      month = k1.geburtsdatum.month == k2.geburtsdatum.month ? 2 : 0
      year = k1.geburtsdatum.year == k2.geburtsdatum.year ? 4 : 0
      sum = day + month + year
      case sum
      when 6 then 0.2
      when 5 then 0.3
      when 4 then 0.6
      when 3 then 0.3
      when 2 then 0.8
      when 1 then 0.8
      when 0 then 1
      end
    end
  end
  
end