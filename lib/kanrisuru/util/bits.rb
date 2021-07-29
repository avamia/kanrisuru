# frozen_string_literal: true

module Kanrisuru
  class Util
    class Bits
      def self.normalize_size(string)
        size, unit = string.split
        size = size.to_f
        unit ||= 'b'

        return 0 if size.zero?

        case unit.downcase
        when 'b'
          Kanrisuru::Util::Bits.convert_bytes(size, :byte, :kilobyte)
        when 'kb', 'k', 'kib'
          size
        when 'mb', 'm', 'mib'
          Kanrisuru::Util::Bits.convert_from_mb(size, :kilobyte).to_i
        when 'gb', 'g', 'gib'
          Kanrisuru::Util::Bits.convert_from_gb(size, :kilobyte).to_i
        end
      end

      def self.convert_from_kb(value, metric)
        convert_bytes(value, :kilobyte, metric)
      end

      def self.convert_from_mb(value, metric)
        convert_bytes(value, :megabyte, metric)
      end

      def self.convert_from_gb(value, metric)
        convert_bytes(value, :gigabyte, metric)
      end

      def self.convert_from_tb(value, metric)
        convert_bytes(value, :terabyte, metric)
      end

      def self.convert_from_pb(value, metric)
        convert_bytes(value, :petabyte, metric)
      end

      def self.convert_bytes(value, from, to)
        from = from.downcase.to_sym
        to   = to.downcase.to_sym

        byte_translations = {
          b: :deca,
          kb: :kilo,
          mb: :mega,
          gb: :giga,
          tb: :tera,
          pb: :peta,
          byte: :deca,
          kilobyte: :kilo,
          megabyte: :mega,
          gigabyte: :giga,
          terabyte: :tera,
          petabyte: :peta
        }

        bit_translations = {
          kib: :kilo,
          mib: :mega,
          gib: :giga,
          tib: :tera,
          pib: :peta,
          bit: :deca,
          kilobit: :kilo,
          megabit: :mega,
          gigabit: :giga,
          terabit: :tera,
          petabit: :peta
        }

        bit_translation_from = false
        bit_translation_to   = false

        from =
          if bit_translations.key?(from)
            bit_translation_from = true
            bit_translations[from]
          elsif byte_translations.key?(from)
            byte_translations[from]
          else
            raise ArgumentError, 'Invalid data type'
          end

        to =
          if bit_translations.key?(to)
            bit_translation_to = true
            bit_translations[to]
          elsif byte_translations.key?(to)
            byte_translations[to]
          else
            raise ArgumentError, 'Invalid data type'
          end

        multiplier = if bit_translation_from && !bit_translation_to
                       (1.to_f / 8).to_f
                     elsif !bit_translation_from && bit_translation_to
                       8
                     else
                       1
                     end

        power = convert_power(from, to)

        (value * 1000.pow(power).to_f) * multiplier
      end

      def self.convert_power(from_metric, to_metric)
        @conversions ||= {
          deca: {
            deca: 0,
            kilo: -1,
            mega: -2,
            giga: -3,
            tera: -4,
            peta: -5,
            exa: -6,
            zetta: -7,
            yotta: -8
          },
          kilo: {
            deca: 1,
            kilo: 0,
            mega: -1,
            giga: -2,
            tera: -3,
            peta: -4,
            exa: -5,
            zetta: -6,
            yotta: -7
          },
          mega: {
            deca: 2,
            kilo: 1,
            mega: 0,
            giga: -1,
            tera: -2,
            peta: -3,
            exa: -4,
            zetta: -5,
            yotta: -6
          },
          giga: {
            deca: 3,
            kilo: 2,
            mega: 1,
            giga: 0,
            tera: -1,
            peta: -2,
            exa: -3,
            zetta: -4,
            yotta: -5
          },
          tera: {
            deca: 4,
            kilo: 3,
            mega: 2,
            giga: 1,
            tera: 0,
            peta: -1,
            exa: -2,
            zetta: -3,
            yotta: -4
          },
          peta: {
            deca: 5,
            kilo: 4,
            mega: 3,
            giga: 2,
            tera: 1,
            peta: 0,
            exa: -1,
            zetta: -2,
            yotta: -3
          },
          exa: {
            deca: 6,
            kilo: 5,
            mega: 4,
            giga: 3,
            tera: 2,
            peta: 1,
            exa: 0,
            zetta: -1,
            yotta: -2
          },
          zetta: {
            deca: 7,
            kilo: 6,
            mega: 5,
            giga: 4,
            tera: 3,
            peta: 2,
            exa: 1,
            zetta: 0,
            yotta: -1
          },
          yotta: {
            deca: 8,
            kilo: 7,
            mega: 6,
            giga: 5,
            tera: 4,
            peta: 3,
            exa: 2,
            zetta: 1,
            yotta: 0
          }
        }

        values = @conversions[from_metric]
        values ? values[to_metric] : nil
      end
    end
  end
end
