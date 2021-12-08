module Kanrisuru::Core::System
  module Parser
    class Last
      class << self
        def parse(command)
          lines = cmd.to_a

          mapping = {}

          lines.each do |line|
            next if Kanrisuru::Util.blank?(line)
            next if line.include?('wtmp') || line.include?('btmp')

            line = line.gsub('  still logged in', '- still logged in') if line.include?('still logged in')

            values = line.split(/\s{2,}/, 4)
            user   = values[0]
            tty    = values[1]
            ip     = IPAddr.new(values[2])

            date_range = values[3]
            login, logout = date_range.split(' - ')

            login = parse_last_date(login) if login
            logout = parse_last_date(logout) if logout

            detail = Kanrisuru::Core::System::SessionDetail.new
            detail.tty = tty
            detail.ip_address = ip
            detail.login_at = login
            detail.logout_at = logout

            detail.success = !Kanrisuru::Util.present?(opts[:failed_attemps])

            mapping[user] = Kanrisuru::Core::System::LoginUser.new(user, []) unless mapping.key?(user)

            mapping[user].sessions << detail
          end

          mapping.values
        end

        def parse_last_date(string)
          tokens = string.split

          return if tokens.length < 4

          month_abbr = tokens[1]
          day = tokens[2]
          timestamp = tokens[3]
          year = tokens[4]

          DateTime.parse("#{day} #{month_abbr} #{year} #{timestamp}")
        end
      end
    end
  end
end
