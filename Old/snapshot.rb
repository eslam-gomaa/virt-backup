require_relative 'functions'
include Functions

require 'open4'
require 'tempfile'
require 'optparse'
require 'fileutils'
require 'json'



module Snapshot
  class Restore_snapshot

    def initialize(arr_of_hashes, vm, arr_by_order)
      @arr_of_h            = arr_of_hashes
      @vm                  = vm
      @arr_by_order        = arr_by_order
        # @start_true_or_false = true
    end
    def restore_internal_snapshot(arr=@arr_of_h, vm=@vm, hash_order=@arr_by_order )
      running = arr.select {|x| x[:state] == 'running'}
      shutoff = arr.select {|x| x[:state] == 'shutoff'}
      paused  = arr.select {|x| x[:state] == 'paused'}

      need_to_start = running.concat paused
      vm_ = VM.new(vm)
      if need_to_start.count > 1
        puts "[ INFO ] (#{need_to_start.count}) snapshots in RUNNING/PAUSED state detected"
        if vm_.vm_state? == 'shut off'
          puts "[ INFO ] Starting the VM: (#{vm})"
          cmd  = "virsh start #{vm}"
          status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
            $err = stderr.read.strip
            $out = stdout.read.strip
          end
          if status.exitstatus == 0
            true
          else status.exitstatus > 0
          STDERR.puts "[ ERROR ] Unable to Start VM: (#{vm})"
          puts "\t\s => #{$err}"
          end
          # waiting for 60 seconds before restoring the snapshots
          60.to_i.downto(0) do |i|
            print "\r[ INFO ] Waiting for: #{i} seconds  "
            sleep 1
          end
          puts
        end
      end

      # Restore in Order
      for h in hash_order
        cmd  = "virsh snapshot-create --domain #{vm} #{h[:xml]} --redefine"
        status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
          $err = stderr.read.strip
          $out = stdout.read.strip
        end
        if status.exitstatus == 0
          puts "\t\s => Snapshot: (#{h[:name]}) Restored Successfully"
        else status.exitstatus > 0
        STDERR.puts "[ ERROR ] Unable to restore snapshot: (#{h[:name]})"
        puts "\t\s => #{$err}"
        end
      end
      #last_snap_name = hash_order.last[:name]
      last_snap_name = vm_.snapshots_list.last
      puts "[ INFO ] revert to the last snapshot: #{last_snap_name}"
      cmd  = "virsh snapshot-revert --domain #{vm} --snapshotname '#{last_snap_name}'"
      status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
        $err = stderr.read.strip
        $out = stdout.read.strip
      end
      if status.exitstatus == 0
        puts "\t\s => Snapshot: (#{last_snap_name}) Reverted Successfully"
      else status.exitstatus > 0
      STDERR.puts "[ ERROR ] Unable to revert snapshot: (#{last_snap_name})"
      puts "\t\s => #{$err}"
      end
    end

    def restore_external_snapshot
      #puts "[ INFO ] External Snapshots are NOT Supported yet."
    end

  end
end


#  xmls = ['/root/xml/snap22-docker-installed-snap.xml',
#          '/root/xml/snap22-snap2-s1-snap.xml',
#          '/root/xml/snap22-test-shutdown-snapshot-snap.xml',
#          '/root/xml/snap22-paused-snapshot-snap.xml',
#          '/root/xml/snap22-snap2-s2-snap.xml']

#restored = Restored.new


#restore_snapshot = Restore_snapshot.new(restored.snapshot_list_by_type(xmls)[:internal], 'mv12', false)

#restore_snapshot = Restore_snapshot.new(arr_of_hashes=restored.snapshot_list_by_type(xmls)[:internal], vm='mv12',start=true )

#restore_snapshot.restore_internal_snapshot

#restore_snapshot = Restore_snapshot.new(arr_of_hashes=restored.snapshot_list_by_type(xmls)[:internal], vm=$vm_name,start=options[:start])
#restore_snapshot.restore_internal_snapshot

#p restored.snapshot_list_by_parent(xmls)
