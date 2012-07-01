require "filestore.rb"

class Factory
  def Factory::for_name(className)
    ObjectSpace.each_object(Class) do |c|
      return c if c.name == className
    end
    raise "Class #{className} not found"
  end
end
