require_relative 'functions'
include Functions

require 'open4'
require 'xmlrpc/parser'
require 'tempfile'
require 'optparse'
require 'fileutils'
require 'json'



module Snapshot
  class Restore_snapshot

    def initialize(arr_of_hashes, vm, start_true_or_false)
      @arr_of_h            = arr_of_hashes
      @vm                  = vm
      @start_true_or_false = start_true_or_false
    end
    def restore_internal_snapshot(arr=@arr_of_h, vm=@vm,start=@start_true_or_false)
      running = arr.select {|x| x[:state] == 'running'}
      shutoff = arr.select {|x| x[:state] == 'shutoff'}
      paused  = arr.select {|x| x[:state] == 'paused'}

      # restoring RUNNING state snapshot

      if start == true
        # If RUNNING STATE snapshot > 1, restore
        if running.count >= 1
          puts "[ INFO ] restoring RUNNING state snapshots, N of snapshots: (#{running.count})"
          vm_ = VM.new(vm)
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
          for  h in running
            puts "\t\s => Restoring snapshot: (#{h[:name]})"
            cmd  = "virsh snapshot-create --domain #{vm} #{h[:xml]} --redefine"
            status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
              $err = stderr.read.strip
              $out = stdout.read.strip
            end
            if status.exitstatus == 0
              true
            else status.exitstatus > 0
            STDERR.puts "[ ERROR ] Unable to restore snapshot: (#{h[:name]})"
            puts "\t\s => #{$err}"
            end
          end
        end
        # restoring PAUSED state snapshot
        if paused.count >= 1
          puts "[ INFO ] restoring SHUTOFF state snapshots, N of snapshots: (#{paused.count})"
          for  h in paused
            puts "\t\s => Restoring snapshot: (#{h[:name]})"
            cmd  = "virsh snapshot-create --domain #{vm} #{h[:xml]} --redefine"
            status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
              $err = stderr.read.strip
              $out = stdout.read.strip
            end
            if status.exitstatus == 0
              true
            else status.exitstatus > 0
            STDERR.puts "[ ERROR ] Unable to restore snapshot: (#{h[:name]})"
            puts "\t\s => #{$err}"
            end
          end
        end
      end
      # restoring SHUTOFF state snapshot
      # If SHUT OFF STATE snapshot > 1, restore
      if shutoff.count >= 1
        puts "[ INFO ] restoring SHUTOFF state snapshots, N of snapshots: (#{shutoff.count})"
        for  h in shutoff
          puts "\t\s => Restoring snapshot: (#{h[:name]})"
          cmd  = "virsh snapshot-create --domain #{vm} #{h[:xml]} --redefine"
          status = Open4::popen4(cmd) do |pid,stdin,stdout,stderr|
            $err = stderr.read.strip
            $out = stdout.read.strip
          end
          if status.exitstatus == 0
            true
          else status.exitstatus > 0
          STDERR.puts "[ ERROR ] Unable to restore snapshot: (#{h[:name]})"
          puts "\t\s => #{$err}"
          end
        end
      end
    end


    def restore_external_snapshot
      # puts "Not supported for now"
    end

  end
end

#xmls = ['/root/firefox-installed.xml', '/root/s2.xml', '/root/s1.xml', '/root/snap2-s1.xml']

#restored = Restored.new


#restore_snapshot = Restore_snapshot.new(restored.snapshot_list_by_type(xmls)[:internal], 'mv12', false)

#restore_snapshot = Restore_snapshot.new(arr_of_hashes=restored.snapshot_list_by_type(xmls)[:internal], vm='mv12',start=true )

#restore_snapshot.restore_internal_snapshot

#puts "Test"

#restored.update_snapshot_disk_dir(xmls, '/tmp')



