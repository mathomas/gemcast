#!/usr/bin/ruby
#================================================
# Classes for a file-based store
#================================================
require "config.rb"
require "store.rb"
require "model.rb"
require "find.rb"
require "date.rb"


# Insert useful filesystem stuff in Criteria class
class Criteria
  def Criteria.all(extension)
    "*" + extension
  end

  def physical_dir_or_filename
    (Config::ROOT_DATA_DIR + category).sub(Config::POST_URL_EXTENSION,
                                             Config::POST_FILE_EXTENSION)
  end
  
  def physical_dirname
    if File.file?(physical_dir_or_filename)
      File.dirname(physical_dir_or_filename)
    else
      physical_dir_or_filename
    end
  end
  
  def sidebar_file_pattern
    File.join(physical_dirname, Criteria.all(Config::SIDEBAR_FILE_EXTENSION))
  end
  
  def sidebar_default_file_pattern
    File.join(File.join(Config::ROOT_DATA_DIR, Criteria.all(Config::SIDEBAR_FILE_EXTENSION)))
  end
end


# Insert useful stuff in Dir class
class Dir
  def Dir.sidebar_entries(criteria)
    dir_listing = glob(criteria.sidebar_file_pattern)
    dir_listing = glob(criteria.sidebar_default_file_pattern) if dir_listing.empty?
    dir_listing
  end
end


# Insert useful stuff in Find module
module Find
  def Find.log_entries(criteria)
      Find.find(criteria.physical_dir_or_filename) {|file_name|  # recursively get all files
        if File.file?(file_name) and File.extname(file_name) == Config::POST_FILE_EXTENSION
          yield file_name
        end
      }
  end
  
  def Find.categories
    Find.find(Config::ROOT_DATA_DIR) { |file_name| 
      if file_name != Config::ROOT_DATA_DIR
        if File.directory? file_name
          short_dir_name = file_name.gsub(Config::ROOT_DATA_DIR + "/", "")
          # TODO: move below into Dir, above
          num_entries = Dir.glob(File.join(file_name, Criteria.all(Config::POST_FILE_EXTENSION))).size
          yield short_dir_name, num_entries
        end
      end
    }
  end
end


#--------------------------------------------------------
# EntryMaker
# A mixin for those classes that need to make LogEntry
# objects.
#--------------------------------------------------------
module EntryMaker
  def make_entry(fully_qualified_file_name)
    title="", date=nil, text=""

    File.open(fully_qualified_file_name) { |file|
      title = file.gets.chomp!  #first line is title
      text = ""
      file.each_line { |line|
        text << line 
      }
      date = File.stat(fully_qualified_file_name).mtime
    }

    category = File.dirname(fully_qualified_file_name).gsub(Config::ROOT_DATA_DIR, "")
    category.gsub!("/+", "/")
    category.gsub!("/+$", "")
    id = File.basename(fully_qualified_file_name, Config::POST_FILE_EXTENSION) + ".html"
    LogEntryData.new(id, title, text, date, category, Config::SITE_BASE_URL)
  end

  def make_404_entry
    LogEntryData.new("error.html",
                     "404 - Article Not Found", "I looked really hard, but couldn't find the specified article.  Bummer.",
                     DateTime.now, "",
                     Config::ROOT_DATA_DIR)  
  end
end



#--------------------------------------------------------
# LogEntryQuery
# A query that takes a criteria and returns LogEntry objects
# derived from the filesystem.
#--------------------------------------------------------
class LogEntryQuery
  include EntryMaker

  def execute(criteria, max_entries)
    entries = Array.new

    Find.log_entries(criteria) { |file_name|
      entries << make_entry(file_name) if criteria.date_matcher.match(File.stat(file_name).mtime)
    }
    
    entries << make_404_entry if entries.empty? and criteria.post?
    entries
  end
end


#--------------------------------------------------------
# SidebarEntryQuery
# A query that takes a criteria and returns SidebarEntryQuery
# objects derived from the filesystem.
#--------------------------------------------------------
class SidebarEntryQuery
  include EntryMaker
  
  def execute(criteria)
    entries = Array.new
    dir_listing = Dir.sidebar_entries(criteria)
    dir_listing.collect { |file_name| make_entry(file_name) }
  end
end


#------------------------------------------------
# FileStore - represents where we get our stuff 
#------------------------------------------------
class FileStore < Store
  protected
  def make_template(fully_qualified_file_name)
    text = ""
    File.open(fully_qualified_file_name) { |file|
      text = file.gets(nil)
    }
    Template.new(text)
  end

  public
  
  def get_all_log_entries(criteria, max_entries)
    entries = LogEntryQuery.new.execute(criteria, max_entries)
    entries.sort.reverse[0...max_entries]
  end

  def get_all_sidebar_entries(criteria)
    entries = SidebarEntryQuery.new.execute(criteria)
    entries.sort.reverse
  end

  def get_all_categories()
    logCategories = Array.new

    Find.categories { |path, num_entries| 
      logCategories << CategoryData.new("/" + path, num_entries)
    }
    logCategories.sort
  end

  def get_entry_template
    make_template(File.join(Config::TEMPLATE_DIR, Config::ENTRY_TEMPLATE))
  end

  def get_sidebox_template
    make_template(File.join(Config::TEMPLATE_DIR, Config::BOX_TEMPLATE))
  end

  def get_body_template
    make_template(File.join(Config::TEMPLATE_DIR, Config::BODY_TEMPLATE))
  end
end

