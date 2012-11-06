class Entry
  attr_accessor :ip_address, :hostname, :aliases, :comment, :priority

  def initialize(options = {})
    raise ':ip_address and :hostname are both required options' if options[:ip_address].nil? || options[:hostname].nil?

    @ip_address = options[:ip_address]
    @hostname = options[:hostname]
    @aliases = [options[:aliases]].flatten
    @comment = options[:comment]
    @priority = options[:priority] || calculate_priority(options[:ip_address])
  end

  class << self
    # Creates a new Hostsfile::Entry object by parsing a text line. The
    # `line` attribute will be in the following format:
    #
    #     1.2.3.4 hostname [alias[, alias[, alias]]] [# comment]
    #
    # This returns a new Entry object...
    def parse(line)
      entry_part, comment_part = line.split('#', 2).collect{ |part| part.strip.empty? ? nil : part.strip }

      # Return nil if the line is empty
      return nil if entry_part.nil?

      # Otherwise, collect all the entries and make a new Entry
      entries = entry_part.split(/\s+/).collect{ |entry| entry.strip unless entry.nil? || entry.strip.empty? }.compact
      return self.new(
        :ip_address => entries[0],
        :hostname => entries[1],
        :aliases => entries[2..-1],
        :comment => comment_part,
        :priority => calculate_priority(entries[0])
      )
    end

    private
    # Attempt to calculate the relative priority of each entry
    def calculate_priority(ip_address)
      return 80 if ip_address.between?('127.0.0.1', '127.0.0.8') # local
      return 60 if ip_address.match /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/ # ipv4
      return 20 # ipv6
    end
  end

  # Write out the entry as it appears in the hostsfile
  def to_s
    alias_string = [ aliases ].flatten.join(' ')

    unless comment.nil?
      [ pad(ip_address), hostname, alias_string, "# #{comment}" ].join(' ').strip
    else
      [ pad(ip_address), hostname, alias_string].join(' ').strip
    end
  end

  private
  # Pads the ip_address to length 15 so things are nicely in a column
  def pad(ip_address)
    ip_address + ' '*(20-ip_address.length)
  end

  # Proxy to the class method
  def calculate_priority(ip_address)
    Entry.send(:calculate_priority, ip_address)
  end
end
