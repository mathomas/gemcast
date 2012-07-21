# The "Model" is composed of simple data holders derived from whatever data source we 
# choose to use (currently the filesystem).  These data holders are wrapped/adapted by
# "content" classes in the engine module.  The exception is Template,
# which is used directly by the engine module.

#------------------------------------------------
# LogEntryData - data representing a weblog entry.
#------------------------------------------------
class LogEntryData 
  include Comparable

  attr_reader :id, :title, :text, :date, :category, :base_url

  def initialize(id, title, text, date, category, base_url)
    @id, @title, @text, @date, @category, @base_url = id, title, text, date, category, base_url
  end

  def <=>(other)
    date <=> other.date
  end

end


#----------------------------------------------------
# CategoryData - data representing a category
#----------------------------------------------------
class CategoryData

  attr_reader :file_name, :num_entries

  def initialize(file_name, num_entries)
    @file_name, @num_entries = file_name, num_entries
  end

  def display_name
    @file_name.gsub("_"," ")
  end 

  def <=>(other)
    display_name <=> other.display_name
  end

end


