require 'ip'

desc "Find untracked servers"
task :untracked_servers => :environment do
  personalities = Personality.servers
  personalities.each do |personality|
    if personality.vulnerabilities.empty?
      $stdout.puts "#{personality.name},#{personality.ip}"
    end
  end
end

desc "Scan network"
task :scan_network => :environment do
  net_objs = Network.all
  net_objs.each do |net_obj|
    if alive?(net_obj.default_gateway)
      net = IP.new("#{net_obj.network_identifier}/#{mask_len(net_obj.network_mask)}")
      threads = []
      range = (1..(net.size - 2))
      range.each_slice(20) do |chunk|
        chunk.each do |i|
          ip = (net + i).to_addr
          threads << Thread.new(i) do
            if alive?(ip)
              name = resolve(ip)
              p = Personality.find_or_initialize_by_name(name)
              p.ip, p.network_id = ip, net_obj.id
              p.last_seen = Time.now
              $stdout.puts "Saw [#{name}] on network [#{net_obj.network_identifier}]"
              p.save
            end
          end
        end
      end
      threads.each(&:join)
    end
  end
end

def alive?(ip)
  ping_result = `ping -c 1 -W 1 #{ip}`
  return $? == 0
end

def resolve(ip)
  host_result = `host -W 0.1 #{ip}`
  if host_result.match(/not found/)
    return name = ip.split('.').join('-')
  else
    return name = host_result.split.last.split('.').first
  end
end

def mask_len(mask)
  mask.split(".").map do |e|
    e.to_i.to_s(2).split("").count("1")
  end.inject(:+)
end