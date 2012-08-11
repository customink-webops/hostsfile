class Manipulator
  def initialize
    contents = ::File.readlines(hostsfile_path)

    @entries = contents.collect do |line|
      Entry.parse(line) unless line.strip.nil? || line.strip.empty?
    end.compact
  end

  def ip_addresses
    @entries.collect do |entry|
      entry.ip_address
    end.compact || []
  end

  def add(options = {})
    @entries << Entry.new(
      :ip_address => options[:ip_address],
      :hostname => options[:hostname],
      :aliases => options[:aliases],
      :comment => options[:comment]
    )
  end

  def update(options = {})
    if entry = find_entry_by_ip_address(options[:ip_address])
      entry.hostname = options[:hostname]
      entry.aliases = options[:aliases]
      entry.comment = options[:comment]
    end
  end

  def remove(ip_address)
    if entry = find_entry_by_ip_address(ip_address)
      @entries.delete(entry)
    end
  end

  def save
    save!
  rescue
    false
  end

  def save!
    entries = []
    entries << "#"
    entries << "# This file is (partially) managed by Chef, using the hostsfile cookbook."
    entries << "# Editing this file by hand is highly discouraged!"
    entries << "# Last updated: #{::Time.now}"
    entries << "#"
    entries << ""
    entries = entries + (unique_entries.sort)

    ::File.open(hostsfile_path, 'w') do |file|
      file.write( entries.join("\n") )
    end
  end

  def find_entry_by_ip_address(ip_address)
    @entries.detect do |entry|
      !entry.ip_address.nil? && entry.ip_address == ip_address
    end
  end

  private
  # Returns the path to the hostsfile.
  # TODO: This should be updated to support multiple platforms, including
  # Windows.
  def hostsfile_path
    '/etc/hosts'
  end

  # This is a crazy way of ensuring unique objects in an array using a Hash
  def unique_entries
    Hash[*@entries.map{ |entry| [entry.ip_address, entry] }.flatten].values
  end
end
