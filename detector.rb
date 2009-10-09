class Detector
  
  WINDOWSIZE = 20
  THRESHOLD = 0.3
  STEPSIZE = 10000
  
  def self.output(results, key)
    values = []
    results.sort_by { |r| r[:distance] }.each do |result|
      if Datenreinigung::Config["detector"]["save"]
        minid, maxid = result[:k1].origid > result[:k2].origid ? [result[:k2].origid, result[:k1].origid] : [result[:k1].origid, result[:k2].origid]
        values << [minid, maxid, "'#{key}'", result[:distance]].join(",")
      else
        puts "#{result[:distance]}: #{result[:k1]} ---- #{result[:k2]}"
      end
    end
    
    if Datenreinigung::Config["detector"]["save"] && !values.empty?
      insert = Datenreinigung::Config["database"]["adapter"] == "mysql" ? "INSERT INTO matches (kunde1_id,kunde2_id,`key`,distance) VALUES" : "INSERT INTO matches (kunde1_id,kunde2_id,key,distance) VALUES"
      ActiveRecord::Base.connection.execute("#{insert} (#{values.join('),(')} )")
    end
  end
  
  def self.process
    count = Kunde.count
    steps = (count / STEPSIZE) + 1
    
    Datenreinigung::Config["detector"]["keys"].each do |key|
      puts "Search by #{key}"
      
      (0..steps).each do |step|
        retrieve = Time.now
        kunden = Kunde.all(:conditions => "kunden_keys.keyname = '#{key}'", :joins => :key, :order => 'value ASC', :offset => [step*STEPSIZE - WINDOWSIZE, 0].max, :limit => STEPSIZE)
        
        next if kunden.empty?
        
        detect = Time.now
        result = []
        kunden.each_with_index do |kunde, i|
          (0..([i, WINDOWSIZE].min-1)).each do |k|
            other = kunden[i-k-1]
            distance = kunde.distance_to(other)
            result << {:distance => distance, :k1 => kunde, :k2 => other} if distance < THRESHOLD
          end
        end
        
        insert = Time.now
        output(result, key)
        
        finish = Time.now
        puts "  #{("%0"+steps.to_s.size.to_s+"d") % (step+1)}: processed #{kunden.size} objects and found #{result.size} duplicates in #{time_format(finish-retrieve)} minutes (select: #{time_format(detect-retrieve)}, detect: #{time_format(insert-detect)}, insert: #{time_format(finish-insert)})"
      end
    end
  end
  
  def self.time_format(seconds)
    "#{(seconds / 60).to_i}:#{"%.1f" % (seconds % 60)}"
  end
  
end