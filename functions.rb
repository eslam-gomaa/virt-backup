module Functions
require 'open4'
require 'tempfile'
require 'optparse'
require 'digest'
require 'zip'
require 'fileutils'
require 'json'


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

# Functions

  def exec_cmd(cmd)
    info = {}
    info[:cmd] = cmd
    status   = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
      info[:stderr] = stderr.read.strip
      info[:stdout] = stdout.read.strip
      info[:pid]    = pid
    end
    info[:exit_status] = status.exitstatus
    info
  end

  class VM
    def initialize(vm_name)
      @vm = vm_name
    end

# check if the vm exists - If false => exit(1)
# grep -E '(^|\s)#{vm}($|\s)'  => grep EXACT match
    def vm_exists?(vm=@vm)
      cmd = exec_cmd("virsh list --all | grep -E '(^|\\s)#{vm}($|\\s)'")
      if cmd[:exit_status] == 0
        true
      else cmd[:exit_status] > 0
      STDERR.puts "[ ERROR ] vm: (#{vm}) NOT Found"
      exit(1)
      end
    end

# Check of VM exists - returns Boolean [true || false]
    def vm_exists_?(vm=@vm)
      cmd = exec_cmd("virsh list --all | grep -E '(^|\\s)#{vm}($|\\s)'")
      if cmd[:exit_status] == 0
        true
      else cmd[:exit_status] > 0
      false
      end
    end

# print VM state = [shut off, reboot, running, etc...]
    def vm_state?(vm=@vm)
      # grep -E '(^|\s)#{vm}($|\s)'  => grep exact match
      cmd = exec_cmd("virsh list --all | grep -E '(^|\\s)#{vm}($|\\s)'")
      if cmd[:exit_status] == 0
        cmd[:stdout].gsub(/^-/, "").gsub(/\s+/m, ' ').gsub(/^[0-9]\s/, "").gsub(vm,'').gsub(/^\s+/, '').gsub(/^[0-9]+/, '').gsub(/^\s+/, '')
      else cmd[:exit_status] > 0
      STDERR.puts "[ ERROR ] vm: (#{vm}) NOT Found"
      exit(1)
      end
    end

