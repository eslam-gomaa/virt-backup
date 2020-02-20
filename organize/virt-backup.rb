require_relative 'functions'
require_relative 'snapshot'
include Functions
include Snapshot

require 'open4'
require 'xmlrpc/parser'
require 'tempfile'
require 'optparse'
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
  #options[:start]            = false

  opts.on("-B", "--backup", "Backup KVM VM") do |v|
    options[:backup] = v
    options[:backup] = false if options[:backup].nil?
  end
  opts.on("-R", "--restore", "Restore KVM VM") do |v|
    options[:restore] = v
    options[:restore] = false if options[:restore].nil?
  end
  opts.on("-s", "--with-snapshots", "Backup the Snapshots along with the VM") do |v|
    options[:with_snapshots] = v
  end
  #opts.on("-t", "--start", "To restore 'running' snapshots, the VM must be started first") do |v|
  #  options[:start] = v
  #  options[:start] = false if options[:start].nil?
  #end
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
  def pink
    colorize(35)
  end
  def light_blue
    colorize(36)
  end
  def green
    colorize(32)
  end
end

###############

# ARGV[0] must be '--backup' or '--restore'

if options[:backup] | options[:restore] == false
  puts $opts
  exit(1)
end

###############

# Initialize "Functions.rb" classes
#
$vm_ = VM.new(options[:original_vm])
$md5 = MD5.new
$zip = ZIP.new
$restored = Restored.new

###############



# Checking VM State
# Abort if VM state != /'shut off'||'running'||paused/
if options[:backup]
  if $vm_.vm_state?(options[:original_vm]) == "shut off"
    # puts "vm is shut off"
  elsif $vm_.vm_state?(options[:original_vm]) == "running"
    # puts "vm is running"
  elsif $vm_.vm_state?(options[:original_vm]) == "paused"
    # puts "vm is paused"
  else
    puts "[ Warning ] VM must be in a 'shut off', 'paused' or 'running' state, Aborting"
    puts "\t\s => Current VM state: " + "#{$vm_.vm_state?(options[:original_vm])}".light_blue
    exit(1)
  end
end

### Backup ###

$options = options
def backup(vm)

  zip_file = "#{$options[:save_dir]}/#{vm}.zip"
  if File.file?(zip_file)
    puts
    puts "[ INFO ] A backup file with the same name already exists, choose another directory"
    exit(1)
  end


  #p vm_info(vm)
  # Throw a warning if there are missing disks for the VM's (specified in the XML file but NOT exist)
  if $vm_.vm_info(vm)[:disks_missing_number] > 0
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
    STDERR.puts "[ Error ] could NOT Extract VM XML, check the Error below" #  \n#{'-'.*(55)}
    puts
    puts "\t\s => #{$err}"
    exit(1)
  end

  puts
  puts "[ INFO ] Current VM State: " + "#{$vm_.vm_state?($options[:original_vm])}".pink

  if $vm_.vm_state?($options[:original_vm]) == 'running'
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

  STDOUT.puts "[ INFO ] Getting checksum of the Files will be backed up - May take time based on size"
  # Check sum of the files that'll be backed-up
  checksum = $md5.disks_md5($vm_.vm_info(vm)[:disks_exist])
  checksum[:"#{vm}.xml"] = $md5.file_md5($vm_xml_path)
  # p checksum

  #p $vm_.snapshots_list($options[:original_vm])

  # checksum of snapshots XML files
  $snapshot_paths = []
  if $options[:with_snapshots]
    if not $vm_.snapshots_list(vm).nil?
      for snapshot in $vm_.snapshots_list(vm)
        $snap_xml_path = "/tmp/#{vm}-#{snapshot.gsub(/\s+/, '-')}-snap.xml"
        cmd  = "virsh snapshot-dumpxml #{vm} '#{snapshot}' > #{$snap_xml_path}"
        status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
          $err = stderr.read.strip
        end
        if status.exitstatus == 0
          true
        else
          puts
          STDERR.puts "[ Error ] could NOT Extract Snap XML (#{snapshot}), check the Error below" # \n#{'-'.*(55)} # to print ----
          puts "\t\s => #{$err}"
          exit(1)
        end
        checksum[:"#{vm}-#{snapshot.gsub(/\s+/, '-')}-snap.xml".to_s] = $md5.file_md5($snap_xml_path).to_s
        $snapshot_paths << $snap_xml_path
      end
    end
  end

  #p checksum
  #p $snapshot_paths

  ### backup ###

  # Add the disk files to the ZIP file
  #

  #if File.file?($options[:options])

  if $options[:system_disk_only]
    disks_to_backup = $vm_.vm_info(vm)[:disks][0].split
  else
    disks_to_backup = $vm_.vm_info(vm)[:disks_exist]
  end
  #p disks_to_backup

  STDOUT.puts "[ INFO ] Backing up VM: (#{$options[:original_vm]}), N of disks: (#{disks_to_backup.count}) - May take time based on size"

  # Create Zip file, & add the "checksum" of the files will be backed up
  checksum_file = "/tmp/#{vm}.checksum"
  File.open(checksum_file, 'w') { |f|
    f.puts checksum }


  $zip.create_zip(zip_file,checksum_file)
  File.delete(checksum_file)

  # Add snapshots XML files to the ZIP file
  if $options[:with_snapshots]
    for s in $snapshot_paths
      $zip.create_zip(zip_file, s)
      File.delete(s)
    end

  end

  # Add the VM's XML to the ZIP file
  vm_xml_file = "/tmp/#{vm}.xml"
  cmd  = "virsh dumpxml #{vm} > #{vm_xml_file}"
  system(cmd)
  $zip.create_zip(zip_file, vm_xml_file)
  File.delete(vm_xml_file)

  for disk in disks_to_backup
    $zip.create_zip(zip_file,disk)
  end

  if $vm_.vm_state?(vm) == "paused"
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
    puts "[ INFO ] Current VM State: " + "#{$vm_.vm_state?($options[:original_vm])}".pink
  end
  $backed_up_file = "#{$options[:save_dir]}/#{vm}.zip"
  puts "[ INFO ] Backup stored successfully in (#{$backed_up_file.gsub("//", "/")})"
