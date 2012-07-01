require "factory.rb"
require "model.rb"
require "content.rb"
require "config.rb"
require "html.rb"


#================================================
# Classes that do the actual content generation
# via templates and content holders.
#================================================


#--------------------------------------------------------------
# Template - represents templates with replaceable parameters, 
# and provides the method by which the replacements are made.
#--------------------------------------------------------------
class Template
  def initialize(text)
    @text = text
  end

  def text
    @text
  end

  # Trickiest code in the entire system!  Apply "attribute" values 
  # from the passed Hash, to matching Template content variables 
  # (which have the form #{variable_name}), resulting in resolved content.  
  def apply(attribs_hash)
    # Basically, the below finds each variable occurence, and the block supplies the
    # replacement value for that occurence from the attributes hash.  The outer gsub
    # ensures that all occurences of that variable are replaced.
    result = @text.gsub(/#\{\w+\}/){ |m|
               keyword_regexp = /#\{(\w+)\}/ # capture variable name in $1
               keyword_regexp.match(m)       # get the template symbol
               attribs_hash[$1]              # yield return replacement for the symbol (variable_name) 
                                             # from hash, for use in gsub.
             }
    result
  end 

  def to_s
    @text
  end
end


#----------------------------------------------------
# Weblog - represents the HTML document to be
# returned.
#----------------------------------------------------
class Weblog
  def initialize(criteria, store)
    @criteria = criteria
    @store = store
  end 

  def generate_content
    attrs = Hash.new
    
    # TODO:
    # Below could/should iterate over a set of dynamically accessed
    # plug-ins (of which the current set would be "core").  This
    # leads to the necessity to go to a single template file approach
    # because we'd like to load one template file, then apply
    # plugin content to it.
    
    log_entries = @store.get_all_log_entries(@criteria, Config::MAX_ENTRIES)
    entry_template = @store.get_entry_template()
    attrs.update(LogEntries.new(log_entries, entry_template).attribs)
    
    sidebar_entries = @store.get_all_sidebar_entries(@criteria)
    sidebar_template = @store.get_sidebox_template()
    attrs.update(SidebarEntries.new(sidebar_entries, sidebar_template).attribs)
    
    attrs.update(Categories.new(@criteria.normalized_expression, @store).attribs)
    attrs.update(BreadCrumbs.new(@criteria.normalized_expression).attribs)
    attrs.update(Miscellaneous.new(@criteria.normalized_expression).attribs)
        
    # apply the attributes to the templatee
    template = @store.get_body_template()
    template.apply(attrs)
  end
end

#----------------------------------------------------
# RssFeed - represents the RSS feed content to be
# returned.
#----------------------------------------------------
require "rss/0.9"
class RssFeed
  def initialize(criteria, store)
    @criteria = criteria
    @store = store
  end
  
  def generate_content
    rss = RSS::Rss.new("0.9")
    channel = make_channel
    channel.image = make_image
    
    rss.channel = channel
  
    entries = @store.get_all_log_entries(@criteria, Config::MAX_ENTRIES)
    STDERR::puts "entry count: ", entries.size.to_s
    entries.each { |entry|
      item = RSS::Rss::Channel::Item.new
      item.title = entry.title
      item.link = Config::SITE_PROTO_DOMAIN + Config::SITE_SCRIPT + entry.category + "/" + entry.id
      item.description = entry.text
      channel.items << item
    }
    rss.to_s
  end
  
  def make_channel
    channel = RSS::Rss::Channel.new
    channel.description = "Somewhat Daily Mutterings"
    category = @criteria.category.split("/").last
    if category == nil
      channel.title = channel.description
    else
      channel.title = channel.description + " : " + category
    end
    channel.link = Config::SITE_PROTO_DOMAIN + "/weblog/gemcast.rb"
    channel
  end
  
  def make_image
    image = RSS::Rss::Channel::Image.new
    image.url = Config::SITE_PROTO_DOMAIN + "/gemcast_images/header_portrait.jpg"
    image.title = "samoht.com"
    image.link = Config::SITE_PROTO_DOMAIN + "/weblog/gemcast.rb"
    image
  end
end
