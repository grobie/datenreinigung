module Cleaner
  
  def id
    self[:id].to_i
  end
  
  def anrede
    process_name unless @processed_name
    @anrede
  end
  
  def titel
    process_name unless @processed_name
    @titel
  end
  
  def vorname
    process_name unless @processed_name
    @vorname
  end
  
  def mittelname
    process_name unless @processed_name
    @mittelname
  end
  
  def nachname
    process_name unless @processed_name
    @nachname
  end
  
  def strasse
    unless self[:strasse].blank?
      @strasse = self[:strasse].strip
      case self[:strasse]
      when /Postfach (\d+)/
        @strasse = nil
        @postfach = $1
      when /(.*?) *(\d+[a-zA-Z]*)/
        @strasse = $1
        self[:hausnummer] = $2
      end
      @strasse = @strasse.sub(/ Str.$/, 'str.') unless @strasse.blank?
      @strasse
    end
  end
  
  def hausnummervon
    process_hausnummer unless @processed_hausnummer
    @hausnummervon
  end
  
  def hausnummerbis
    process_hausnummer unless @processed_hausnummer
    @hausnummerbis
  end
  
  def postleitzahl
    unless self[:postleitzahl].blank?
      self[:postleitzahl].sub("D-", "")
    end
  end
  
  def postfach
    result = @postfach || self[:postfach]
    result.blank? || result == 0 ? nil : result.to_s.gsub(/[^0-9]/, '').to_i
  end
  
  def ort
    process_ort unless @processed_ort
    @ort
  end
  
  def ortzusatz
    process_ort unless @processed_ort
    @ortzusatz
  end
  
  def vorwahl
    parse_telefon unless @parsed_telefon
    @vorwahl
  end
  
  def telefonnummer
    parse_telefon unless @parsed_telefon
    @telefonnummer
  end
  
  def geburtsdatum
    date = nil
    
    unless self[:geburtsdatum].blank?
      case self[:geburtsdatum]
      when /(\d{2})\.(\d{2})\.(\d{4})/
        day = $1.to_i
        month = $2.to_i
        year = $3.to_i
      when /(\d{4})(\d{2})(\d{2})/
        day = $3.to_i
        month = $2.to_i
        year = $1.to_i
      when /(\d{2})\/(\d{2})\/(\d{2})/
        day = $1.to_i
        month = $2.to_i
        year = "19#{$3}".to_i
      end
      
      if month > 12
        day, month = month, day
      end
      
      # create date objects
      tries = 0
      begin
        date = Date.parse("#{year}-#{month}-#{day}")
      rescue ArgumentError
        if tries < 1 
          tries += 1
          # correct days
          if day > 31 || (month == 2 && day > 28) || (month % 2 == 0 && day > 30)
            day -= 1
          end
          retry
        end
        date = nil
      end
      
      # correct dates in the future
      date -= 100.years if date && date > Date.today
    end
    
    date
  end
  
  private
  
  def parse_telefon
    unless  self[:telefon].blank?        
      tel = self[:telefon].strip.gsub(/\+49|\(|\)/, '')
      if tel =~ /\d+(\.|\/)\d+(\.|\/)\d+/
        self.geburtsdatum = self.telefon
        self[:telefon] = nil
      else
        parts = tel.split("/")
        if parts.size == 2
          @vorwahl = parts[0]
          @telefonnummer = parts[1].to_i
        else
          @telefonnummer = parts.join.to_i
        end
      end
    end
    @telefonnummer = nil if @telefonnummer == 0
    @parsed_telefon = true
  end
  
  def process_name
    process_nachname
    process_vorname
    process_anrede
    process_titel
    @processed_name = true
  end
  
  def process_nachname
    @nachname = self[:nachname].strip
    @nachname = nil if @nachname.blank?
    
    if @nachname =~ /(Frau und Herr|Herr und Frau|Herr|Frau)($| )(.*)/
      @anrede = $1
      @nachname = $3
    end
    if @nachname =~ /(Dipl\. Ing\.|Dr\.|Prof\.|Dr\. Prof\.|Prof\. Dr\.)* *(.*)/
      @titel = $1
      @nachname = $2
    end
    
    @nachname = @nachname.gsub(/  +/, ' ') unless @nachname.blank?
  end
  
  def process_vorname
    @vorname = self[:vorname].strip
    @vorname = nil if @vorname.blank?
    
    if @vorname =~ /(Frau und Herr|Herr und Frau|Herr|Frau)($| )(.*)/
      @anrede = $1
      @vorname = $3
    end
    if @vorname =~ /(Dipl\. Ing\.|Dr\.|Prof\.|Dr\. Prof\.|Prof\. Dr\.)* *(.*)/
      @titel = $1
      @vorname = $2
    end
    
    unless @vorname.nil? || @anrede == "Herr und Frau"
      parts = @vorname.split(" ")
      if parts.size > 1 && !%w(und u. +).include?(parts[1])
        @vorname = parts.shift
        @mittelname = parts.join(" ")
      end
    end
    
    # rechange first chars
    if !@vorname.blank? && @vorname =~ /([a-zäöü])([A-ZÄÖÜ])(.*)/u
      @vorname = $2+$1+$3
    end
  end
  
  def process_hausnummer
    unless self[:hausnummer].blank?
      self[:hausnummer] = self[:hausnummer].strip.upcase
      parts = self[:hausnummer].split('-')
      if parts.size == 2
        @hausnummervon = parts[0]
        @hausnummerbis = parts[1] =~ /^[A-Z]+$/ ? "#{parts[0].to_i}#{parts[1]}" : parts[1]
      else
        @hausnummervon = self[:hausnummer]
        @hausnummerbis = self[:hausnummer]
      end
    end
    @processed_hausnummer = true
  end
  
  def process_anrede
    @anrede
  end
  
  def process_titel
    @titel
  end
  
  def process_ort
    unless self[:ort].blank?
      self[:ort] = self[:ort].strip
      if self[:ort] =~ /(.*?) *, *(.*)/
        @ort = $1
        @ortzusatz = $2
      else
        @ort = self[:ort]
      end
    end
    @processed_ort = true
  end
  
end