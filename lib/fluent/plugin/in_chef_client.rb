#!/usr/bin/env ruby

if __FILE__ == $0
  module Fluent
    class Input
      def self.config_param(name, *args, &block)
      end
    end
    class Plugin
      def self.register_input(type, klass)
      end
    end
  end
end

module Fluent
  class ChefClientInput < Input
    Plugin.register_input("chef_client", self)

    config_param :check_interval, :integer, :default => 60
    config_param :chef_server_url, :string, :default => nil
    config_param :client_key, :string, :default => nil
    config_param :config_file, :string, :default => "/etc/chef/client.rb"
    config_param :node_name, :string, :default => nil
    config_param :tag, :string, :default => "chef_client"

    def initialize
      super
      require "json"
      require "rbconfig"
    end

    def configure(conf)
      super
      @chef_config = {
        :config_file     => @config_file,
        :chef_server_url => @chef_server_url,
        :client_key      => @client_key,
        :node_name       => @node_name,
      }
      ruby = ::File.join(::RbConfig::CONFIG["bindir"], ::RbConfig::CONFIG["ruby_install_name"])
      if ::File.executable?(ruby)
        @ruby = ruby
      else
        @ruby = "ruby"
      end
    end

    def start
      @running = true
      @thread = ::Thread.new(&method(:run))
    end

    def shutdown
      @running = false
      @thread.join
    end

    def run
      next_run = ::Time.new
      while @running
        if ::Time.new < next_run
          sleep(1)
        else
          data = nil
          begin
            emit_time = Engine.now # the precision of `Engine.now` might be changed in future implementation
            ohai_time = ::Time.new.to_i # expect epoch time in seconds
            $log.debug("invoking process: #{@ruby} #{__FILE__}")
            # Run the plugin script oneself as a child process of fluentd
            ::IO.popen([@ruby, __FILE__], "r+") do |io|
              io.write(::JSON.dump(@chef_config))
              io.close_write
              data = ::JSON.load(io.read)
            end
            $log.debug("#{File.basename(__FILE__).dump} exits as #{$?.exitstatus}")
            if $?.exitstatus == 0 and Hash === data
              data.each do |key, val|
                Engine.emit("#{@tag}.#{key}", emit_time, {"value" => val})
              end
              if ::Numeric === data["ohai_time"]
                Engine.emit("#{@tag}.behind_seconds", emit_time, {"value" => ohai_time - data["ohai_time"]})
              end
            else
              raise("invalid response from #{__FILE__.dump}: #{data.inspect}")
            end
          rescue => error
            $log.warn("failed to load attributes: #{error.class}: #{error.message}: #{data.inspect}")
            next
          ensure
            next_run = ::Time.new + @check_interval
          end
        end
      end
    end

    # This method will not be invoked directly from fluentd plugin to avoid yajl's incompatibility issue between fluentd and chef.
    def run_once
      require "chef"
      if @config_file
        ::Chef::Config.from_file(@config_file)
      end
      if @chef_server_url
        ::Chef::Config[:chef_server_url] = @chef_server_url
      end
      if @client_key
        ::Chef::Config[:client_key] = @client_key
      end
      if @node_name
        ::Chef::Config[:node_name] = @node_name
      end
      node_name = ::Chef::Config[:node_name]
      node = ::Chef::Node.load(node_name)
      data = ::Hash[["ohai_time", "idletime_seconds", "uptime_seconds"].map { |attr| [attr, node[attr].to_i] }]
      STDOUT.puts(::JSON.dump(data))
    end
  end
end

if __FILE__ == $0
  input = Fluent::ChefClientInput.new
  data = JSON.load(STDIN.read)
  if Hash === data
    data.each do |key, val|
      input.instance_variable_set(:"@#{key}", val)
    end
  end
  input.run_once
end
