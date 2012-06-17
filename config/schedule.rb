# Import new vulnerabilities
every 1.day, :at => '14:40' do
  rake "identify_vulnerable"
end