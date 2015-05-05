module Fluent
  class ChefClientInput < Input
    Plugin.register_input("chef_client", self)

    config_param :check_interval, :integer, :default => 60
    config_param :chef_server_url, :string, :default => nil
    config_param :client_key, :string, :default => nil
    config_param :config_file, :string, :default => "/etc/chef/client.rb"
    config_param :node_name, :string, :default => nil
    config_param :tag_prefix, :string, :default => "chef_client"

    def initialize
      super
      require "chef"
    end

    def configure(conf)
      super
      ::Chef::Config.from_file(@config_file)
      if @chef_server_url
        ::Chef::Config[:chef_server_url] = @chef_server_url
      end
      if @client_key
        ::Chef::Config[:client_key] = @client_key
      end
      if @node_name
        ::Chef::Config[:node_name] = @node_name
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
      node_name = ::Chef::Config[:node_name]
      next_run = ::Time.new
      while @running
        if ::Time.new < next_run
          sleep(1)
        else
          begin
            now = Engine.now
            node = ::Chef::Node.load(node_name)
            ohai_time = node["ohai_time"]
            Engine.emit("#{@tag_prefix}.behind_from", now, {"value" => ohai_time ? (now - ohai_time) : -1})
          rescue => error
            $log.warn("failed to load attributes of node \`#{node_name.inspect}': #{error.inspect}")
            next
          ensure
            next_run = ::Time.new + @check_interval
          end
        end
      end
    end
  end
end
