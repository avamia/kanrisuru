
module Kanrisuru
  module Core
    module Dmi
      class Parser
        class << self
          def parse(command)
            lines = command.to_a

            rows = []
            current_struct = nil
            wrapped_field_line = nil

            lines.each do |line|
              next if Kanrisuru::Util.blank?(line)

              case line
              when /^Handle/
                if current_struct
                  rows << current_struct

                  current_struct = nil
                  wrapped_field_line = nil
                end

                values = line.split(', ')
                handle = values[0].split('Handle ')[1]

                type = values[1].split(/(\d+)/)[1].to_i
                type = Kanrisuru::Util::DmiType[type]
                next if Kanrisuru::Util.blank?(type)

                bytes = values[2].split(/(\d+)/)[1]

                current_struct = dmi_type_to_struct(type)
                current_struct.dmi_handle = handle
                current_struct.dmi_type = type
                current_struct.dmi_size = bytes.to_i
              when /:/
                values = line.split(': ')

                field = values[0].strip
                value = values[1] ? values[1].strip : ''

                dmi_append_field(current_struct, field, value)

                case line
                when 'Characteristics:'
                  current_struct.characteristics = []
                  wrapped_field_line = :characteristics
                when 'Flags:'
                  current_struct.flags = []
                  wrapped_field_line = :flags
                when 'Supported SRAM Types:'
                  current_struct.supported_sram_types = []
                  wrapped_field_line = :supported_sram_types
                when 'Features:'
                  current_struct.features = []
                  wrapped_field_line = :features
                when 'Strings:'
                  current_struct.strings = []
                  wrapped_field_line = :strings
                end
              else
                current_struct[wrapped_field_line] << line.strip if wrapped_field_line
              end
            end

            rows << current_struct if current_struct
            rows
          end

          def dmi_append_field(struct, field, value)
            field = dmi_field_translate(struct, field)
            field = field.to_sym

            if struct.respond_to?(field)
              case struct.dmi_type
              when 'OEM Strings'
                if struct.strings
                  struct[field] << value
                else
                  struct.strings = [value]
                end
              else
                struct[field] = value
              end
            else
              Kanrisuru.logger.warn("Field does not exist for: #{struct.dmi_type}: #{field} => #{value}")
            end
          end

          def dmi_field_translate(struct, field)
            field = field.downcase
            field = field.gsub(/\s/, '_')
            field = field.gsub('-', '_')
            field = field.gsub(':', '')

            case struct.dmi_type
            when 'Memory Device'
              case field
              when 'size'
                return 'mem_size'
              end
            when 'System Slots'
              case field
              when 'length'
                return 'slot_length'
              end
            when 'OEM Strings'
              case field
              when /^string/
                return 'strings'
              end
            when 'Boot Integrity Services'
              case field
              when '16_bit_entry_point_address'
                return 'sixteen_bit_entry_point_address'
              when '32_bit_entry_point_address'
                return 'thirty_two_bit_entry_point_address'
              end
            end

            field
          end

          def dmi_type_to_struct(type)
            type =
              case type
              when '32-bit Memory Error'
                'Memory Error 32 Bit'
              when '64-bit Memory Error'
                'Memory Error 64 Bit'
              else
                type
              end

            type_camelized = Kanrisuru::Util.camelize(type.gsub(/\s/, ''))
            struct_class = Kanrisuru::Core::Dmi.const_get(type_camelized)
            struct_class.new
          end

          def parse_dmi_type(type)
            raise ArgumentError, 'Invalid DMI type' unless Kanrisuru::Util::DmiType.valid?(type)

            if type.instance_of?(Integer)
              type
            else
              Kanrisuru::Util::DmiType[type]
            end
          end
        end
      end
    end
  end
end