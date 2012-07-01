class String
  # Ensures that a string containing slashes contains runs of
  # only one slash, with no slashes at the beginning or end.
  # "///foo//bar////".normalize_slashes => "foo/bar"
  def normalize_slashes
    self.gsub(/\/+/, "/").gsub(/\/*$/, "").gsub(/^\//, "")
  end
end
