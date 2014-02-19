class DupSites
def self.site
tags =[66057]
greatethentag = 74578
for tag_id in tags
  puts "#{tag_id}"
   (Tag.find "#{tag_id}").site_ids.collect do |site_id|
    puts "#{(Tag.find(tag_id)).site_ids.count}"
    site_tag = Tag.find(greatethentag)
 if not site_tag.site_ids.include?(site_id)
     site_id =Site.find(site_id)
    ActiveRecord::Base.connection.execute("UPDATE sites_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and data_proxy_id = #{site_id.data_proxy_id}")
    else
 site_id =Site.find(site_id)
       ActiveRecord::Base.connection.execute("delete from sites_tags where data_proxy_id = '#{site_id.data_proxy_id}' and tag_id = '#{tag_id}'")
    end
  end
end
end

def self.site1
tags =[67644]
greatethentag = 65922
for tag_id in tags
  puts "#{tag_id}"
   (Tag.find "#{tag_id}").site_ids.collect do |site_id|
    puts "#{(Tag.find(tag_id)).site_ids.count}"
    site_tag = Tag.find(greatethentag)
 if not site_tag.site_ids.include?(site_id)
     site_id =Site.find(site_id)
     ActiveRecord::Base.connection.execute("UPDATE sites_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and data_proxy_id = #{site_id.data_proxy_id}")
    else
 site_id =Site.find(site_id)
       ActiveRecord::Base.connection.execute("delete from sites_tags where data_proxy_id = '#{site_id.data_proxy_id}' and tag_id = '#{tag_id}'")

    end
  end
end
end


def self.site2
tags =[74293]
greatethentag = 74378
for tag_id in tags
  puts "#{tag_id}"
   (Tag.find "#{tag_id}").site_ids.collect do |site_id|
    puts "#{(Tag.find(tag_id)).site_ids.count}"
    site_tag = Tag.find(greatethentag)
 if not site_tag.site_ids.include?(site_id)
     site_id =Site.find(site_id)
     ActiveRecord::Base.connection.execute("UPDATE sites_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and data_proxy_id = #{site_id.data_proxy_id}")
    else
 site_id =Site.find(site_id)
       ActiveRecord::Base.connection.execute("delete from sites_tags where data_proxy_id = '#{site_id.data_proxy_id}' and tag_id = '#{tag_id}'")

    end
  end
end
end

def self.site3
tags =[28579]
greatethentag = 12727
for tag_id in tags
  puts "#{tag_id}"
   (Tag.find "#{tag_id}").site_ids.collect do |site_id|
    puts "#{(Tag.find(tag_id)).site_ids.count}"
    site_tag = Tag.find(greatethentag)
 if not site_tag.site_ids.include?(site_id)
     site_id =Site.find(site_id)
     ActiveRecord::Base.connection.execute("UPDATE sites_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and data_proxy_id = #{site_id.data_proxy_id}")
    else
 site_id =Site.find(site_id)
       ActiveRecord::Base.connection.execute("delete from sites_tags where data_proxy_id = '#{site_id.data_proxy_id}' and tag_id = '#{tag_id}'")

    end
  end
end
end

def self.site4
tags =[74338]
greatethentag = 69347
for tag_id in tags
  puts "#{tag_id}"
   (Tag.find "#{tag_id}").site_ids.collect do |site_id|
    puts "#{(Tag.find(tag_id)).site_ids.count}"
    site_tag = Tag.find(greatethentag)
 if not site_tag.site_ids.include?(site_id)
     site_id =Site.find(site_id)
     ActiveRecord::Base.connection.execute("UPDATE sites_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and data_proxy_id = #{site_id.data_proxy_id}")
    else
 site_id =Site.find(site_id)
       ActiveRecord::Base.connection.execute("delete from sites_tags where data_proxy_id = '#{site_id.data_proxy_id}' and tag_id = '#{tag_id}'")

    end
  end
end
end

