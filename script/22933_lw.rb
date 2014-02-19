s = Site.find 5

["Asia and Australasia","Europe","Latin America","Middle East and Africa","North America","Offshore","UK"].each do | aa |
s.categories.create(:parent_id => 110, :name => "#{aa}", :full_name => "International >> #{aa}", :full_alias_name => "international >> #{aa.downcase.gsub(/(\s)/,'-')}", :alias_name => "#{aa.downcase.gsub(/(\s)/,'-')}")
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
["Asia and Australasia","Europe","Latin America","Middle East and Africa","North America","Offshore","UK"].each do | aa |
a = s.categories.find_by_name "#{aa}"
puts "#{a.id}---#{a.name}"
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
3009---Asia and Australasia
["Australia","Cambodia","China","Hong Kong","India","Indonesia","Japan","Kazakhstan","Laos","Malaysia","Mongolia","Myanmar","New Zealand","Pakistan","Philippines","Singapore","South Korea","Sri Lanka","Taiwan","Thailand","Uzbekistan","Vietnam"].each do |aa|
s.categories.create(:parent_id => 3830, :name => "#{aa}", :full_name => "International >> Asia and Australasia >> #{aa}", :full_alias_name => "international >> asia-and-australasia >> #{aa.downcase.gsub(/(\s)/,'-')}", :alias_name => "#{aa.downcase.gsub(/(\s)/,'-')}")
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
3010---Europe
["Azerbaijan","Belarus","Belgium","Bosnia and Herzegovina","Bulgaria","Croatia","Cyprus","Czech Republic","Denmark","Estonia","Finland","Georgia","Greece","Hungary","Iceland","Ireland","Latvia","Lithuania","Luxembourg","Moldova","Montenegro","Norway","Poland","Portugal","Republic of Macedonia","Romania","Russian Federation","Serbia","Slovakia","Slovenia","Spain","Sweden","The Netherlands","Turkey","Ukraine"].each do | aa |
s.categories.create(:parent_id => 3831, :name => "#{aa}", :full_name => "International >> Europe >> #{aa}", :full_alias_name => "international >> europe >> #{aa.downcase.gsub(/(\s)/,'-')}", :alias_name => "#{aa.downcase.gsub(/(\s)/,'-')}")
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
3011---Latin America
["Argentina","Bolivia","Brazil","Chile","Colombia","Costa Rica","Dominican Republic","Ecuador","El Salvador","Guatemala","Honduras","Jamaica","Mexico","Nicaragua","Panama","Paraguay","Peru","Puerto Rico","The Bahamas","Trinidad and Tobago","Turks & Caicos Islands","Uruguay","Venezuela"].each do |aa|
s.categories.create(:parent_id => 3834, :name => "#{aa}", :full_name => "International >> Latin America >> #{aa}", :full_alias_name => "international >> latin-america >> #{aa.downcase.gsub(/(\s)/,'-')}", :alias_name => "#{aa.downcase.gsub(/(\s)/,'-')}")
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
3012---Middle East and Africa
["Algeria","Angola","Botswana","Egypt","Ghana","Iran","Iraq","Israel","Jordan","Lebanon","Morocco","Mozambique","Nigeria","Oman","Qatar","Saudi Arabia","South Africa","Tanzania","Tunisia","Uganda","United Arab Emirates"].each do | aa|
s.categories.create(:parent_id => 3833, :name => "#{aa}", :full_name => "International >> Middle East and Africa >> #{aa}", :full_alias_name => "international >> middle-east-and-africa >> #{aa.downcase.gsub(/(\s)/,'-')}", :alias_name => "#{aa.downcase.gsub(/(\s)/,'-')}")
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
3013---North America
["Canada","USA"].each do |aa|
s.categories.create(:parent_id => 3834, :name => "#{aa}", :full_name => "International >> North America >> #{aa}", :full_alias_name => "international >> north-america >> #{aa.downcase.gsub(/(\s)/,'-')}", :alias_name => "#{aa.downcase.gsub(/(\s)/,'-')}")
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
187---Offshore
["Anguilla","Bahrain","Belize","Bermuda","British Virgin Islands","Brunei","Cayman Islands","Channel Islands-Guernsey","Channel Islands-Jersey","Gibraltar","Grenada","Isle of Man","Liechtenstein","Malta","Mauritius","Netherlands Antilles"].each do |aa|
s.categories.create(:parent_id => 3835, :name => "#{aa}", :full_name => "International >> Offshore >> #{aa}", :full_alias_name => "international >> offshore >> #{aa.downcase.gsub(/(\s)/,'-')}", :alias_name => "#{aa.downcase.gsub(/(\s)/,'-')}")
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
3015---UK
["England and Wales","Northern Ireland","Scotland"].each do |aa|
s.categories.create(:parent_id => 3836, :name => "#{aa}", :full_name => "International >> UK >> #{aa}", :full_alias_name => "international >> uk >> #{aa.downcase.gsub(/(\s)/,'-')}", :alias_name => "#{aa.downcase.gsub(/(\s)/,'-')}")
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

