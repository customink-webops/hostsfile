class Entry
  attr_accessor :ip_address, :hostname, :aliases, :comment

  def initialize(options = {})
    raise ':ip_address and :hostname are both required options' if options[:ip_address].nil? || options[:hostname].nil?

    @ip_address = options[:ip_address]
    @hostname = options[:hostname]
    @aliases = [options[:aliases]].flatten
    @comment = options[:comment]
  end

  # Creates a new Hostsfile::Entry object by parsing a text line. The
  # `line` attribute will be in the following format:
  #
  #     1.2.3.4 hostname [alias[, alias[, alias]]] [# comment]
  #
  # This returns a new Entry object...
  def self.parse(line)
    entry_part, comment_part = line.split('#', 2).collect{ |part| part.strip.empty? ? nil : part.strip }

    # Return nil if the line is empty
    return nil if entry_part.nil?

    # Otherwise, collect all the entries and make a new Entry
    entires = entry_part.split(/\s+/).collect{ |entry| entry.strip unless entry.nil? || entry.strip.empty? }.compact
    return self.new(
      :ip_address => entires[0],
      :hostname => entires[1],
      :aliases => entires[2..-1],
      :comment => comment_part
    )
  end

  # Sort by comparing hostnames
  def <=>(other_entry)
    if self.hostname == 'localhost'
      -1
    elsif other_entry.hostname == 'localhost'
      1
    else
      self.hostname <=> other_entry.hostname
    end
  end

  # Write out the entry as it appears in the hostsfile
  def to_s
    alias_string = [ aliases ].flatten.join(' ')

    unless comment.nil?
      [ pad(ip_address), hostname, alias_string, "# #{comment}" ].join(' ')
    else
      [ pad(ip_address), hostname, alias_string].join(' ')
    end
  end

  private
  # Pads the ip_address to length 15 so things are nicely in a column
  def pad(ip_address)
    ip_address + ' '*(20-ip_address.length)
  end
end