end

if options[:backup]
  if $vm_.vm_exists?(options[:original_vm])
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
    $zip.extract_zip(options[:backup_file], $restore_dir)
  rescue Errno::ENOSPC => e
    STDERR.puts "[ Error ] No Space Left on the Device - choose a directory with enough space"
    STDERR.puts "\t\s => #{e}"
    STDERR.puts "[ INFO ] Rolling back"
    FileUtils.rm_rf($restore_dir)
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
  restored_files_hash = $md5.disks_md5(restored_files)


  $checksum_f = checksum_file

  if restored_disks.length == 1
    # restored xml p disk
    vm_info_restored_p_disk = File.basename($restored.vm_info_restored(vm_xml[0])[:disks][0])
    # restored disks
    restored_disks_str = File.basename(restored_disks[0])

    # vm_info_restored_p_disk => vm_info_restored_xml_primary_disk
    # restored_disks_str      => actually restored disks

    if vm_info_restored_p_disk == restored_disks_str
      puts "[ INFO ] Only Primary disk is detected for this backup"
      to_del_from_checksum = $restored.vm_info_restored(vm_xml[0])[:disks] - $restored.vm_info_restored(vm_xml[0])[:disks].grep(/#{restored_disks_str}$/)

      for d in to_del_from_checksum
        checksum_hash.reject! { |k,v| k == d}
      end
      checksum_hash
    end
  end

  #p "disks from restored xml"
  #p vm_info_restored(vm_xml[0])[:disks]

  puts "[ INFO ] Comparing backup MD5 vs restored MD5"
  $md5.compare_md5(checksum_hash, restored_files_hash)

  #$snapshots_xml = snapshots_xml
  #p $snapshots_xml

  restored_xml_disks = $restored.vm_info_restored(vm_xml[0])[:disks]

  #restored_xml_disks_p_disk = restored_xml_disks[0]

  #puts "[ INFO ] Updating disks location with the restored dir"

  if restored_disks.length <= 1
    puts "[ INFO ] Updating disk location with the restored dir"
    restored_xml_disks_p_disk = $restored.vm_info_restored(vm_xml[0])[:disks][0]
    new_disk_location = "#{$restore_dir}/#{File.basename(restored_xml_disks_p_disk)}".gsub("//", "/")

    a =  File.open(vm_xml[0], 'r')
    a1 = a.read
    a.close

    a1.gsub!(restored_xml_disks_p_disk,new_disk_location)
    File.open(vm_xml[0],'w') {|file| file << a1}

  else restored_disks.length > 1
  puts "[ INFO ] Updating disks location with the restored dir"
  for d in restored_xml_disks
    new_disk_location = "#{$restore_dir}/#{File.basename(d)}".gsub("//", "/")
    # d                 => disk location that needs to be replaced
    # new_disk_location => new disk location to replace

    a =  File.open(vm_xml[0], 'r')
    a1 = a.read
    a.close

    a1.gsub!(d,new_disk_location)
    File.open(vm_xml[0],'w') {|file| file << a1}
  end
  end

  # update snapshots xml disks

  #p $restore_dir

  puts "[ INFO ] Updating snapshots disks location with the restored dir"
  $restored.update_snapshot_disk_dir(snapshots_xml, $restore_dir)


  # Define the vm

  if $vm_.vm_exists_?($vm_name) == false
    $restored.define_restored_vm(vm_xml[0])
  else
    puts "[ INFO ] VM: (#{$vm_name}) already exists - Skip defining the VM"
  end

  #p snapshots_list($vm_name)
  #p snapshots_xml

  if $vm_.vm_exists_?($vm_name)
    if options[:with_snapshots]
      #$restored.define_snapshots($vm_name,snapshots_xml)


    end
  end


  if $restored.snapshot_list_by_type(snapshots_xml)[:internal].count > 0
    puts "[ INFO ] Restoring Internal Snapshots - (#{$restored.snapshot_list_by_type(snapshots_xml)[:internal].count}) detected"
    restore_snapshot = Restore_snapshot.new(arr_of_hashes=$restored.snapshot_list_by_type(snapshots_xml)[:internal], vm=$vm_name,arr_by_order=$restored.snapshot_list_by_parent(snapshots_xml))
    restore_snapshot.restore_internal_snapshot
  end
  if $restored.snapshot_list_by_type(snapshots_xml)[:external].count > 0
    puts "[ INFO ] (#{$restored.snapshot_list_by_type(snapshots_xml)[:external].count}) External Snapshots detected"
    puts "[ INFO ] External Snapshots are NOT Supported yet..."
  end



else
  puts "[ Warning ] use '--backup' or '--restore'"
  puts $opts
  puts
end

