#--------------------------------------------------------------
# Criteria
# Interprets the URL to provide the criteria represented by
# that URL.
#--------------------------------------------------------------
class Criteria
  
  def initialize(path)
    if path != nil
      @path = path.chomp
    else
      @path = ""
    end
  end
  
  def post?
    @path =~ /\.html$/
  end
  
  def full_expression
    @path
  end
  
  def normalized_expression
    @path.gsub("/index.html", "").gsub("/index.rss", "")
  end
  
  def date
    date_regex = /\d{4}(\/+\d{2})?(\/+\d{2})?$/
    date_regex =~ normalized_expression
    $& == nil ? "" : $&
  end
  
  def category
    normalized_expression.sub(date, "").sub(/\/$/, "")
  end
  
  def date_matcher
    DateMatcher.new(date)
  end
  
  def flavor
    flavor = @path.split(".").last
    if flavor != "html" and flavor != "rss"
      return "html"
    else
      return flavor
    end
  end
  
  def flavor_rss?
    flavor == "rss"
  end
  
  def flavor_html?
    flavor == "html"
  end
end


class DateMatcher
  def initialize(date_string)
     @date_string = date_string.gsub("/", "") if date_string != nil # normalize date string
     @date_regexp = /^#{@date_string}/
  end
  
  def match(in_date)
    if @date_string == nil or @date_string == ""
      return true
    end
    in_date_normalized = in_date.year.to_s + 
                         in_date.month.to_s.rjust(2, "0") + 
                         in_date.day.to_s.rjust(2, "0")
    @date_regexp =~ in_date_normalized
  end
end

#------------------------------------------------
# Store - represents where we get our stuff 
# This is an "abstract class" that defines what
# a store must support in order to be pluggable
# with the rest of the system.
#------------------------------------------------
class Store
    
  # Returns an collection of log entry LogEntryData objects corresponding
  # to the passed query and maxEntries parms.
  def get_all_log_entries(query, maxEntries)
    raise "Store subclasses must implement 'get_all_log_entries'"
  end

  # Returns an collection of sidebar entry LogEntryData objects corresponding
  # to the passed query.
  def get_all_sidebar_entries(query)
    raise "Store subclasses must implement 'get_all_sidebar_entries'"
  end

  # Returns an collection of sidebar entry CategoryData objects corresponding
  # to the passed query.
  def get_all_categories()
    raise "Store subclasses must implement 'get_all_categories'"
  end

  # Returns the Template object configured for log entries.
  def get_entry_template
    raise "Store subclasses must implement 'get_entry_template'"
  end

  # Returns the Template object configured for sidebar entries.
  def get_sidebox_template
    raise "Store subclasses must implement 'get_sidebox_template'"
  end

  # Returns the Template object configured for the docment body.
  def get_body_template
    raise "Store subclasses must implement 'get_body_template'"
  end
  
end

