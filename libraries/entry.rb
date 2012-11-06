require 'ipaddr'

class Entry
  attr_accessor :ip_address, :hostname, :aliases, :comment, :priority

  def initialize(options = {})
    raise ':ip_address and :hostname are both required options' if options[:ip_address].nil? || options[:hostname].nil?

    @ip_address = IPAddr.new(options[:ip_address])
    @hostname = options[:hostname]
    @aliases = [options[:aliases]].flatten
    @comment = options[:comment]
    @priority = options[:priority] || calculate_priority(@ip_address)
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
        ip_address: entries[0],
        hostname: entries[1],
        aliases: entries[2..-1],
        comment: comment_part
      )
    end

    private
    # Attempt to calculate the relative priority of each entry
    def calculate_priority(ip_address)
      return 81 if ip_address == IPAddr.new("127.0.0.1")
      return 80 if IPAddr.new("127.0.0.0/8").include?(ip_address) # local
      return 60 if ip_address.ipv4? # ipv4
      return 20 if ip_address.ipv6? # ipv6
      return 00 # 
    end
  end

  # Write out the entry as it appears in the hostsfile
  def to_s
    alias_string = [ aliases ].flatten.join(' ')

    unless comment.nil?
      [ ip_address, hostname + ' ' + alias_string, "# #{comment}" ].join("\t").strip
    else
      [ ip_address, hostname + ' ' + alias_string].join("\t").strip
    end
  end

  private
  # Proxy to the class method
  def calculate_priority(ip_address)
    Entry.send(:calculate_priority, ip_address)
  end
end
