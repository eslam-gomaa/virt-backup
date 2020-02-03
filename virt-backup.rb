require 'open4'
require 'xmlrpc/parser'
require 'tempfile'
require 'optparse'
require 'digest'
require 'zip/zip'
require 'fileutils'
require 'json'


options = {}
OptionParser.new do |opts|
  $opts = opts
  opts.banner = "Usage: #{$0} --backup | --restore [options]"

  options[:with_snapshots]   = false
  options[:original_vm]      = false
  options[:save_dir]         = false
  options[:system_disk_only] = false
  options[:restore_dir]      = false
  options[:backup_file]      = false

  opts.on("-B", "--backup", "Backup KVM VM") do |v|
    options[:backup] = v
  end

  opts.on("-R", "--restore", "Restore KVM VM") do |v|
    options[:restore] = v
  end

  opts.on("-s", "--with-snapshots", "Backup the Snapshots along with the VM") do |v|
    options[:with_snapshots] = v
  end

  opts.on("-S", "--system-disk-only", "Backup the system disk only") do |v|
    options[:system_disk_only] = v
  end

  opts.on("-o", "--original-vm", "Original VM to be Cloned") do |v|
    options[:original_vm] = ARGV[0]
    options[:original_vm] = false if options[:original_vm].nil?
  end


  opts.on("-D", "--save-dir", "Backup save directory") do |v|
    options[:save_dir] = ARGV[0]
    options[:save_dir] = false if options[:save_dir].nil?
  end

  opts.on("-d", "--backup-file", "ZIP File which represents the VM backup") do |v|
    options[:backup_file] = ARGV[0]
    options[:backup_file] = false if options[:backup_file].nil?
  end

  opts.on("-r", "--restore-dir", "Restore directory, with --restore") do |v|
    options[:restore_dir] = ARGV[0]
    options[:restore_dir] = false if options[:restore_dir].nil?
  end

end.parse!


# check input
if options[:backup]
  if options[:original_vm] == false
    puts "\n[ INFO ] you must specify --original-vm"
    puts
    puts $opts
    puts
    exit(1)
  end
  if options[:save_dir] == false
    puts "\n[ INFO ] you must specify --save-dir"
    puts
    puts $opts
    puts
    exit(1)
  end

  if ! File.directory?(options[:save_dir])
    STDERR.puts "[ Error ] --save-dir option must be a directory"
    exit(1)
  end
end

if options[:restore]
  if options[:backup_file] == false
    puts "\n[ INFO ] you must specify --backup-file"
    puts
    puts $opts
    puts
    exit(1)
  end


  if ! File.file?(options[:backup_file])
    STDERR.puts "\n[ INFO ] you must specify a File --backup-file FILE.zip"
    puts
    STDERR.puts $opts
    exit(1)
  elsif File.extname(options[:backup_file]) != ".zip"
    STDERR.puts "\n[ INFO ] --backup-file must be a ZIP File"
    puts
    STDERR.puts $opts
    exit(1)
  elsif options[:backup_file].nil?
    STDERR.puts "\n[ INFO ] you must specify --backup-file"
    puts
    exit(1)
  end

  if options[:restore_dir] == false
    puts "\n[ INFO ] you must specify --restore-dir"
    puts
    puts $opts
    puts
    exit(1)
  end

  if ! File.directory?(options[:restore_dir])
    STDERR.puts "[ Error ] --restore-dir option must be a directory"
    exit(1)
  end


end


# Color
class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end
end


# check if the vm exists, if so abort
def vm_exists?(vm)
  # grep -E '(^|\s)#{vm}($|\s)'  => grep exact match
  cmd  = "virsh list --all | grep -E '(^|\\s)#{vm}($|\\s)'"
  status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
    $err = stderr.read.strip
    $out = stdout.read.strip
  end
  if status.exitstatus == 0
    true
  else status.exitstatus > 0
  STDERR.puts "[ ERROR ] vm: (#{vm}) NOT Found"
  exit(1)
  end
