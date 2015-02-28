module Tunnelss::ConfigureWithPow

  def configure_with_pow
    build_or_update_certificate
  end

  def pow_present?
    File.exists? pow_dir
  end

  private

  def build_or_update_certificate
    unless File.exists?(dir)
      build_dir
      build_ca
      build_certificate
    else
      unless ca_exists?
        build_ca
        build_certificate
      else
        build_certificate if pow_domains_changed?
      end
    end
  end

  def build_dir
    Dir.mkdir(dir)
  end

  def ca_exists?
    File.exists?(ca_dir) && File.exists?("#{ca_dir}/key.pem") && File.exists?("#{ca_dir}/cert.pem")
  end

  def build_ca
    FileUtils.rm_rf(ca_dir) if File.exists?(ca_dir)
    Dir.mkdir(ca_dir)

    puts "Creating SSL keypair for signing #{pow_domain_extensions.join(',')}certificate"
    multi_domain_certificate_param = pow_domain_extensions.map { |e| "CN=*.#{e} Domain CA" }.join('/')
    system "openssl req -newkey rsa:2048 -batch -x509 -sha256 -nodes -subj \"/C=US/O=Developer Certificate/#{multi_domain_certificate_param}\" -keyout #{ca_dir}/key.pem -out #{ca_dir}/cert.pem -days 9999 &> /dev/null"
    puts "Adding certificate to login keychain as trusted."
    system "security add-trusted-cert -d -r trustRoot -k #{ENV['HOME']}/Library/Keychains/login.keychain #{ca_dir}/cert.pem"
    puts "================================================================================"
    puts "To use the certificate without a warning in Firefox you must add the\n\"#{ca_dir}/cert.pem\" certificate to your Firefox root certificates."
    puts "================================================================================"
  end

  def build_certificate
    prepare_openssl_config

    puts "Generating new *.#{pow_domain_extensions.join(',')} certificate"
    multi_domain_certificate_param = pow_domain_extensions.map { |e| "CN=*.#{e}" }.join('/')
    system "openssl req -newkey rsa:2048 -sha256 -batch -nodes -subj \"/C=US/O=Developer Certificate/#{multi_domain_certificate_param}\" -keyout #{dir}/key.pem -out #{dir}/csr.pem -days 9999 &> /dev/null"
    puts "Signing *.#{pow_domain_extensions.join(',')} certificate"
    system "openssl ca -config #{ca_dir}/openssl.cnf -policy policy_anything -batch -days 9999 -out #{dir}/cert.pem -infiles #{dir}/csr.pem &> /dev/null"

    # Build cert chain
    system "cat #{dir}/cert.pem > #{dir}/server.crt"
    system "cat #{ca_dir}/cert.pem >> #{dir}/server.crt"

    write_pow_domains_to_cache

    puts "Generated certificate for your Pow #{pow_domain_extensions.join(',')} domains."
    true
  end

  def prepare_openssl_config
    Dir.mkdir("#{ca_dir}/newcerts") unless File.exists?("#{ca_dir}/newcerts")
    system "touch #{ca_dir}/index.txt"
    serial = File.exists?("#{ca_dir}/serial") ? File.read("#{ca_dir}/serial").to_i + 1 : 1
    File.open("#{ca_dir}/serial", 'w') {|f| f.puts ("%02d" % serial).to_s}
    build_openssl_config_file
  end

  def build_openssl_config_file
    openssl_conf = File.read(File.expand_path('../../../generators/openssl.cnf', __FILE__))
    openssl_conf.gsub!('--CA_DIR--', ca_dir)
    openssl_conf.gsub!('--DOMAINS--', pow_domains_str)
    File.open("#{ca_dir}/openssl.cnf", "w") {|f| f.puts openssl_conf}
  end

  def dir
    "#{ENV['HOME']}/.tunnelss"
  end

  def ca_dir
    "#{dir}/ca"
  end

  def pow_domains_changed?
    read_pow_domains_from_cache != pow_domains.join(',')
  end

  def read_pow_domains_from_cache
    File.exists?(pow_domains_cache_file) ? File.read(pow_domains_cache_file).strip : ''
  end

  def write_pow_domains_to_cache
    File.open(pow_domains_cache_file, 'w') {|f| f.puts pow_domains.join(',')}
  end

  def pow_domains_cache_file
    "#{dir}/pow_domains"
  end

  def pow_domains
    @pow_domains ||= Dir["#{pow_dir}/*"].collect {|f| File.basename(f)}
  end

  def pow_domain_extensions
    @pow_domain_extensions ||= begin
      domains = `source #{ENV['HOME']}/.powconfig 2> /dev/null && echo $POW_DOMAINS`.chomp.split(',')
      domains = ['dev'] if domains.empty?
      domains
    end
  end

  def pow_domains_str
    pow_domains.map do |d|
      pow_domain_extensions.map do |e|
        "DNS:#{d}.#{e},DNS:*.#{d}.#{e}"
      end
    end.flatten.join(',')
  end

  def pow_dir
    "#{ENV['HOME']}/.pow"
  end
end
