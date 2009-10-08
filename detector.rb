class Detector
  
  WINDOWSIZE = 20
  THRESHOLD = 0.3
  STEPSIZE = 10000
  
  def initialize(key, save = false)
    @key = key
    @save = save
  end
  
  def output(results)
    values = []
    results.sort_by { |r| r[:distance] }.each do |result|
      if @save
        minid, maxid = result[:k1].origid > result[:k2].origid ? [result[:k2].origid, result[:k1].origid] : [result[:k1].origid, result[:k2].origid]
        values << [minid, maxid, "'#{@key}'", result[:distance]].join(",")
      else
        puts "#{result[:distance]}: #{result[:k1]} ---- #{result[:k2]}"
      end
    end
    
    if @save
      query = 'INSERT INTO matches (kunde1_id,kunde2_id,key,distance) VALUES (' + values.join('),(') + ')'
      ActiveRecord::Base.connection.execute(query)
    end
  end
  
  def process
    count = Kunde.count
    steps = (count / STEPSIZE) + 1
    
    (0..steps).each do |step|
      retrieve = Time.now
      kunden = Kunde.all(:conditions => "kunden_keys.keyname = '#{@key}'", :joins => :key, :order => 'value ASC', :offset => [step*STEPSIZE - WINDOWSIZE, 0].max, :limit => (step+1)*STEPSIZE)
      
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
      output(result)
      
      finish = Time.now
      puts "processed #{kunden.size} objects and found #{result.size} duplicates in #{time_format(finish-retrieve)} minutes (select: #{time_format(detect-retrieve)}, detect: #{time_format(insert-detect)}, insert: #{time_format(finish-insert)})"
    end
  end
  
  def time_format(seconds)
    "#{(seconds / 60).to_i}:#{"%.1f" % (seconds % 60)}"
  end
  
end