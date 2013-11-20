if defined?(ChefSpec)
  def append_hostsfile_entry(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:hostsfile_entry, :append, resource_name)
  end

  def create_hostsfile_entry(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:hostsfile_entry, :create, resource_name)
  end

  def create_hostsfile_entry_if_missing(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:hostsfile_entry, :create_if_missing, resource_name)
  end

  def remove_hostsfile_entry(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:hostsfile_entry, :remove, resource_name)
  end

  def update_hostsfile_entry(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:hostsfile_entry, :update, resource_name)
  end
end
