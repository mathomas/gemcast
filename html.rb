class HTML
  def HTML::internal_link(caption, path)
    '<a href="' + (Config::SITE_SCRIPT + path).gsub(/\/+/, "/") + '">' + caption + "</a>"
  end 
end

