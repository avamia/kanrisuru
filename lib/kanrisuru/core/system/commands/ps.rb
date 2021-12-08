module Kanrisuru
  module Core
    module System
      def ps(opts = {})
        group = opts[:group]
        user  = opts[:user]
        pid   = opts[:pid]
        ppid  = opts[:ppid]
        # tree  = opts[:tree]

        command = Kanrisuru::Command.new('ps ww')

        if !user.nil? || !group.nil? || !pid.nil? || !ppid.nil?
          command.append_arg('--user', user.instance_of?(Array) ? user.join(',') : user)
          command.append_arg('--group', group.instance_of?(Array) ? group.join(',') : group)
          command.append_arg('--pid', pid.instance_of?(Array) ? pid.join(',') : pid)
          command.append_arg('--ppid', ppid.instance_of?(Array) ? ppid.join(',') : ppid)
        else
          command.append_flag('ax')
        end

        command.append_arg('-o', 'uid,user,gid,group,ppid,pid,pcpu,pmem,stat,pri,flags,policy,time,cmd')
        command.append_flag('--no-headers')

        execute(command)
        
        Kanrisuru::Result.new(command) do |cmd|
          Parser::Ps.parse(cmd)
        end
      end
    end
  end
end
