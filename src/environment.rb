require "cgi"

class Environment
  def initialize
     @cgi=CGI.new("html4")

     path = []
     @cgiPath = @cgi.path_info
     if @cgi.path_info
       path = @cgi.path_info.split(/\//) 
       path.shift
     end

     path = path[0]
     if path == nil 
        @path = "" 
     else 
        @path = path
     end
  end

  def get_http_headers
      @cgi.header("type"=>"text/html") 
  end

  def get_query_path
    if @cgiPath == nil
       "/"
    else
       @cgiPath
    end
  end
end

class HttpPrinter
    def initialize(environment)
        @content = environment.get_http_headers
    end
    
    def write(text)
        @content << text
    end
    
    def content
        @content
    end
end
