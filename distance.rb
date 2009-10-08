require 'amatch'
require 'unicode'

module Distance
  include Amatch
  
  def self.edit_distance(s1, s2)
    s1,s2 = s1.to_s.downcase,s2.to_s.downcase
    Levenshtein.new(s1).match(s2).to_f / [s1.size, s2.size].max
  end
  
  def self.edit_distance_initial(s1, s2)
    s1,s2 = Unicode.downcase(s1), Unicode.downcase(s2)
    if s1 =~ /^[a-zäöüÄÖÜ]\.*/u || s2 =~ /^[a-zäöüÄÖÜ]\.*/u
      i1 = s1 =~ /^[äöüÄÖÜ]/u ? s1[0,2] : s1[0,1]
      i2 = s2 =~ /^[äöüÄÖÜ]/u ? s2[0,2] : s2[0,1]
      i1 == i2 ? 0 : 1
    else
      edit_distance(s1,s2)
    end
  end
  
end