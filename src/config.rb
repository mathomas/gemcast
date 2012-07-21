# This file configures gemcast.  The things you're most likely to need
# to change are at the top, and those that are most dangerous or least
# likely to need changing are at the bottom.
class Config

  # Made available as weblog_title in templates
  WEBLOG_TITLE      = "samoht.com weblog"

  SITE_PROTO_DOMAIN = "http://www.samoht.com"
  SITE_SCRIPT       = "/gemcast/gemcast.rb"
  #SITE_SCRIPT       = "/~mike/cgi-bin/gemcast.rb"
  # The "base" URL of your installation, up to the gemcast.rb script name.
  SITE_BASE_URL     = SITE_PROTO_DOMAIN + SITE_SCRIPT

  # The directory where gemcast starts looking for your content.
  # It can be relative or absolute.
  #ROOT_DATA_DIR     = "./gemcast_data"
  ROOT_DATA_DIR     = "../gemcast_data"
  
  # The directory where gemcast looks for your templates.
  #TEMPLATE_DIR      = "./gemcast_data/templates"
  TEMPLATE_DIR      = "../gemcast_data/templates"

  # The maximum number of entries rendered for any given query
  MAX_ENTRIES       = 2


  # --------- Below this point are settings least likely to change -----------
  # The file name(s) of your templates.
  ENTRY_TEMPLATE    = "entry"
  BOX_TEMPLATE      = "box"
  BODY_TEMPLATE     = "body"

  POST_URL_EXTENSION     = ".html"
  RSS_URL_EXTENSION     = ".html"
  POST_FILE_EXTENSION    = ".txt"
  SIDEBAR_FILE_EXTENSION = ".box"

  # Determines what type of storage system your gemcast install uses.
  # Currently, the only one that is available is FileModel, so don't
  # change this.
  STORE_CLASS       = "FileStore"

end
