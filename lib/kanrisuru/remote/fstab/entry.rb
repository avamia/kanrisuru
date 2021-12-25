# frozen_string_literal: true

module Kanrisuru
  module Remote
    class Fstab
      class Entry
        attr_reader :device, :uuid, :invalid, :label, :type, :opts, :freq, :passno
        attr_accessor :mount_point

        def initialize(opts = {})
          @host = opts[:host]
          @line = opts[:line]

          @default = nil

          @device = opts[:device] || nil
          @opts = opts[:opts] || nil
          @label = opts[:label] || nil
          @uuid = opts[:uuid] || nil
          @mount_point = opts[:mount_point] || nil
          @type = opts[:type] || nil
          @freq = opts[:freq] || nil
          @passno = opts[:passno] || nil

          @changed = false

          @ucount = 0
          @special = false
          @invalid = false

          if Kanrisuru::Util.present?(@line) && @line.instance_of?(String)
            parse_line!
          elsif (Kanrisuru::Util.present?(@opts) && @opts.instance_of?(String)) || @opts.instance_of?(Hash)
            @opts = Kanrisuru::Remote::Fstab::Options.new(@type, @opts)
          end
        end

        def inspect
          str = '#<Kanrisuru::Remote::Fstab::Entry:0x%<object_id>s ' \
                '@line=%<line>s @device=%<device>s @label=%<label>s' \
                '@uuid=%<uuid>s @freq=%<freq>s @pasno=%<passno>s' \
                '@opts=%<opts>s}>'

          format(
            str,
            object_id: object_id,
            line: @line,
            device: @device,
            label: @label,
            uuid: @uuid,
            freq: @freq,
            passno: @passno,
            opts: @opts.inspect
          )
        end

        def valid?
          !@invalid
        end

        def to_s(override = nil)
          mode = override || @default

          case mode
          when 'uuid'
            "UUID=#{@uuid} #{@mount_point} #{@type} #{@opts} #{@freq} #{@passno}"
          when 'label'
            "LABEL=#{@label} #{@mount_point} #{@type} #{@opts} #{@freq} #{@passno}"
          else
            "#{@device} #{@mount_point} #{@type} #{@opts} #{@freq} #{@passno}"
          end
        end

        private

        def parse_line!
          fsline, mp, @type, opts, freq, passno = @line.split

          @mount_point = mp
          @freq = freq || '0'
          @passno = passno || '0'

          @opts = Fstab::Options.new(@type, opts)

          case @line
          when /^\s*LABEL=/
            @default = 'label'
            parse_label(fsline)
          when /^\s*UUID=/
            @default = 'uuid'
            parse_uuid(fsline)
          when %r{^\s*/dev}
            @default = 'dev'
            parse_dev(fsline)
          else
            # TODO: somewhat risky to assume that everything else
            # can be considered a special device, but validating this
            # is really tricky.
            @special = true
            @device = fsline
          end

          # Fstab entries not matching real devices have device unknown
          @invalid = (@line.split.count != 6) # invalid entry if < 6 columns

          if (@uuid.nil? && @label.nil? && !@special) ||
             @device =~ /^unknown_/ ||
             (!@host.inode?(@device) && !@special)
            @invalid = true
            @ucount += 1
          end

          @invalid = true unless @freq =~ /0|1|2/ && @passno =~ /0|1|2/
        end

        def parse_label(fsline)
          @label = fsline.split('=').last.strip.chomp
          path = @host.realpath("/dev/disk/by-label/#{@label}").path

          @device = begin
            "/dev/#{path.split('/').last}"
          rescue StandardError
            "unknown_#{@ucount}"
          end

          result = @host.blkid(device: @device)
          @uuid = result.success? ? result[0].uuid : nil
        end

        def parse_uuid(fsline)
          @uuid = fsline.split('=').last.strip.chomp
          path = @host.realpath("/dev/disk/by-uuid/#{uuid}").path

          @device = begin
            "/dev/#{path.split('/').last}"
          rescue StandardError
            "unknown_#{@ucount}"
          end

          result = @host.blkid(device: @device)
          @label = result.success? ? result[0].label : nil
        end

        def parse_dev(fsline)
          @device = fsline
          result = @host.blkid(device: @device)

          @label = result.success? ? result[0].label : nil
          @uuid = result.success? ? result[0].uuid : nil
        end
      end
    end
  end
end
