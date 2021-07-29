# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Dmi do
  it 'responds to dmi type fields' do
    expect(Kanrisuru::Core::Dmi::BIOS.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :vendor, :version, :release_date, :address, :runtime_size,
      :rom_size, :characteristics, :bios_revision, :firmware_revision
    )
    expect(Kanrisuru::Core::Dmi::System.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :manufacturer, :product_name, :version, :serial_number,
      :uuid, :wake_up_type, :sku_number, :family
    )
    expect(Kanrisuru::Core::Dmi::Baseboard.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :type, :manufacturer, :product_name, :version, :serial_number, :asset_tag,
      :features, :location_in_chassis, :chassis_handle, :contained_object_handles
    )
    expect(Kanrisuru::Core::Dmi::Chassis.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :manufacturer, :type, :lock, :version, :serial_number,
      :asset_tag, :boot_up_state, :power_supply_state, :thermal_state,
      :security_status, :oem_information, :height, :number_of_power_cords,
      :contained_elements, :sku_number
    )
    expect(Kanrisuru::Core::Dmi::Processor.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :socket_designation, :type, :family, :manufacturer, :id, :signature, :flags,
      :version, :voltage, :external_clock, :max_speed, :current_speed,
      :status, :upgrade, :l1_cache_handle, :l2_cache_handle, :l3_cache_handle,
      :serial_number, :asset_tag, :part_number, :core_count, :core_enabled, :thread_count,
      :characteristics
    )
    expect(Kanrisuru::Core::Dmi::MemoryController.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :error_detecting_method, :error_correcting_capabilities, :supported_interleave,
      :current_interleave, :maximum_memory_module_size, :maximum_total_memory_size,
      :supported_seeds, :supported_memory_types, :memory_module_voltage, :associated_memory_slots,
      :enabled_error_correcting_capabilities
    )
    expect(Kanrisuru::Core::Dmi::MemoryModule.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :socket_designation, :bank_connections, :current_speed, :type, :installed_size, :enabled_size,
      :error_status
    )
    expect(Kanrisuru::Core::Dmi::Cache.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :socket_designation, :configuration, :operational_mode, :location,
      :installed_size, :maximum_size, :supported_sram_types, :installed_sram_type,
      :speed, :error_correction_type, :system_type, :associativity
    )
    expect(Kanrisuru::Core::Dmi::PortConnector.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :internal_reference_designator,
      :internal_connector_type,
      :external_reference_designator,
      :external_connector_type,
      :port_type
    )
    expect(Kanrisuru::Core::Dmi::SystemSlots.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :designation, :type, :current_usage, :slot_length,
      :id, :characteristics, :bus_address,
      :data_bus_width, :peer_devices
    )
    expect(Kanrisuru::Core::Dmi::OnBoardDevice.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :type, :status, :description
    )
    expect(Kanrisuru::Core::Dmi::OEMStrings.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :strings
    )
    expect(Kanrisuru::Core::Dmi::SystemConfigurationOptions.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :options
    )
    expect(Kanrisuru::Core::Dmi::BIOSLanguage.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :language_description_format, :installed_languages, :currently_installed_language
    )
    expect(Kanrisuru::Core::Dmi::GroupAssociation.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :name, :items
    )
    expect(Kanrisuru::Core::Dmi::SystemEventLog.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :area_length, :header_start_offset, :header_length, :data_start_offset,
      :access_method, :change_token, :header_format, :supported_log_type_descriptors,
      :descriptors
    )
    expect(Kanrisuru::Core::Dmi::PhysicalMemoryArray.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :location, :use, :error_correction_type, :maximum_capacity,
      :error_information_handle, :number_of_devices
    )
    expect(Kanrisuru::Core::Dmi::MemoryDevice.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :array_handle, :error_information_handle, :total_width,
      :data_width, :mem_size, :form_factor, :set, :locator,
      :bank_locator, :type, :type_detail, :speed,
      :manufacturer, :serial_number, :asset_tag,
      :part_number, :rank, :configured_clock_speed,
      :minimum_voltage, :maximum_voltage, :configured_voltage,
      :firmware_version, :model_manufacturer_id, :module_product_id,
      :memory_subsystem_controller_manufacturer_id,
      :memory_subsystem_controller_product_id,
      :non_volatile_size, :cache_size, :logical_size
    )
    expect(Kanrisuru::Core::Dmi::MemoryError32Bit.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :type, :granularity, :operation, :vendor_syndrome, :memory_array_address,
      :device_address, :resolution
    )
    expect(Kanrisuru::Core::Dmi::MemoryArrayMappedAddress.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :starting_address, :ending_address, :range_size,
      :physical_array_handle, :partition_width
    )
    expect(Kanrisuru::Core::Dmi::MemoryDeviceMappedAddress.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :starting_address, :ending_address, :range_size,
      :physical_device_handle, :memory_array_mapped_address_handle,
      :partition_row_position, :interleave_position,
      :interleaved_data_depth
    )
    expect(Kanrisuru::Core::Dmi::BuiltInPointingDevice.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :type, :inteface, :buttons
    )
    expect(Kanrisuru::Core::Dmi::PortableBattery.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :location, :manufacturer, :manufacture_date,
      :serial_number, :name, :chemistry,
      :design_capacity, :design_voltage, :maximum_error,
      :sbds_version, :sbds_serial_number, :sbds_manufacturer_date,
      :sbds_chemistry, :oem_specific_information
    )
    expect(Kanrisuru::Core::Dmi::SystemReset.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :status, :watchdog_timer, :boot_option,
      :boot_option_on_limit, :timer_interval,
      :reset_count, :reset_limit, :timeout
    )
    expect(Kanrisuru::Core::Dmi::HardwareSecurity.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :power_on_password_status, :keyboard_password_status,
      :administrator_password_status, :front_panel_reset_status
    )
    expect(Kanrisuru::Core::Dmi::SystemPowerControls.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :next_scheduled_power_on
    )
    expect(Kanrisuru::Core::Dmi::VoltageProbe.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :description, :location, :status, :maximum_value,
      :minimum_value, :resolution, :tolerance, :accuracy,
      :oem_specific_information, :nominal_value
    )
    expect(Kanrisuru::Core::Dmi::CoolingDevice.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :temperature_probe_handle, :type,
      :status, :cooling_unit_group, :oem_specific_information,
      :nominal_speed, :description
    )
    expect(Kanrisuru::Core::Dmi::TemperatureProbe.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :description, :location, :status,
      :maximum_value, :minimum_value, :resolution,
      :tolerance, :accuracy, :oem_specific_information,
      :nominal_value
    )
    expect(Kanrisuru::Core::Dmi::ElectricalCurrentProbe.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :description, :location, :status,
      :maximum_value, :minimum_value, :resolution,
      :tolerance, :accuracy, :oem_specific_information,
      :nominal_value
    )
    expect(Kanrisuru::Core::Dmi::OutOfBandRemoteAccess.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :manufacturer_name, :inbound_connection,
      :outbound_connection
    )
    expect(Kanrisuru::Core::Dmi::BootIntegrityServices.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :checksum,
      :sixteen_bit_entry_point_address,
      :thirty_two_bit_entry_point_address
    )
    expect(Kanrisuru::Core::Dmi::SystemBoot.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :status
    )
    expect(Kanrisuru::Core::Dmi::MemoryError64Bit.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :type, :granularity, :operation, :vendor_syndrome, :memory_array_address,
      :device_address, :resolution
    )
    expect(Kanrisuru::Core::Dmi::ManagementDevice.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :description, :type, :address, :address_type
    )
    expect(Kanrisuru::Core::Dmi::ManagementDeviceComponent.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :description, :management_device_handle, :component_handle,
      :threshold_handle
    )
    expect(Kanrisuru::Core::Dmi::ManagementDeviceThresholdData.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :lower_non_critical_threshold,
      :upper_non_critical_threshold,
      :lower_critical_threshold,
      :upper_critical_threshold,
      :lower_non_recoverable_threshold,
      :upper_non_recoverable_threshold
    )
    expect(Kanrisuru::Core::Dmi::MemoryChannelDevice.new).to respond_to(
      :load,
      :handle
    )
    expect(Kanrisuru::Core::Dmi::MemoryChannel.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :type, :maximal_load, :devices
    )
    expect(Kanrisuru::Core::Dmi::IPMIDevice.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :interface_type, :specification_version, :i2c_slave_address,
      :nv_storage_device_address, :nv_storage_device, :base_address, :register_spacing,
      :interrupt_polarity, :interrupt_trigger_mode, :interrupt_number
    )
    expect(Kanrisuru::Core::Dmi::SystemPowerSupply.new).to respond_to(
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
    expect(Kanrisuru::Core::Dmi::AdditionalInformation.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :referenced_handle, :referenced_offset,
      :string, :value
    )
    expect(Kanrisuru::Core::Dmi::OnboardDevicesExtendedInformation.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :reference_designation, :type, :status,
      :type_instance, :bus_address
    )
    expect(Kanrisuru::Core::Dmi::ProtocolRecord.new).to respond_to(
      :protocol_id,
      :protocol_type_specific_data
    )
    expect(Kanrisuru::Core::Dmi::ManagementControllerHostInterface.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :interface_type, :vendor_id, :device_type,
      :protocol_records, :host_ip_assignment_type, :host_ip_address_format
    )
    expect(Kanrisuru::Core::Dmi::TPMDevice.new).to respond_to(
      :dmi_type, :dmi_handle, :dmi_size,
      :specification_version, :firmware_revision,
      :description, :characteristics, :oem_specific_information
    )
  end
end
