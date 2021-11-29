# frozen_string_literal: true

require 'pathname'

module LND
  module Tool
    # Daemon module for cli
    module Daemon

      module_function

      # Get base directory path.
      # @return [Pathname] directory path.
      def base_dir
        Pathname.new(File.expand_path("#{Dir.home}/.lnd-tool"))
      end

      # Get database file path.
      # @return [Pathname] database file path.
      def db_path
        base_dir.join('storage.db')
      end

      # Get pid file path.
      # @return [Pathname] pid file path.
      def pid_path
        base_dir.join('pid')
      end

      # Check whether pid file exist?
      # @return [Boolean]
      def pid_file?
        pid_path.file?
      end

      # Check whether daemon running?
      # @return [Boolean]
      def running?
        base_dir.exist? && pid_file? && Process.kill(0, pid_path.read.to_i) == 1
      rescue Errno::ESRCH
        false
      end

      # Stop daemon.
      def stop
        Process.kill('KILL', pid_path.read.to_i) if running?
      end

      # Start block program as daemon.
      def start
        base_dir.mkdir unless base_dir.exist?
        raise LND::Tool::Error, "process(#{pid_path.read.to_i}) already running." if running?

        Process.daemon(true)
        pid_path.write(Process.pid.to_s)
        yield
      ensure
        pid_path.delete if pid_file?
      end

    end
  end
end
