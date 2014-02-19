class Migration # 
 def self.html_for_bi
          HtmlParsing.for_bi({:site_short_name => "inside_outside",
        :source_name => "Inside-Outside",
        :section_name => "Beautiful home",
        :tag_name  => "test",
        :category_name => "Inside Outside",
        :author_name => "rameshk",
       # :urls => ["http://feeds.feedburner.com/Homedit?format=xml"]
        :urls => ["http://feeds.feedburner.com/home-designing"]
            })
      end

    
       def self.from_html_by_rameskiotest
      Html.iotest_migration({:site_short_name => "inside_outside",
        :source_name => "inside-outside",
        :section_name => "Featured",
        :author_name => "rameshk",
        :urls => ["/home/busind/CMS/Admin/public/iotest/Concrete intentions-Tadao Ando.html"],
        :inline_asset_path=> {"Concrete-intentions-Tadao-Ando-web-images" => "/home/busind/CMS/Admin/public/iotest/Concrete-intentions-Tadao-Ando-web-images"},
        :class_for_content => "story-body",
        })
    end

       def self.html_migration_by_section
     HtmlMigration.migrate("/home/busind/CMS/Admin/public/HTML/NOV5/iodecember2010html",
       {:site_short_name => "inside_outside",
        :source_name => "inside-outside",
        :section_name => "Issue magazine",
        :author_email => "rameshk",
        :draft_flag => "false",
        :file_name => "iodecember2010html",
        :issue_volume => "true",
        :magazine_short_name => "Dec 2010",
        :issue_date => "2010-12-31 13:45:52 UTC",
        :content_format => "html",
#        :inline_asset_path=> {"Concrete-intentions-Tadao-Ando-web-images" => "/home/rameshs/InsideOuside/iotest/Concrete-intentions-Tadao-Ando-web-images"},
        })
       end

def self.html_migration_by_pervin
     HtmlMigration.migrate("/home/busind/CMS/Admin/public/HTML/Pervin/Aroundthe_world/indiansabroad",
       {:site_short_name => "inside_outside",
        :source_name => "inside-outside",
        :section_name => "Around the world",
        :author_email => "rameshk",
        :draft_flag => "true",
        :file_name => "Around the world",
        :issue_valume => "true",
       # :magazine_short_name => "May 2012",
        :content_format => "html"
#        :inline_asset_path=> {"Concrete-intentions-Tadao-Ando-web-images" => "/home/rameshs/InsideOuside/iotest/Concrete-intentions-Tadao-Ando-web-images"},
        })
       end

 


end
