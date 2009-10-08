require 'amatch'

module Distance
  include Amatch
  
  def self.edit_distance(s1, s2)
    s1,s2 = s1.to_s.downcase,s2.to_s.downcase
    Levenshtein.new(s1).match(s2).to_f / [s1.size, s2.size].max
  end
  
  def self.edit_distance_initial(s1, s2)
    s1,s2 = s1.downcase, s2.downcase
    if s1 =~ /^[a-zäöüÄÖÜ]\./ || s2 =~ /^[a-zäöüÄÖÜ]\./
      i1 = s1 =~ /^[äöüÄÖÜ]/ ? s1[0,2] : s1[0,1]
      i2 = s2 =~ /^[äöüÄÖÜ]/ ? s2[0,2] : s2[0,1]
      i1 == i2 ? 0 : 1
    else
      edit_distance(s1,s2)
    end
  end
  
end
