
module Kanrisuru
  module Core
    module Dmi
      ## Type 0: BIOS Information
      BIOS = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :vendor, :version, :release_date, :address, :runtime_size,
        :rom_size, :characteristics, :bios_revision, :firmware_revision
      )

      ## Type 1: Sytem Information
      System = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :manufacturer, :product_name, :version, :serial_number,
        :uuid, :wake_up_type, :sku_number, :family
      )

      ## Type 2: Baseboard Information
      Baseboard = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :type, :manufacturer, :product_name, :version, :serial_number, :asset_tag,
        :features, :location_in_chassis, :chassis_handle, :contained_object_handles
      )

      ## Type 3: Chassis Information
      Chassis = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :manufacturer, :type, :lock, :version, :serial_number,
        :asset_tag, :boot_up_state, :power_supply_state, :thermal_state,
        :security_status, :oem_information, :height, :number_of_power_cords,
        :contained_elements, :sku_number
      )

      ## Type 4: Processor Information
      Processor = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :socket_designation, :type, :family, :manufacturer, :id, :signature, :flags,
        :version, :voltage, :external_clock, :max_speed, :current_speed,
        :status, :upgrade, :l1_cache_handle, :l2_cache_handle, :l3_cache_handle,
        :serial_number, :asset_tag, :part_number, :core_count, :core_enabled, :thread_count,
        :characteristics
      )

      ## Type 5: Memory Controller Information
      MemoryController = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :error_detecting_method, :error_correcting_capabilities, :supported_interleave,
        :current_interleave, :maximum_memory_module_size, :maximum_total_memory_size,
        :supported_seeds, :supported_memory_types, :memory_module_voltage, :associated_memory_slots,
        :enabled_error_correcting_capabilities
      )

      ## Type 6: Memory Module Information
      MemoryModule = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :socket_designation, :bank_connections, :current_speed, :type, :installed_size, :enabled_size,
        :error_status
      )

      ## Type 7: Cache Information
      Cache = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :socket_designation, :configuration, :operational_mode, :location,
        :installed_size, :maximum_size, :supported_sram_types, :installed_sram_type,
        :speed, :error_correction_type, :system_type, :associativity
      )

      ## Type 8: Port Connector Information
      PortConnector = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :internal_reference_designator,
        :internal_connector_type,
        :external_reference_designator,
        :external_connector_type,
        :port_type
      )

      ## Type 9: Sytem Slots
      SystemSlots = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :designation, :type, :current_usage, :slot_length,
        :id, :characteristics, :bus_address,
        :data_bus_width, :peer_devices
      )

      ## Type 10: On Board Device Information
      OnBoardDevice = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :type, :status, :description
      )

      ## Type 11: OEM Strings
      OEMStrings = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :strings
      )

      ## Type 12: System Configuration Options
      SystemConfigurationOptions = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :options
      )

      ## Type 13: BIOS Language Information
      BIOSLanguage = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :language_description_format, :installed_languages, :currently_installed_language
      )

      ## Type 14: Group Associations
      GroupAssociation = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :name, :items
      )

      ## Type 15: System Event Log
      SystemEventLog = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :area_length, :header_start_offset, :header_length, :data_start_offset,
        :access_method, :change_token, :header_format, :supported_log_type_descriptors,
        :descriptors
      )

      ## Type 16: Physical Memory Array
      PhysicalMemoryArray = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :location, :use, :error_correction_type, :maximum_capacity,
        :error_information_handle, :number_of_devices
      )

      ## Type 17: Memory Device
      MemoryDevice = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :array_handle, :error_information_handle, :total_width,
        :data_width, :mem_size, :form_factor, :set, :locator,
        :bank_locator, :type, :type_detail, :speed,
        :manufacturer, :serial_number, :asset_tag,
        :part_number, :rank, :configured_clock_speed,
        :minimum_voltage, :maximum_voltage,
        :configured_voltage, :configured_memory_speed,
        :firmware_version, :model_manufacturer_id, :module_product_id,
        :memory_subsystem_controller_manufacturer_id,
        :memory_subsystem_controller_product_id,
        :non_volatile_size, :cache_size, :logical_size
      )

      ## Type 18: 32-bit Memory Error Information
      MemoryError32Bit = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :type, :granularity, :operation, :vendor_syndrome, :memory_array_address,
        :device_address, :resolution
      )

      ## Type 19: Memory Array Mapped Address
      MemoryArrayMappedAddress = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :starting_address, :ending_address, :range_size,
        :physical_array_handle, :partition_width
      )

      ## Type 20: Memory Device Mapped Address
      MemoryDeviceMappedAddress = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :starting_address, :ending_address, :range_size,
        :physical_device_handle, :memory_array_mapped_address_handle,
        :partition_row_position, :interleave_position,
        :interleaved_data_depth
      )

      ## Type 21: Built-In Pointing Device
      BuiltInPointingDevice = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :type, :inteface, :buttons
      )

      ## Type 22: Portable Battery
      PortableBattery = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :location, :manufacturer, :manufacture_date,
        :serial_number, :name, :chemistry,
        :design_capacity, :design_voltage, :maximum_error,
        :sbds_version, :sbds_serial_number, :sbds_manufacturer_date,
        :sbds_chemistry, :oem_specific_information
      )

      ## Type 23: System Reset
      SystemReset = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :status, :watchdog_timer, :boot_option,
        :boot_option_on_limit, :timer_interval,
        :reset_count, :reset_limit, :timeout
      )

      ## Type 24: Hardware Security
      HardwareSecurity = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :power_on_password_status, :keyboard_password_status,
        :administrator_password_status, :front_panel_reset_status
      )

      ## Type 25: System Power Controls
      SystemPowerControls = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :next_scheduled_power_on
      )

      ## Type 26: Voltage Probe
      VoltageProbe = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :description, :location, :status, :maximum_value,
        :minimum_value, :resolution, :tolerance, :accuracy,
        :oem_specific_information, :nominal_value
      )

      ## Type 27: Cooling Device
      CoolingDevice = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :temperature_probe_handle, :type,
        :status, :cooling_unit_group, :oem_specific_information,
        :nominal_speed, :description
      )

      ## Type 28: Temperature Probe
      TemperatureProbe = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :description, :location, :status,
        :maximum_value, :minimum_value, :resolution,
        :tolerance, :accuracy, :oem_specific_information,
        :nominal_value
      )

      ## Type 29: Electrical Current Probe
      ElectricalCurrentProbe = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :description, :location, :status,
        :maximum_value, :minimum_value, :resolution,
        :tolerance, :accuracy, :oem_specific_information,
        :nominal_value
      )

      ## Type 30: Out-of-band Remote Access
      OutOfBandRemoteAccess = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :manufacturer_name, :inbound_connection,
        :outbound_connection
      )

      ## Type 31: Boot Integrity Services Entry Point
      BootIntegrityServices = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :checksum,
        :sixteen_bit_entry_point_address,
        :thirty_two_bit_entry_point_address
      )

      ## Type 32: System Boot
      SystemBoot = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :status
      )

      ## Type 33: 64-bit Memory Error
      MemoryError64Bit = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :type, :granularity, :operation, :vendor_syndrome, :memory_array_address,
        :device_address, :resolution
      )

      ## Type 34: Management Device
      ManagementDevice = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :description, :type, :address, :address_type
      )

      ## Type 35: Management Device Component
      ManagementDeviceComponent = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :description, :management_device_handle, :component_handle,
        :threshold_handle
      )

      ## Type 36: Management Device Threshold Data
      ManagementDeviceThresholdData = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :lower_non_critical_threshold,
        :upper_non_critical_threshold,
        :lower_critical_threshold,
        :upper_critical_threshold,
        :lower_non_recoverable_threshold,
        :upper_non_recoverable_threshold
      )

      ## Type 37: Memory Channel
      MemoryChannelDevice = Struct.new(
        :load,
        :handle
      )

      MemoryChannel = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :type, :maximal_load, :devices
      )

      ## Type 38: IPMI Device Information
      IPMIDevice = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :interface_type, :specification_version, :i2c_slave_address,
        :nv_storage_device_address, :nv_storage_device, :base_address, :register_spacing,
        :interrupt_polarity, :interrupt_trigger_mode, :interrupt_number
      )

      ## Type 39: System Power Supply
      SystemPowerSupply = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :power_unit_group, :location, :name,
        :manufacturer, :serial_number, :asset_tag, :model_part_number,
        :revision, :max_power_capacity, :status,
        :type, :input_voltage_range_switching,
        :plugged, :hot_replaceable,
        :input_voltage_probe_handle,
        :cooling_device_handle,
        :input_current_probe_handle
      )

      ## Type 40: Additional Information
      AdditionalInformation = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :referenced_handle, :referenced_offset,
        :string, :value
      )

      ## Type 41: On Board Devices Extended Information
      OnboardDevicesExtendedInformation = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :reference_designation, :type, :status,
        :type_instance, :bus_address
      )

      ## Type 42: Management Controller Host Interface
      ProtocolRecord = Struct.new(
        :protocol_id,
        :protocol_type_specific_data
      )

      ManagementControllerHostInterface = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :interface_type, :vendor_id, :device_type,
        :protocol_records, :host_ip_assignment_type, :host_ip_address_format
      )

      ## Type 43: TPM Device
      TPMDevice = Struct.new(
        :dmi_type, :dmi_handle, :dmi_size,
        :specification_version, :firmware_revision,
        :description, :characteristics, :oem_specific_information
      )
    end
  end
end
