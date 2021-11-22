
require "pathname"

module LND
  module Tool
    module Daemon

      module_function

      def base_dir
        Pathname.new(File.expand_path("#{Dir.home}/.lnd-tool"))
      end

      def pid_path
        base_dir.join('pid')
      end

      def pid_file?
        pid_path.file?
      end

      def running?
        base_dir.exist? && pid_file? && Process.kill(0, pid_path.read.to_i) == 1
      rescue Errno::ESRCH
        false
      end

      def stop
        Process.kill('KILL', pid_path.read.to_i) if running?
      end

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