end

def vm_exists_?(vm)
  # grep -E '(^|\s)#{vm}($|\s)'  => grep exact match
  cmd  = "virsh list --all | grep -E '(^|\\s)#{vm}($|\\s)'"
  status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
    $err = stderr.read.strip
    $out = stdout.read.strip
  end
  if status.exitstatus == 0
    true
  else status.exitstatus > 0
  false
  end
end

#vm_exists?("kube-1")

def vm_state?(vm)
  # grep -E '(^|\s)#{vm}($|\s)'  => grep exact match
  cmd  = "virsh list --all | grep -E '(^|\\s)#{vm}($|\\s)'"
  status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
    $err = stderr.read.strip
    $out = stdout.read.strip
  end
  if status.exitstatus == 0
    $out.gsub(/^-/, "").gsub(/\s+/m, ' ').gsub(/^[0-9]\s/, "").gsub(vm,'').gsub(/^\s+/, '').gsub(/^[0-9]+/, '').gsub(/^\s+/, '')
  else status.exitstatus > 0
  STDERR.puts "[ ERROR ] vm: (#{vm}) NOT Found"
  exit(1)
  end
end

if options[:backup]
  if vm_state?(options[:original_vm]) == "shut off"
    # puts "vm is shut off"
  elsif vm_state?(options[:original_vm]) == "running"
    # puts "vm is running"
  elsif vm_state?(options[:original_vm]) == "paused"
    # puts "vm is paused"
  else
    puts "[ Warning ] VM must be in a 'shut off', 'paused' or 'running' state, Aborting"
    puts "\t\s => Current VM state:#{vm_state?(options[:original_vm])}"
    exit(1)
  end
end

