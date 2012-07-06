
require 'nokogiri'
require 'time'

log_file = Rails.root.join('log/vulns.log')
logger = Logger.new(log_file)
logger.formatter = Logger::Formatter.new

tmp_log_file = Rails.root.join('log/fixed_vulns.log')
tmp_logger = Logger.new(tmp_log_file)

desc "Update vulnerabilities"
task :update_vulns => :environment do |t, args|
  logger.info "Updating vulnerabilities from file: [#{latest_report}]"
  xml = Nokogiri::XML(File.read(latest_report))
      
  xml.css('VULN_DETAILS').each do |vuln|
    qid = vuln.at_css('QID').content
    v = Vulnerability.where(:qid => qid).first
    
    if v.nil?
      logger.info "Adding #{qid}"
      v = update(Vulnerability.new(:qid => qid), vuln)
    elsif should_update?(v.last_update, vuln)
      logger.info "Updating #{qid}"
      v = update(v, vuln)
    else
      logger.info "Doing nothing for #{qid}"
    end
    
    if v.valid? and v.changed?
     v.save
    end
  end
end

desc "Identify vulnerable"
task :identify_vulnerable => [:environment, :update_vulns] do |t, args|
  logger.info "Identifying affected installs from file: [#{latest_report}]"
  xml = Nokogiri::XML(File.read(latest_report))
  xml.css('HOST').each do |ip|
    if ip.at_css('NETBIOS')
      p = Personality.where('name ilike ?', ip.at_css('NETBIOS').content).first
    elsif ip.at_css('DNS')
      p = Personality.where('name ilike ?', ip.at_css('DNS').content.split('.').first).first
    else
      p = Personality.where('name ilike ?', ip.at_css('IP').content.split('.').join('-')).first
    end
    if p
      old_vulns = p.vulnerabilities
      new_list = []
      
      new_vulns = ip.css('VULN_INFO').reject {|v| v.at_css('VULN_STATUS').content == 'Fixed'}
      new_qids = new_vulns.map {|v| v.at_css('QID').content}.uniq
      
      if same_list?(old_vulns.map(&:name), new_qids)
        logger.info "No change for #{p.name}"
      else
        logger.info "Updating vulnerabilities for #{p.name}"
        new_list += remove_old(old_vulns, new_qids, p.name, tmp_logger)
        new_list += add_new(old_vulns, new_qids)
        p.vulnerabilities = new_list
      end
    end
  end
end

desc "Destroy all Vulnerabilities"
task :destroy_vulns => :environment do
  Vulnerability.all.each do |vuln|
    vuln.destroy
  end
end

def update(v, vuln)
  v.last_update = Time.parse(vuln.at_css('LAST_UPDATE').content).to_date
  v.severity = vuln.at_css('SEVERITY').content
  v.title = vuln.at_css('TITLE').content
  v.pci = vuln.at_css('PCI_FLAG').content == '1'
  v.diagnosis = vuln.at_css('THREAT').content
  v.consequence = vuln.at_css('IMPACT').content
  v.solution = vuln.at_css('SOLUTION').content
  v.fixable = fixable?(vuln)
  
  return v
end

def same_list?(list1, list2)
  (list1 - list2 ) == (list2 - list1)
end

def remove_old(old_vulns, new_qids, ip, log)
  # Temporary solution to removing vulns
  old_qids = old_vulns.map(&:name)
  removed = old_qids - new_qids
  removed.each do |vuln|
    log.info "#{ip},#{vuln},#{Time.now}"
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

def fixable?(vuln)
  if vuln.at_css('SOLUTION').content.match(/^There are no vendor supplied patches available at this time\./) != nil
    return false
  elsif vuln.at_css('TITLE').content.match(/zero day/i) != nil
    return false
  else
    return true
  end
end

def latest_report
  d = Dir.new("/home/deployer/reports")
  return File.join(d.path, d.sort.last)
end