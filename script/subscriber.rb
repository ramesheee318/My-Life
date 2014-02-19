["ramvel14@gmail.com","ashokhbharggav@gmail.com","nalinibs60@hotmail.com","test@insideoutside.in","lmiyer@hotmail.com","adhirajkumar@ramesh.com","ashokhb@insideoutside.in","1234576@gmail.com","deva@gmail.com","jenorish987@gmail.com","jenorishssdf987@gmail.com","jenorishkingston@gmail.com","jenorish1233242453@gmail.com","jenorish@gmail.com"].each do | each_do |
@sub = Subscriber.all.collect{|aa| aa  if aa.created_at.strftime("%Y-%m-%d") == "2012-11-23"}.compact.collect{|a| a if a.email_id == "#{each_do}" }.compact.first
@author = Author.find(:first,:conditions =>["subscriber_id =? and created_at >=? and created_at<=?",@sub.id,"2012-11-23 00:00:00","2012-11-23 23:00:00"])
if !@author.blank?
  @author.author_profiles.collect{|a| a.delete}
  @author.delete
end
@sub.collect{|a| a.subscriber_property.delete}   if !@sub.subscriber_property.blank?
@sub.delete
end

=begin
____________________________________________________________--
Subscriber.all.collect{|aa| aa  if aa.created_at.strftime("%Y-%m-%d") == "2012-11-23"}.compact.find_by_

end
Subscriber.all.collect{|aa| aa  if aa.created_at.strftime("%Y-%m-%d") == "2012-11-23"}.compact.collect{|a| a.id if a.
Subscriber.all.collect{|aa| aa  if aa.created_at.strftime("%Y-%m-%d") == "2012-11-23"}.compact.collect{|a| a.id if !a.subscriber_property.blank?}

Subscriber.all.collect{|aa| aa.id  if aa.created_at.strftime("%Y-%m-%d") == "2012-11-23"}.compact.each do |a|
auth = Author.find_by_subscriber_id(a)
auth.author_profiles

end

=begin
-----------------------
 ["ashokhb@insideoutside.in", "ashokhbharggav@hotmail.com", "ashokhbharggav@hotmail.com"].each do | each_do |
@sub = Subscriber.all.collect{|aa| aa }.compact.collect{|a| a if a.email_id == "#{each_do}" }.compact.first
if !@sub.blank?
@author = Author.find(:first,:conditions =>["subscriber_id =?",@sub.id])
if !@author.blank?
  @author.author_profiles.collect{|a| a.delete}
  @author.delete
end
@sub.collect{|a| a.subscriber_property.delete}   if !@sub.subscriber_property.blank?
@sub.delete
else
@author = Author.find_by_email(each_do)
  @author.author_profiles.collect{|a| a.delete}
  @author.delete
end
end


Author.find_by_sql("select * from authors where email LIKE 'as%'").collect{|aa| aa.email}
=end

