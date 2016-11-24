require 'chef/handler'
require 'flowdock'

class Chef
  class Handler
    class FlowdockHandler < Chef::Handler

      def initialize(options = {})
        @from = options[:from] || nil
        @flow = Flowdock::Flow.new(:api_token =>
          options[:api_token],
          :source => options[:source] || "Chef client")
      end

      def report
        if run_status.failed?
          content = "Chef client raised an exception:<br/>"
          content << run_status.formatted_exception
          content << "<br/>"
          content << run_status.backtrace.join("<br/>")

          @from = {:name => "root", :address =>
            "root@#{run_status.node.fqdn}"} if @from.nil?

          @flow.push_to_team_inbox(:subject => "Chef client
            run on #{run_status.node} failed!",
            :content => content,
            :tags => ["chef",
              run_status.node.chef_environment,
              run_status.node.name], :from => @from)
        end
      end
    end
  end
end