def vm_info(vm)
  xml = Tempfile.new(vm)
  cmd  = "virsh dumpxml #{vm} > #{xml.path}"
  xml.close
  status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
    $err = stderr.read.strip
    $out = stdout.read.strip
  end
  if status.exitstatus == 0
    true
  else
    puts
    STDERR.puts "[ Error ] could NOT get VM info, check the Error below \n#{'-'.*(55)}"
    puts
    puts "=> #{$err}"
    exit(1)
  end
  info = {}

  info[:disks] = File.readlines(xml.path).grep(/source file=/).collect {|disk| disk.strip.gsub(/source file=/, '').gsub(/<'/,'').gsub("'/>", '')}
  info[:disks_number] = File.readlines(xml.path).grep(/source file=/).collect {|disk| disk.strip.gsub(/source file=/, '').gsub(/<'/,'').gsub("'/>", '')}.count

  def disks_missing?(disks)
    missing_disks = []
    for disk in disks
      if not File.file?(disk)
        missing_disks << disk
      end
    end
    missing_disks
  end
  info[:disks_missing] = disks_missing?(info[:disks])
  info[:disks_missing_number] = disks_missing?(info[:disks]).count
  info[:disks_exist] = info[:disks] - info[:disks_missing]
  info[:disks_exit_number] = info[:disks_exist].count
  info
end

def file_md5(file)
  begin
    Digest::MD5::hexdigest File.read file
  rescue Errno::ENOENT => e
    return "File_does_NOT_Exist"
  end
end

def disks_md5(disks_array)
  disks_md5 = {}
  for d in disks_array
    disks_md5[d.to_sym] = file_md5(d)
  end
  disks_md5
end

#p disks_md5(vm_info("kube-1")[:disks_exist])

# Function to backup files in a zip file,
# ZIP file will be created itf does NOT exist, so the function is to add files to zip file
def create_zip(zip_file, file)
  begin
    Zip::ZipFile.open(zip_file, Zip::ZipFile::CREATE) do |zipfile|
      zipfile.add(File.basename(file), file)
      puts "\t\s => " + "#{File.basename(file)}  [OK]".green
    end
  rescue Zip::ZipEntryExistsError => e
    #puts "file #{file} exists"
  end
end
# create_zip('zip1.zip', 'kube-ready-to-install.qcow2')

def read_zip(file)
  files_arr = []
  Zip::ZipFile.open(file) do |zip|
    for z in zip
      files_arr.push z.name
    end
  end
  files_arr
end


def extract_zip(file, dir)
  begin
    Zip::ZipFile.open(file) { |zip_file|
      zip_file.each { |f|
        f_path=File.join("/#{dir}", f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) unless File.exist?(f_path)
        puts "\t\s => " + "#{f}  [OK]".green
      }
    }
  end
end

# Function to list snapshots
def snapshots_list(vm)
  begin
    cmd  = "virsh snapshot-list --domain #{vm} --tree"
    status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
      $err = stderr.read.strip
      $out = stdout.read.strip
    end
    if status.exitstatus == 0
      true
    else
      puts
      STDERR.puts "[ Error ] Could NOT list Snapshots"
      puts
      puts "=> #{$err}"
    end
    if $out.length == 0
      STDERR.puts "[ Warning ] No Snapshots Found for #{vm}"
    else
      $snapshots_list = $out.to_s.gsub!("+-","").gsub!("|","").gsub!("\n","").split("\s")
    end
  rescue => e
    STDERR.puts "[ Warning ] Could NOT list snapshots"
    STDERR.puts "\t\s\s\s\s => #{e}"
    STDERR.puts "\t\s\s\s\s => #{$err}" if status.exitstatus > 0
  end
  $snapshots_list
end

def snapshots_list_restore(vm)
  begin
    cmd  = "virsh snapshot-list --domain #{vm} --tree"
    status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
      $err = stderr.read.strip
      $out = stdout.read.strip
    end
    if status.exitstatus == 0
      true
    else
      puts
      STDERR.puts "[ Error ] Could NOT list Snapshots"
      puts
      puts "=> #{$err}"
    end
    if ! $out.length == 0
      $snapshots_list = $out.to_s.gsub!("+-","").gsub!("|","").gsub!("\n","").split("\s")
    else
      $snapshots_list = []
    end
  rescue => e
    STDERR.puts "[ Warning ] Could NOT list snapshots"
    STDERR.puts "\t\s\s\s\s => #{e}"
    STDERR.puts "\t\s\s\s\s => #{$err}" if status.exitstatus > 0
  end
  $snapshots_list
end

#p snapshots_list("kube-2")

$options = options
def backup(vm)

  #p vm_info(vm)
  # Throw a warning if there are missing disks for the VM's (specified in the XML file but NOT exist)
  if vm_info(vm)[:disks_missing_number] > 0
    puts
    STDERR.puts "[ Warning ] (#{vm_info(vm)[:disks_missing_number]}) Missing disk/s found, Will NOT be backed up:"
    STDERR.puts "\t\s\s\s\s => #{vm_info(vm)[:disks_missing]}"
  end

  # get xml file of the VM
  xml = Tempfile.new(vm)
  cmd  = "virsh dumpxml #{vm} > #{xml.path}"
  $vm_xml_path = xml.path
  xml.close
  status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
    $err = stderr.read.strip

  end
  if status.exitstatus == 0
    true
  else
    puts
    STDERR.puts "[ Error ] could NOT Extract VM XML, check the Error below \n#{'-'.*(55)}"
    puts
    puts "=> #{$err}"
    exit(1)
  end

  puts
  STDOUT.puts "[ INFO ] Getting checksum of the Files will be backed up - May take time based on size"
  # Check sum of the files that'll be backed-up
  checksum = disks_md5(vm_info(vm)[:disks_exist])
  checksum[:"#{vm}.xml"] = file_md5($vm_xml_path)
  # p checksum

  # checksum of snapshots XML files
  $snapshot_paths = []
  if $options[:with_snapshots]
    if not snapshots_list(vm).nil?
      for snapshot in snapshots_list(vm)
        $snap_xml_path = "/tmp/#{vm}-#{snapshot}-snap.xml"
        cmd  = "virsh snapshot-dumpxml #{vm} #{snapshot} > #{$snap_xml_path}"

        status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
          $err = stderr.read.strip
        end
        if status.exitstatus == 0
          true
        else
          puts
          STDERR.puts "[ Error ] could NOT Extract Snap XML (#{snapshot}), check the Error below \n#{'-'.*(55)}"
          puts
          puts "=> #{$err}"
          exit(1)
        end
        checksum[:"#{vm}-#{snapshot}-snap.xml".to_s] = file_md5($snap_xml_path).to_s
        $snapshot_paths << $snap_xml_path
      end
    end
  end

  #p checksum
  #p $snapshot_paths

  ### backup ###


  puts "[ INFO ] Current state VM: #{vm_state?($options[:original_vm])}"

  if vm_state?($options[:original_vm]) == 'running'
    STDOUT.puts "[ INFO ] Pausing the VM"
    cmd  = "virsh suspend #{$options[:original_vm]}"
    status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
      $err = stderr.read.strip
      $out = stdout.read.strip
    end
    if status.exitstatus == 0
      true
    else status.exitstatus > 0
    STDERR.puts "[ ERROR ] vm: (#{$options[:original_vm]}) Unable to Pause the VM "
    STDERR.puts "=> #{$err}"
    exit(1)
    end
  end
  sleep(6)


  # Add the disk files to the ZIP file
  #
  if $options[:system_disk_only]
    disks_to_backup = vm_info(vm)[:disks][0].split
  else
    disks_to_backup = vm_info(vm)[:disks_exist]
  end
  #p disks_to_backup


  STDOUT.puts "[ INFO ] Backing up VM: (#{$options[:original_vm]}), N of disks: (#{disks_to_backup.count}) - May take time based on size"

  # Create Zip file, & add the "checksum" of the files will be backed up
  checksum_dir = "/tmp/#{vm}.checksum"
  File.open(checksum_dir, 'w') { |f|
    f.puts checksum }

  zip_file = "#{$options[:save_dir]}/#{vm}.zip"
  create_zip(zip_file,checksum_dir)
  File.delete(checksum_dir)

  # Add snapshots XML files to the ZIP file
  if $options[:with_snapshots]
    for s in $snapshot_paths
      create_zip(zip_file, s)
      File.delete(s)
    end
  end

  # Add the VM's XML to the ZIP file
  vm_xml_file = "/tmp/#{vm}.xml"
  cmd  = "virsh dumpxml #{vm} > #{vm_xml_file}"
  system(cmd)
  create_zip(zip_file, vm_xml_file)
  File.delete(vm_xml_file)

  for disk in disks_to_backup
    create_zip(zip_file,disk)
  end

  if vm_state?(vm) == "paused"
    STDOUT.puts "[ INFO ] Resuming the VM"
    cmd  = "virsh resume #{$options[:original_vm]}"
    status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
      $err = stderr.read.strip
      $out = stdout.read.strip
    end
    if status.exitstatus == 0
      true
    else status.exitstatus > 0
    STDERR.puts "[ ERROR ] vm: (#{$options[:original_vm]}) Unable to Resume the VM "
    STDERR.puts "\t\s\s=> #{$err}"
    exit(1)
    end
    sleep(3)
    puts "[ INFO ] Current state VM: #{vm_state?($options[:original_vm])}"
  end
  $backed_up_file = "#{$options[:save_dir]}/#{vm}.zip"
  puts "[ INFO ] Backup stored successfully in (#{$backed_up_file.gsub("//", "/")})"
end


if options[:backup]
  if vm_exists?(options[:original_vm])
    backup(options[:original_vm])
  end

elsif options[:restore]

  puts
  # Restore

  $vm_name     = File.basename(options[:backup_file], '.*')
  $restore_dir = "#{options[:restore_dir]}/#{$vm_name}".gsub("//", "/")


  if File.directory?($restore_dir)
    puts "[ INFO ] Dir: (#{$restore_dir}) already exists, Try again with a non-existing directory"
    exit(1)
  end

  ####

  puts "[ INFO ] Restoring VM: (#{$vm_name}), May take time based on size"

  # Create Restore directory
  FileUtils.mkdir_p($restore_dir)

  begin
    extract_zip(options[:backup_file], $restore_dir)
  rescue Errno::ENOSPC => e
    STDERR.puts "[ Error ] No Space Left on the Device - choose a directory with enough space"
    STDERR.puts "\t\s => #{e}"
    STDERR.puts "[ INFO ] Rolling back"
    #FileUtils.rm_rf($restore_dir)
    exit(1)
  end

  STDOUT.puts "[ INFO ] Backup restored successfully in (#{$restore_dir})"

  #zip_files = read_zip(options[:backup_file])

  checksum_file  = "#{$restore_dir}/#{$vm_name}.checksum"
  checksum_read  = File.read(checksum_file)
  checksum_clear = checksum_read.gsub(":", "").gsub('=>', ':').gsub("\n", '')
  checksum_hash  = JSON.parse(checksum_clear.gsub('\"', '"'))


  restored_files = Dir["#{$restore_dir}/*"]
  restored_xml = Dir["#{$restore_dir}/*.xml"]
  snapshots_xml = Dir["#{$restore_dir}/*-snap.xml"]
  vm_xml = restored_xml - snapshots_xml
  restored_disks = restored_files  - restored_xml - checksum_file.split


  #checksum_keys = checksum_hash.keys

  #p checksum_hash

  STDOUT.puts "[ INFO ] Getting checksum of the restored backup - May take time based on size"
  restored_files_hash = disks_md5(restored_files)

  #p checksum_file

  $checksum_f = checksum_file
  def compare_md5(old_hash, restored_hash)
    # compare 2 Hashes
    begin
      old_hash_r = Hash[old_hash.map { |k, v| [k.to_s.sub(k.to_s,File.basename(k.to_s)), v] }]
      #p old_hash_r
      restored_hash.reject! { |k,v| k == :"#{$checksum_f}" }
      #if old_hash.size == restored_hash.size

      restored_hash_r = Hash[restored_hash.map { |k, v| [k.to_s.sub(k.to_s,File.basename(k.to_s)), v] }]
      #p restored_hash_r
      if old_hash_r == restored_hash_r
        sleep(1)
        puts "[ INFO ] MD5 check is OK :)"
      else
        STDERR.puts "[ Error ] Found checksum mismatch between backup and restored files"
        STDERR.puts "[ INFO ] Rolling back"
        FileUtils.rm_rf($restore_dir)
        exit(1)
      end

      #else
      #  STDERR.puts "[ Error ] restored Files number does NOT match backup files number"
      #  exit(1)
      #end

    end
  end


  # Update restored XML with the new location of disks

  def vm_info_restored(xml_file)
    info = {}
    info[:disks] = File.readlines(xml_file).grep(/source file=/).collect {|disk| disk.strip.gsub(/source file=/, '').gsub(/<'/,'').gsub("'/>", '')}
    info[:disks_number] = File.readlines(xml_file).grep(/source file=/).collect {|disk| disk.strip.gsub(/source file=/, '').gsub(/<'/,'').gsub("'/>", '')}.count

    info
  end


  if restored_disks.length == 1
    # restored xml p disk
    vm_info_restored_p_disk = File.basename(vm_info_restored(vm_xml[0])[:disks][0])
    # restored disks
    restored_disks_str = File.basename(restored_disks[0])

    # vm_info_restored_p_disk => vm_info_restored_xml_primary_disk
    # restored_disks_str      => actually restored disks

    if vm_info_restored_p_disk == restored_disks_str
      puts "[ INFO ] Only Primary disk is detected for this backup"
      to_del_from_checksum = vm_info_restored(vm_xml[0])[:disks] - vm_info_restored(vm_xml[0])[:disks].grep(/#{restored_disks_str}$/)

      for d in to_del_from_checksum

        checksum_hash.reject! { |k,v| k == d}
      end
      checksum_hash
    end
  end

  #p "disks from restored xml"
  #p vm_info_restored(vm_xml[0])[:disks]

  puts "[ INFO ] Comparing backup MD5 vs restored MD5"
  compare_md5(checksum_hash, restored_files_hash)

  #$snapshots_xml = snapshots_xml
  #p $snapshots_xml

  def define_snapshots(vm,snapshot_files)
    if snapshot_files.length > 0
      puts "[ INFO ] Defining the Snapshots"
      for snap in snapshot_files
        cmd  = "virsh snapshot-create #{vm} --xmlfile #{snap}"
        status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
          $err = stderr.read.strip
          $out = stdout.read.strip
        end
        if status.exitstatus == 0
          puts "\t\s => Snapshot #{snap} defined successfully"
          puts "\t\s => #{$out}"
        else status.exitstatus > 0
        STDERR.puts "[ Warning ] Can NOT define Snapshot: (#{File.basename(snap)})"
        STDERR.puts "\t\s => #{$err}".green
        end
      end
    end
  end

  def run_restored_vm(vml_file)
    STDOUT.puts "[ INFO ] Defining the restored VM: (#{$vm_name})"
    cmd  = "virsh define #{vml_file}"
    status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
      $err = stderr.read.strip
      $out = stdout.read.strip
    end
    if status.exitstatus == 0
      puts "[ INFO ] VM: #{$vm_name} defined successfully"
      puts "\t\s => #{$out}"
    else status.exitstatus > 0
    STDERR.puts "[ ERROR ] Can NOT define the restored VM:  #{$vm_name}"
    STDERR.puts "\t\s => #{$err}"
    exit(1)
    end
  end


  restored_xml_disks = vm_info_restored(vm_xml[0])[:disks]

  #restored_xml_disks_p_disk = restored_xml_disks[0]

  #puts "[ INFO ] Updating disks location with the restored dir"

  if restored_disks.length <= 1
    puts "[ INFO ] Only primary disk detected"
    restored_xml_disks_p_disk = vm_info_restored(vm_xml[0])[:disks][0]
    new_disk_locaiton = "#{$restore_dir}/#{File.basename(restored_xml_disks_p_disk)}".gsub("//", "/")

    a =  File.open(vm_xml[0], 'r')
    a1 = a.read
    a.close

    a1.gsub!(restored_xml_disks_p_disk,new_disk_locaiton)
    File.open(vm_xml[0],'w') {|file| file << a1}

  else restored_disks.length > 1
  puts "[ INFO ] Updating disks location with the restored dir"
  for d in restored_xml_disks
    new_disk_locaiton = "#{$restore_dir}/#{File.basename(d)}".gsub("//", "/")
    # d                 => disk location that needs to be replaced
    # new_disk_locaiton => new disk location to replace

    a =  File.open(vm_xml[0], 'r')
    a1 = a.read
    a.close

    a1.gsub!(d,new_disk_locaiton)
    File.open(vm_xml[0],'w') {|file| file << a1}
  end
  end


  if vm_exists_?($vm_name) == false
    run_restored_vm(vm_xml[0])
  else
    puts "[ INFO ] VM: #{$vm_name} already exists - Skip defining the VM"
  end

  #p snapshots_list($vm_name)
  #p snapshots_xml

  if vm_exists_?($vm_name)
    if options[:with_snapshots]
        define_snapshots($vm_name,snapshots_xml)
    end
  end


else
  puts "[ Warning ] use '--backup' or '--restore'"
  puts $opts
  puts
end
