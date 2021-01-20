def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

# Function to parse the raw dns data read from the zone
# file and converting it to the dns_record hash
def parse_dns(raw)
  dns_records = {}

  raw.
    reject { |line| line.empty? or line.start_with?("#") }.
    map { |line| line.strip.split(", ") }.
    reject { |record| record.length < 3 }.
    each { |data| dns_records[data[1]] = { :type => data[0], :target => data[2] } }

  dns_records
end

# Function to find the IP Address for the given
# domain in the dns_records hash. Returns a lookup
# array of aliases(if any) and the address itself
def resolve(dns_records, lookup_chain, domain)
  domain_detail = dns_records[domain]

  if domain_detail.nil?
    return ["Error: record not found for #{domain}"]
  end

  # Pushing the target to the lookup list
  lookup_chain.push(domain_detail[:target])

  # Checking for the record types
  if domain_detail[:type] == "CNAME"
    domain_new = domain_detail[:target]
    lookup_chain = resolve(dns_records, lookup_chain, domain_new)
    return lookup_chain
  elsif domain_detail[:type] == "A"
    return lookup_chain
  else
    return ["ERROR: record type for #{domain} is unknown"]
  end
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
