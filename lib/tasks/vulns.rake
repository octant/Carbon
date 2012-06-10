
require 'nokogiri'
require 'time'

desc "Load vulnerabilities"
task :load_vulns, [:file] => :environment do |t, args|
  xml = Nokogiri::XML(File.read(Rails.root.join(args.file)))
      
  xml.css('SCAN IP VULNS CAT VULN').each do |vuln|
    qid = vuln['number']
    puts "searching for #{qid}"
    v = Vulnerability.where(:qid => qid).first
    
    if v.nil?
      v = update(Vulnerability.new(:qid => vuln['number']), vuln)
    elsif should_update?(v.last_update, vuln)
      puts "Updating #{qid}"
      v = update(v, vuln)
    else
      puts "found #{qid}"
    end
    
    if v.valid? and v.changed?
      puts "saving qid: #{v.qid}"
      v.save
    end
  end
end

desc "Identify vulnerable"
task :identify_vulnerable, [:file] => :environment do |t, args|
   xml = Nokogiri::XML(File.read(Rails.root.join(args.file)))
   xml.css('SCAN IP').each do |ip|
     if ip.at_css('NETBIOS_HOSTNAME')
       p = Personality.where('name ilike ?', ip.at_css('NETBIOS_HOSTNAME').content).first
     else
       p = Personality.where('name ilike ?', ip['value'].split('.').join('-')).first
     end
     if p
       old_vulns = p.vulnerabilities
       new_list = []
     
       new_qids = ip.css('VULNS CAT VULN').map {|v| v['number']}.uniq
       new_list += old_removed(old_vulns, new_qids)
       new_list += new_added(old_vulns, new_qids)
       p.vulnerabilities = new_list
       p.save if p.valid?
     end
   end
end

def update(v, vuln)
  v.last_update = Time.parse(vuln.at_css('LAST_UPDATE').content).to_date
  v.severity = vuln['severity']
  v.title = vuln.at_css('TITLE').content
  v.pci = vuln.at_css('PCI_FLAG').content == '1'
  v.diagnosis = vuln.at_css('DIAGNOSIS').content
  v.consequence = vuln.at_css('CONSEQUENCE').content
  v.solution = vuln.at_css('SOLUTION').content
  v.fixable = vuln.at_css('TITLE').content.match(/zero day/i).nil? ? true : false
  
  return v
end

def old_removed(old_vulns, new_qids)
  old_vulns.select {|e| new_qids.include?(e.name)}
end

def new_added(old_vulns, new_qids)
  new_vulns = []
  old_qids = old_vulns.map(&:name)
  new_qids.each do |qid|
    unless old_qids.include?(qid)
      v = Vulnerability.where(:qid => qid).first
      new_vulns << v if v
    end
  end
  new_vulns
end

def should_update?(last_update, vuln)
  last_update < Time.parse(vuln.at_css('LAST_UPDATE').content).to_date
end
