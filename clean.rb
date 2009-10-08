class Clean

  def self.insert(values)
    query = 'INSERT INTO "kunden" ("origid","origtable","anrede","titel","vorname","mittelname","nachname","strasse","hausnummervon","hausnummerbis","postfach","postleitzahl","ort","ortzusatz","vorwahl","telefonnummer","geburtsdatum") VALUES (' + values.join('),(') + ")\n\n"
    ActiveRecord::Base.connection.execute(query)
  end

  def self.process
    %w(Versand).each do |klass|
      puts klass

      i = 0
      values = []

      klass.constantize.all().each do |object|
          i += 1

          attributes = [object.id, klass, object.anrede, object.titel, object.vorname, object.mittelname, object.nachname, object.strasse, object.hausnummervon, object.hausnummerbis, object.postfach, object.postleitzahl, object.ort, object.ortzusatz, object.vorwahl, object.telefonnummer, object.geburtsdatum]
          values << attributes.map do |attribute|
            case attribute.class.to_s
            when "String" then "'#{ActiveRecord::Base.connection.quote_string(attribute)}'"
            when "Date" then "'#{attribute}'"
            when "NilClass" then "null"
            else attribute
            end
          end.join(", ")

          if i % 5000 == 0
            puts "Processed #{i} tupel"
            insert(values)
            values = []
          end
      end

      insert(values) unless values.empty?
    end
  end
  
end