# Print VM's info from the XML file of the VM - in a hash type
# Contains "Missing disks" method --> used internally inside the vm_info() method.
    def vm_info(vm=@vm)
      xml = Tempfile.new(vm)
      cmd = exec_cmd("virsh dumpxml #{vm} > #{xml.path}")
      if cmd[:exit_status] == 0
        true
      else
        puts
        STDERR.puts "[ Error ] could NOT get VM info, check the Error below" # \n#{'-'.*(55)}
        puts "\t\s => #{cmd[:stderr]}"
        exit(1)
      end
      info = {}
      info[:disks] = File.readlines(xml.path).grep(/source file=/).collect {|disk| disk.strip.gsub(/source file=/, '').gsub(/<'/,'').gsub("'/>", '')}
      info[:disks_number] = File.readlines(xml.path).grep(/source file=/).collect {|disk| disk.strip.gsub(/source file=/, '').gsub(/<'/,'').gsub("'/>", '')}.count

      def disks_missing?(disks)
        missing_disks = []
        for disk in disks
          unless File.file?(disk)
            missing_disks << disk
          end
        end
        missing_disks
      end
      xml.close
      info[:disks_missing] = disks_missing?(info[:disks])
      info[:disks_missing_number] = disks_missing?(info[:disks]).count
      info[:disks_exist] = info[:disks] - info[:disks_missing]
      info[:disks_exit_number] = info[:disks_exist].count
      info
    end

    def snapshots_list(vm=@vm)
      begin
        snapshots_list_r =  []
        cmd = exec_cmd("virsh snapshot-list --domain #{vm} --tree")
        if cmd[:exit_status] == 0
          if cmd[:stdout].length == 0
            STDERR.puts "[ INFO ] ".light_blue + "No Snapshots Found for (#{vm})".gray
          else
            snapshots_list = cmd[:stdout].to_s.gsub("+-","").gsub("|","").gsub("\n","").split(/\s\s\s\s/).reject {|s| s.empty?}
            snapshots_list_r = snapshots_list.collect {|s| s.gsub(/^\s/, "").gsub(/^\s\s/, '').gsub(/^\s\s\s/, '').gsub(/^\s/, '').gsub(/^\s\s/, '')}
          end
        else
          puts
          STDERR.puts "[ Error ] Could NOT list Snapshots"
          puts
          puts "=> #{cmd[:stderr]}"
        end
      rescue => e
        STDERR.puts "[ Warning ] Could NOT list snapshots"
        STDERR.puts "\t\s\s\s\s => #{e}"
        STDERR.puts "\t\s\s\s\s => #{cmd[:stderr]}" if cmd[:exit_status] > 0
      end
      snapshots_list_r
    end



    def snapshots_list_type(vm=@vm)
      begin
        snapshots_list_type = {}
        cmd = exec_cmd("virsh snapshot-list --domain #{vm} --tree")
        if cmd[:exit_status] == 0
          if cmd[:stdout].length == 0
            STDERR.puts "[ INFO ] ".light_blue + "No Snapshots Found for (#{vm})".gray
          else
            snapshots_list = cmd[:stdout].to_s.gsub("+-","").gsub("|","").gsub("\n","").split(/\s\s\s\s/).reject {|s| s.empty?}
            snapshots_list_r = snapshots_list.collect {|s| s.gsub(/^\s/, "")}
            for s in snapshots_list_r
              cmd_snap_info = exec_cmd("virsh snapshot-info #{vm} '#{s}'")
              if cmd_snap_info[:exit_status] == 0
                type = cmd_snap_info[:stdout].split("\n").grep(/State:/)[0].gsub(/^State:/, '').strip
                snapshots_list_type[s] = type
              else
                puts
                STDERR.puts "[ Error ] ".red + "Could NOT list Snapshots types"
                puts
                puts "=> #{cmd_snap_info[:stderr]}"
              end
            end
          end
        else
          puts
          STDERR.puts "[ Error ] Could NOT list Snapshots"
          puts
          puts "=> #{cmd[:stderr]}"
        end
      rescue => e
        STDERR.puts "[ Warning ] Could NOT list snapshots"
        STDERR.puts "\t\s\s\s\s => #{e}"
        STDERR.puts "\t\s\s\s\s => #{cmd[:stderr]}" if cmd[:exit_status] > 0
      end
      snapshots_list_type
    end

  end

end

class MD5
  # check MD5 Checksum of a file - --> used by "disks_md5()" method
  def file_md5(file)
    begin
      secret = ''
      File.open(file, 'r') do |f|
        secret = Digest::MD5.new
        until f.eof?
          f.each { |chunk| secret.update(chunk) }
        end
      end
      secret.hexdigest
    rescue Errno::ENOENT => e
      puts("[ Error ] - #{e}")
      return
    end
  end
# check MD5 Checksum of an Array of files - returns them in a Hash type {:file = checksum}

  def disks_md5(disks_array)
    disks_md5 = {}
    for d in disks_array
      disks_md5[File.basename(d).to_sym] = file_md5(d)
    end
    disks_md5
  end

  def deep_diff(a, b)
    (a.keys | b.keys).each_with_object({}) do |k, diff|
      if a[k] != b[k]
        if a[k].is_a?(Hash) && b[k].is_a?(Hash)
          diff[k] = deep_diff(a[k], b[k])
        else
          diff[k] = [a[k], b[k]]
        end
      end
      diff
    end
  end

  def compare_md5(old_hash, restored_hash)
    # compare 2 Hashes
    begin
      old_hash_r = Hash[old_hash.map { |k, v| [k.to_s.sub(k.to_s,File.basename(k.to_s)), v] }]
      #p old_hash_r
      restored_hash.reject! { |k,v| k == :"#{File.basename($checksum_f)}" }
      #if old_hash.size == restored_hash.size
      restored_hash_r = Hash[restored_hash.map { |k, v| [k.to_s.sub(k.to_s,File.basename(k.to_s)), v] }]

      if old_hash_r == restored_hash_r
        sleep(1)
        puts "[ INFO ] ".light_blue + "MD5 check is OK :)"
      else
        STDERR.puts "[ Error ] Found checksum mismatch between backup and restored files"
        difference = deep_diff(old_hash_r, restored_hash_r)
        puts "\t\s => Difference: #{difference.to_s.red}"
        STDERR.puts "[ INFO ] ".light_blue + "Rolling back".red
        FileUtils.rm_rf($restore_dir)
        exit(1)
      end
    end
  end
end

class ZIP
  # If ZIP File does NOT exist - will create it
  # Append the file to the ZIP File
  def create_zip(zip_file, file)
    begin
      Zip.write_zip64_support = true
      Zip::File.open(zip_file, Zip::File::CREATE) do |zipfile|
        zipfile.add(File.basename(file), file)
        puts "\t\s => " + "#{File.basename(file)}  [OK]".green
      end
    rescue Zip::ZipEntryExistsError => e  # To avoide printing "File already exists" Error
      #puts "file #{file} exists"
    end
  end
# create_zip('zip1.zip', 'kube-ready-to-install.qcow2')

  def create_zip_22(zip_file, file, compression=Zlib::DEFAULT_COMPRESSION)
    Zip.default_compression = compression
    Zip.write_zip64_support = true
    begin
      Zip::File.open(zip_file, Zip::File::CREATE) do |zipfile|
        #zipfile.add(File.basename(file), file)
        File.open(file, 'r') do |f|
          while chunk == f.read(16*1024) do
            zipfile.get_output_stream(File.basename(file)){|c| c.write(chunk)}
            # zipfile.get_output_stream(File.basename(file)){|f| f.write File.read(file, 'r')}
          end
        end
        puts "\t\s => " + "#{File.basename(file)}  [OK]".green
      end
    rescue Zip::ZipEntryExistsError => e  # To avoide printing "File already exists" Error
      #puts "file #{file} exists"
    end
  end



  def create_zip_test(zip_file, file, compression=Zlib::DEFAULT_COMPRESSION)
    Zip.default_compression = compression
    Zip.write_zip64_support = true
    begin
      Zip::OutputStream.open(zip_file) do |io|
        io.put_next_entry(File.basename(file))
        File.open(file, 'r') do |source|
          until source.eof?
            chunk = source.read 1024
            io.write chunk
          end
        end
      end
      puts "\t\s => " + "#{File.basename(file)}  [OK]".green
    end
  rescue Zip::ZipEntryExistsError => e  # To avoid printing "File already exists" Error
    #puts "file #{file} exists"
  end



  def read_zip(file)
    files_arr = []
    Zip::File.open(file) do |zip|
      for z in zip
        files_arr.push z.name
      end
    end
    files_arr
  end

  def extract_zip(file, dir)
    begin
      Zip::File.open(file) { |zip_file|
        zip_file.each { |f|
          f_path=File.join("/#{dir}", f.name)
          FileUtils.mkdir_p(File.dirname(f_path))
          zip_file.extract(f, f_path) unless File.exist?(f_path)
          puts "\t\s => " + "#{f}  [OK]".green
        }
      }
    end
  end
end

class Restored
  def initialize()
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
      if ! $out.empty?
        $snapshots_list = $out.to_s.gsub("+-","").gsub("|","").gsub("\n","").split(/\s\s\s\s/).reject {|s| s.empty?}
        $snapshots_list_r = $snapshots_list.collect {|s| s.gsub(/^\s/, "")}
      else
        $snapshots_list = []
      end
    rescue => e
      STDERR.puts "[ Warning ] Could NOT list snapshots"
      STDERR.puts "\t\s\s\s\s => #{e}"
      STDERR.puts "\t\s\s\s\s => #{$err}" if status.exitstatus > 0
    end
    $snapshots_list_r
  end

  def vm_info_restored(xml_file)
    info = {}
    info[:disks] = File.readlines(xml_file).grep(/source file=/).collect {|disk| disk.strip.gsub(/source file=/, '').gsub(/<'/,'').gsub("'/>", '')}
    info[:disks_number] = File.readlines(xml_file).grep(/source file=/).collect {|disk| disk.strip.gsub(/source file=/, '').gsub(/<'/,'').gsub("'/>", '')}.count

    info
  end

  def snapshot_info(xml_file)
    info ={}
    info[:name] = File.readlines(xml_file).grep(/<name>/)[0].gsub(/<name>/, '').gsub('</name>','').gsub("\n", '').gsub(/^\s+/, '')
    info[:state] = File.readlines(xml_file).grep(/<state>/)[0].gsub(/<state>/, '').gsub('</state>','').gsub("\n", '').gsub(/^\s+/, '')
    info[:type] = File.readlines(xml_file).grep(/snapshot=/)[1].gsub(/<disk name=/, '').gsub(/v.[a-z]/, '').gsub(/\s/, '').gsub(/snapshot=/, '').gsub('/>', '').gsub("\n", '').gsub(/^\s+/, '').gsub("'", '')
    info[:xml] = xml_file
    parent_ = File.readlines(xml_file).grep(/\s\s\s<name>/)
    if parent_.count == 2
      info[:parent] = File.readlines(xml_file).grep(/\s\s\s<name>/)[0].strip.gsub(/<name>/, '').gsub('</name>', '')
    else parent_.count == 1
    info[:parent] = nil
    end

    info
  end

  def snapshot_list_by_state(xml_files_arr)
    info    = {}
    running = []
    shutoff = []
    paused  = []
    for x in xml_files_arr
      snapshot_info(x).collect{|k,v| running << snapshot_info(x) if v == 'running'}
      snapshot_info(x).collect{|k,v| shutoff << snapshot_info(x) if v == 'shutoff'}
      snapshot_info(x).collect{|k,v| shutoff << snapshot_info(x) if v == 'paused'}
    end
    info[:running] = running
    info[:shutoff] = shutoff
    info[:paused]  = paused

    info
  end

  def snapshot_list_by_type(xml_files_arr)
    info    = {}
    internal = []
    external = []
    for x in xml_files_arr
      snapshot_info(x).collect{|k,v| internal << snapshot_info(x) if v == 'internal'}
      snapshot_info(x).collect{|k,v| external << snapshot_info(x) if v == 'external'}
    end
    info[:internal] = internal
    info[:external] = external

    info
  end

  def update_snapshot_disk_dir(snapshots_xmls_arr, dir)
    for xml in snapshots_xmls_arr
      old_disk_location = File.readlines(xml).grep(/source file=/).collect {|disk| disk.strip.gsub(/source file=/, '').gsub(/<'/,'').gsub("'/>", '')}
      for old_d in old_disk_location
        $old_d = old_d
        $new_disk_location = "#{dir}/#{File.basename(old_d)}".gsub("//", "/")
      end
      a =  File.open(xml, 'r')
      a1 = a.read
      a.close

      a1.gsub!($old_d,$new_disk_location)
      File.open(xml,'w') {|file| file << a1}
    end
  end

  #def define_snapshots(vm,snapshot_files)
  #if snapshot_files.length > 0
  #puts "[ INFO ] ".light_blue + "Defining the Snapshots"

  #for snap in snapshot_files
  #snapshot_info(snap)
  #end

  #for snap in snapshot_files
  #cmd  = "virsh snapshot-create #{vm} --xmlfile #{snap}"
  #status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
  #$err = stderr.read.strip
  #$out = stdout.read.strip
  #end
  #if status.exitstatus == 0
  #puts "\t\s => Snapshot #{snap} defined successfully"
  #puts "\t\s => #{$out}"
  #else status.exitstatus > 0
  #$snap_status = 1
  #STDERR.puts "[ Warning ] Can NOT define Snapshot: (#{File.basename(snap)})"
  #STDERR.puts "\t\s => #{$err}".green
  #end
  #end
  #if $snap_status == 1
  #puts "[ INFO ] As a workaround, run the following commands to restore the snapshots"
  #puts "\t\s $ virsh start #{vm} ".light_blue + "  Wait till VM starts;"
  #puts "\t\s $ cd #{$options[:restore_dir]}/#{$vm_name}".gsub("//", "/").light_blue

  #for snap_ in snapshot_files
  #puts "\t\s $ virsh snapshot-create #{vm} --xmlfile #{File.basename(snap_)}".light_blue
  #end
  #end
  # end
  #  end


  def snapshot_list_by_parent(xml_files_arr)
    arr     = []

    for x in xml_files_arr
      info = snapshot_info(x)
      arr.push(info)
    end

    arr.collect { |i| i[:order] = nil }
    arr.collect { |i| i[:order] = 1 if i[:parent] == nil }

    (2).upto(arr.count) do |c|
      arr.collect { |i| i[:order] = c if i[:parent] == arr.collect{|o| o[:name] if o[:order] == c - 1}.compact[0] }
    end
    #father_name = arr.collect{|i| i[:name] if i[:order] == 1}.compact[0]
    #arr.collect { |i| i[:order] = 2 if i[:parent] == arr.collect{|o| o[:name] if o[:order] == 1}.compact[0] }
    #arr.collect { |i| i[:order] = 3 if i[:parent] == arr.collect{|o| o[:name] if o[:order] == 2}.compact[0] }

    arr.sort_by { |v| v[:order] }
  end

  def define_restored_vm(xml_file)
    STDOUT.puts "[ INFO ] ".light_blue + "Defining the restored VM: (#{$vm_name})"
    cmd  = "virsh define #{xml_file}"
    status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
      $err = stderr.read.strip
      $out = stdout.read.strip
    end
    if status.exitstatus == 0
      puts "[ INFO ] ".light_blue + "VM: (#{$vm_name}) defined successfully"
      puts "\t\s => #{$out}"
    else status.exitstatus > 0
    STDERR.puts "[ ERROR ] ".red + "Could NOT define the restored VM:  #{$vm_name}"
    STDERR.puts "\t\s => #{$err}"
    exit(1)
    end
  end
  # end



  ### Examples ###

  #vm = VM.new('snap23')
  # p vm.methods
  #p vm.snapshots_list
  #p vm.vm_info
  #p vm.snapshots_list_type
  #p vm.snapshots_list

  #md5 = MD5.new
  #p md5.methods
  #p md5.disks_md5(vm.vm_info[:disks])

  #zip = ZIP.new
  #p zip.methods


  #  restored = Restored.new
  #  restored.methods
  #  p restored.snapshots_list_restore('kube-master-15')
  #p restored.snapshot_info('/root/snap2-s1.xml')[:parent]
  #p restored.snapshot_info('/root/snap2-s2.xml')
  #  xmls = ['/root/xml/snap22-docker-installed-snap.xml',
  #          '/root/xml/snap22-snap2-s1-snap.xml',
  #          '/root/xml/snap22-test-shutdown-snapshot-snap.xml',
  #          '/root/xml/snap22-paused-snapshot-snap.xml',
  #          '/root/xml/snap22-snap2-s2-snap.xml']

  #p restored.snapshot_list_by_parent(xmls)



end
