
require 'nokogiri'
require 'time'

log_file = Rails.root.join('log/vulns.log')
logger = Logger.new(log_file)
logger.formatter = Logger::Formatter.new

tmp_log_file = Rails.root.join('log/fixed_vulns.log')
tmp_logger = Logger.new(tmp_log_file)

desc "Update vulnerabilities"
task :update_vulns, [:file] do |t, args|
  logger.info "Updating vulnerabilities"
  xml = Nokogiri::XML(File.read(Rails.root.join(args.file)))
      
  xml.css('SCAN IP VULNS CAT VULN').each do |vuln|
    qid = vuln['number']
    v = Vulnerability.where(:qid => qid).first
    
    if v.nil?
      logger.info "Adding #{qid}"
      v = update(Vulnerability.new(:qid => vuln['number']), vuln)
    elsif should_update?(v.last_update, vuln)
      logger.info "Updating #{qid}"
      v = update(v, vuln)
    end
    
    if v.valid? and v.changed?
      v.save
    end
  end
end

desc "Identify vulnerable"
task :identify_vulnerable, [:file] => [:environment, :update_vulns] do |t, args|
  logger.info "Identifying affected installs"
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
      
      if same_list?(old_vulns.map(&:name), new_qids)
        logger.info "No change for #{p.name}"
      else
        logger.info "Updating vulnerabilities for #{p.name}"
        new_list += remove_old(old_vulns, new_qids, p.name)
        new_list += add_new(old_vulns, new_qids)
        p.vulnerabilities = new_list
        
        p.save if p.valid?
      end
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

def same_list?(list1, list2)
  (list1 - list2 ) == (list2 - list1)
end

def remove_old(old_vulns, new_qids, ip)
  # Temporary solution to removing vulns
  old_qids = old_vulns.map(&:name)
  removed = old_qids - new_qids
  removed.each do |vuln|
    tmp_logger.info "#{ip},#{vuln},#{Time.now.to_date}"
  end
  old_vulns.select {|e| new_qids.include?(e.name)}
end

def add_new(old_vulns, new_qids)
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
