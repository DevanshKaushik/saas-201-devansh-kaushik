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

def parse_dns(raw)
  dns_records = {}

  # Removing comments and empty lines
  raw.each.with_index do |line, i|
    if line.start_with?("#") or line == "\n"
      raw.delete_at(i)
    end
  end

  raw.each do |line|
    type, domain, point = record = line.split(",")

    # Creating the hash table
    dns_records[domain.strip] = {
      :type => type.strip,
      :point => point.strip,
    }
  end

  return dns_records
end

def resolve(dns_records, lookup_chain, domain)
  dns_records.each do |domain_stored, domain_detail|
    next if domain_stored != domain

    # Pushing the pointer to the lookup list
    lookup_chain.push(domain_detail[:point])

    # Checking for the record types
    if domain_detail[:type] == "CNAME"
      domain_new = domain_detail[:point]
      lookup_chain = resolve(dns_records, lookup_chain, domain_new)
      return lookup_chain
    elsif domain_detail[:type] == "A"
      return lookup_chain
    else
      return ["ERROR: record type for #{domain} is unknown"]
    end
  end

  # If no records are found
  ["Error: record not found for #{domain}"]
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
