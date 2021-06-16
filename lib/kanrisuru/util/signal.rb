# frozen_string_literal: true

module Kanrisuru
  class Util
    class Signal
      @linux = {
        'HUP' => 1,
        'INT' => 2,
        'QUIT' => 3,
        'ILL' => 4,
        'TRAP' => 5,
        'ABRT' => 6,
        'BUS' => 7,
        'FPE' => 8,
        'KILL' => 9,
        'USR1' => 10,
        'SEGV' => 11,
        'USR2' => 12,
        'PIPE' => 13,
        'ALRM' => 14,
        'TERM' => 15,
        'STKFLT' => 16,
        'CHLD' => 17,
        'CONT' => 18,
        'STOP' => 19,
        'TSTP' => 20,
        'TTIN' => 21,
        'TTOU' => 22,
        'URG' => 23,
        'XCPU' => 24,
        'XFSZ' => 25,
        'VTALRM' => 26,
        'PROF' => 27,
        'WINCH' => 28,
        'IO' => 29,
        'PWR' => 30,
        'SYS' => 31,
        'RTMIN' => 34,
        'RTMIN+1' => 35,
        'RTMIN+2' => 36,
        'RTMIN+3' => 37,
        'RTMIN+4' => 38,
        'RTMIN+5' => 39,
        'RTMIN+6' => 40,
        'RTMIN+7' => 41,
        'RTMIN+8' => 42,
        'RTMIN+9' => 43,
        'RTMIN+10' => 44,
        'RTMIN+11' => 45,
        'RTMIN+12' => 46,
        'RTMIN+13' => 47,
        'RTMIN+14' => 48,
        'RTMIN+15' => 49,
        'RTMAX-14' => 50,
        'RTMAX-13' => 51,
        'RTMAX-12' => 52,
        'RTMAX-11' => 53,
        'RTMAX-10' => 54,
        'RTMAX-9' => 55,
        'RTMAX-8' => 56,
        'RTMAX-7' => 57,
        'RTMAX-6' => 58,
        'RTMAX-5' => 59,
        'RTMAX-4' => 60,
        'RTMAX-3' => 61,
        'RTMAX-2' => 62,
        'RTMAX-1' => 63,
        'RTMAX' => 64
      }

      @linux_inverted = {
        1 => 'HUP',
        2 => 'INT',
        3 => 'QUIT',
        4 => 'ILL',
        5 => 'TRAP',
        6 => 'ABRT',
        7 => 'BUS',
        8 => 'FPE',
        9 => 'KILL',
        10 => 'USR1',
        11 => 'SEGV',
        12 => 'USR2',
        13 => 'PIPE',
        14 => 'ALRM',
        15 => 'TERM',
        16 => 'STKFLT',
        17 => 'CHLD',
        18 => 'CONT',
        19 => 'STOP',
        20 => 'TSTP',
        21 => 'TTIN',
        22 => 'TTOU',
        23 => 'URG',
        24 => 'XCPU',
        25 => 'XFSZ',
        26 => 'VTALRM',
        27 => 'PROF',
        28 => 'WINCH',
        29 => 'IO',
        30 => 'PWR',
        31 => 'SYS',
        34 => 'RTMIN',
        35 => 'RTMIN+1',
        36 => 'RTMIN+2',
        37 => 'RTMIN+3',
        38 => 'RTMIN+4',
        39 => 'RTMIN+5',
        40 => 'RTMIN+6',
        41 => 'RTMIN+7',
        42 => 'RTMIN+8',
        43 => 'RTMIN+9',
        44 => 'RTMIN+10',
        45 => 'RTMIN+11',
        46 => 'RTMIN+12',
        47 => 'RTMIN+13',
        48 => 'RTMIN+14',
        49 => 'RTMIN+15',
        50 => 'RTMAX-14',
        51 => 'RTMAX-13',
        52 => 'RTMAX-12',
        53 => 'RTMAX-11',
        54 => 'RTMAX-10',
        55 => 'RTMAX-9',
        56 => 'RTMAX-8',
        57 => 'RTMAX-7',
        58 => 'RTMAX-6',
        59 => 'RTMAX-5',
        60 => 'RTMAX-4',
        61 => 'RTMAX-3',
        62 => 'RTMAX-2',
        63 => 'RTMAX-1',
        64 => 'RTMAX'
      }

      def self.[](signal)
        return unless valid?(signal)

        if key.instance_of?(Integer)
          @linux_inverted[signal]
        else
          @linux[translate(signal)]
        end
      end

      def self.valid?(signal)
        if signal.instance_of?(Integer)
          @linux_inverted.key?(signal)
        elsif signal.instance_of?(String)
          @linux.key?(translate(signal))
        else
          raise ArgumentError, 'Invalid data type'
        end
      end

      def self.translate(signal)
        signal.gsub('SIG', '')
      end
    end
  end
end