def self.site5
tags =[74303]
greatethentag = 74415
for tag_id in tags
  puts "#{tag_id}"
   (Tag.find "#{tag_id}").site_ids.collect do |site_id|
    puts "#{(Tag.find(tag_id)).site_ids.count}"
    site_tag = Tag.find(greatethentag)
 if not site_tag.site_ids.include?(site_id)
     site_id =Site.find(site_id)
     ActiveRecord::Base.connection.execute("UPDATE sites_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and data_proxy_id = #{site_id.data_proxy_id}")
    else
 site_id =Site.find(site_id)
       ActiveRecord::Base.connection.execute("delete from sites_tags where data_proxy_id = '#{site_id.data_proxy_id}' and tag_id = '#{tag_id}'")

    end
  end
end
end


def self.site6
tags =[55986]
greatethentag = 55985
for tag_id in tags
  puts "#{tag_id}"
   (Tag.find "#{tag_id}").site_ids.collect do |site_id|
    puts "#{(Tag.find(tag_id)).site_ids.count}"
    site_tag = Tag.find(greatethentag)
 if not site_tag.site_ids.include?(site_id)
     site_id =Site.find(site_id)
     ActiveRecord::Base.connection.execute("UPDATE sites_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and data_proxy_id = #{site_id.data_proxy_id}")
    else
 site_id =Site.find(site_id)
       ActiveRecord::Base.connection.execute("delete from sites_tags where data_proxy_id = '#{site_id.data_proxy_id}' and tag_id = '#{tag_id}'")

    end
  end
end
end




def self.site7
tags =[74271]
greatethentag = 74409
for tag_id in tags
  puts "#{tag_id}"
   (Tag.find "#{tag_id}").site_ids.collect do |site_id|
    puts "#{(Tag.find(tag_id)).site_ids.count}"
    site_tag = Tag.find(greatethentag)
 if not site_tag.site_ids.include?(site_id)
     site_id =Site.find(site_id)
     ActiveRecord::Base.connection.execute("UPDATE sites_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and data_proxy_id = #{site_id.data_proxy_id}")
    else
 site_id =Site.find(site_id)
       ActiveRecord::Base.connection.execute("delete from sites_tags where data_proxy_id = '#{site_id.data_proxy_id}' and tag_id = '#{tag_id}'")

    end
  end
end
end

def self.site8
tags =[65947]
greatethentag = 73856
for tag_id in tags
  puts "#{tag_id}"
   (Tag.find "#{tag_id}").site_ids.collect do |site_id|
    puts "#{(Tag.find(tag_id)).site_ids.count}"
    site_tag = Tag.find(greatethentag)
 if not site_tag.site_ids.include?(site_id)
     site_id =Site.find(site_id)
     ActiveRecord::Base.connection.execute("UPDATE sites_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and data_proxy_id = #{site_id.data_proxy_id}")
    else
 site_id =Site.find(site_id)
       ActiveRecord::Base.connection.execute("delete from sites_tags where data_proxy_id = '#{site_id.data_proxy_id}' and tag_id = '#{tag_id}'")

    end
  end
end
end








def self.art
tags = [65947]
greatethentag = 73856 
for tag_id in tags
puts "#{tag_id}"
   (Tag.find "#{tag_id}").articles.collect do |article|
debugger   
 if not (Tag.find "#{greatethentag}").article_ids.include?(article.id)
         ActiveRecord::Base.connection.execute("UPDATE articles_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and article_id = #{article.id}")
      ActiveRecord::Base.connection.execute("UPDATE article_contents_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and article_content_id = #{article.article_contents.last.id}") 
    else
      ActiveRecord::Base.connection.execute("delete from articles_tags where article_id = '#{article.id}' and tag_id = '#{tag_id}'")
     ActiveRecord::Base.connection.execute("delete from  article_contents_tags where article_id = '#{article.article_contents.last.id}' and tag_id = '#{tag_id}'")
    end
  end   
end
end










end

