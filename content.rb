#-----------------------------------------------------------------------------------
# Classes that provide content to the engine for output by wrapping model classes.
# All content classes offer an attribs() method, which returns a hash of key/value
# pairs for the content the class represents.
#-----------------------------------------------------------------------------------

class Content
    def attribs
        Hash.new
    end
end

#------------------------------------------------
# DatedEntry - represents a dated weblog entry.
#------------------------------------------------
class DatedEntry < Content
  include Comparable

  def initialize(entry_data)
    @entry_data = entry_data
  end

  def <=>(other)
    date <=> other.date
  end

  def attribs
    { "entry_id"       => @entry_data.id,
      "entry_title"    => @entry_data.title,
      "entry_text"     => @entry_data.text,
      "entry_date"     => @entry_data.date,
      "entry_category" => @entry_data.category,
      "script_root"    => Config::SITE_SCRIPT,
      "base_url"       => @entry_data.base_url
    }
  end

  def to_s
    puts title
    puts "--------------------"
    puts content
  end  
end


# ----- TODO following two classes should be refactored into one -------

class TemplatedContent < Content
  def initialize(entries, entry_template)
    @entries, @template = entries, entry_template
    @attrib_name = attrib_name
  end
  def attribs
    { @attrib_name => generate() }
  end

  def generate
    content = ""
    @entries.each { |entry|
      content << @template.apply(DatedEntry.new(entry).attribs)
    }
    content
  end
  
  def attrib_name
      raise "Store subclasses must implement 'attrib_name'"
  end
end

#------------------------------------------------
# LogEntries - a collection of log entry content
#------------------------------------------------
class LogEntries < TemplatedContent
    def attrib_name
        "log_entry_content"
    end
end


#------------------------------------------------
# SidebarEntries - a collection of sidebar content 
#------------------------------------------------
class SidebarEntries < TemplatedContent
    def attrib_name
        "sidebar_content"
    end
end


#========= The following seem too filesystem-dependent to be here - consider moving ========

#------------------------------------------------
# Categories - a collection of category 
# (subdirectory) content.
#------------------------------------------------
class Categories < Content
  def initialize(relative_path, store)
    @relative_path = relative_path
    @store = store
  end

  def attribs
    { "category_content" => collect_categories() }
  end

  def collect_categories
    category_content = "none"
    categories = @store.get_all_categories()
    if categories.size < 1
      category_content
    else
      category_content = HTML::internal_link("Top", "") << " " << HTML::internal_link("[rss]", "/" + "index.rss") << "<br>"
      categories.each { |category|
          caption = category.display_name.gsub(/(\w ?)+\//, "&nbsp;&nbsp;&nbsp;&nbsp;")
          caption.sub!(/^/, "&nbsp;&nbsp;&nbsp;&nbsp;")
          caption.sub!(/\//, "")
          category_content << HTML::internal_link(caption, category.file_name) 
          category_content << " (#{category.num_entries})" << "<br>"
      }
      category_content
    end
  end
end


#------------------------------------------------
# BreadCrumbs - lets the user know where she is
# on the site.
#------------------------------------------------
class BreadCrumbs < Content
  def initialize(relative_path)
    @relative_path = relative_path
  end

  def attribs
    {
    "breadcrumb_content" => (Config::WEBLOG_TITLE + @relative_path).gsub("/+$", "")
    }
  end
end


#------------------------------------------------
# Miscellaneous - emits values for various
# attributes.
#------------------------------------------------
class Miscellaneous < Content
  def initialize(relative_path)
    @relative_path = relative_path
  end

  def attribs
    { "weblog_title"      => Config::WEBLOG_TITLE,
      "current_day"       => Time.now.day.to_s, 
      "base_url"          => Config::SITE_BASE_URL,
      "current_mon"       => Time.now.mon.to_s, 
      "current_yr"        => Time.now.year.to_s,
      "script_root"       => Config::SITE_SCRIPT,
      "category_rss_url"  => (Config::SITE_SCRIPT + @relative_path.sub(/\/\w+\.html$/, "") + "/" + "index.rss").gsub(/\/+/, "/"),
      "relative_path"     => @relative_path }
  end
end

