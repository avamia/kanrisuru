# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Remote::Cpu do
  before(:all) do
    StubNetwork.stub!
  end

  after(:all) do
    StubNetwork.unstub!
  end

  context 'metal' do
    let(:host) do
      Kanrisuru::Remote::Host.new(
        host: 'metal-host',
        username: 'ubuntu',
        keys: ['id_rsa']
      )
    end

    before do
      StubNetwork.stub_command!(:lscpu) do |_args|
        struct = Kanrisuru::Core::System::CPUArchitecture.new
        struct.architecture = 'x86_64'
        struct.cores = 48
        struct.byte_order = 'Little Endian'
        struct.address_sizes = ['46 bits physical', '48 bits virtual']
        struct.operation_modes = %w[32-bit 64-bit]
        struct.online_cpus = 0
        struct.threads_per_core = 2
        struct.cores_per_socket = 12
        struct.sockets = 2
        struct.numa_mode = nil
        struct.vendor_id = 'GenuineIntel'
        struct.cpu_family = 6
        struct.model = 63
        struct.model_name = 'Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz'
        struct.stepping = 2
        struct.cpu_mhz = 1200.16
        struct.cpu_max_mhz = 3300.0
        struct.cpu_min_mhz = 1200.0
        struct.bogo_mips = nil
        struct.virtualization = 'VT-x'
        struct.hypervisor_vendor = nil
        struct.virtualization_type = nil
        struct.l1d_cache = '768 KiB'
        struct.l1i_cache = '768 KiB'
        struct.l2_cache = '6 MiB'
        struct.l3_cache = '60 MiB'
        struct.numa_nodes = 2
        struct.vulnerabilities = [
          Kanrisuru::Core::System::CPUArchitectureVulnerability.new('Itlb multihit',
                                                                    'KVM: Mitigation: Split huge pages'),
          Kanrisuru::Core::System::CPUArchitectureVulnerability.new('L1tf',
                                                                    'Mitigation; PTE Inversion; VMX conditional cache flushes, SMT vulnerable'),
          Kanrisuru::Core::System::CPUArchitectureVulnerability.new('Mds',
                                                                    'Mitigation; Clear CPU buffers; SMT vulnerable'),
          Kanrisuru::Core::System::CPUArchitectureVulnerability.new('Meltdown', 'Mitigation; PTI'),
          Kanrisuru::Core::System::CPUArchitectureVulnerability.new('Spec store bypass',
                                                                    'Mitigation; Speculative Store Bypass disabled via prctl and seccomp'),
          Kanrisuru::Core::System::CPUArchitectureVulnerability.new('Spectre v1',
                                                                    'Mitigation; usercopy/swapgs barriers and __user pointer sanitization'),
          Kanrisuru::Core::System::CPUArchitectureVulnerability.new('Spectre v2',
                                                                    'Mitigation; Full generic retpoline, IBPB conditional, IBRS_FW, STIBP conditional, RSB filling'),
          Kanrisuru::Core::System::CPUArchitectureVulnerability.new('Srbds', 'Not affected'),
          Kanrisuru::Core::System::CPUArchitectureVulnerability.new('Tsx async abort', 'Not affected')
        ]
        struct.flags = %w[fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
                          mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid dca sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm cpuid_fault epb invpcid_single pti intel_ppin ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid cqm xsaveopt cqm_llc cqm_occup_llc dtherm ida arat pln pts md_clear flush_l1d]
        struct
      end
    end

    after do
      StubNetwork.unstub_command!(:lscpu)
    end

    it 'gets host cpu attributes' do
      expect(host.cpu.architecture).to eq('x86_64')
      expect(host.cpu.cores).to eq(48)
      expect(host.cpu.byte_order).to eq('Little Endian')
      expect(host.cpu.address_sizes).to eq(['46 bits physical', '48 bits virtual'])
      expect(host.cpu.threads_per_core).to eq(2)
      expect(host.cpu.cores_per_socket).to eq(12)
      expect(host.cpu.sockets).to eq(2)
      expect(host.cpu.vendor_id).to eq('GenuineIntel')
      expect(host.cpu.cpu_family).to eq(6)
      expect(host.cpu.model).to eq(63)
      expect(host.cpu.model_name).to eq('Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz')
      expect(host.cpu.cpu_mhz).to eq(1200.16)
      expect(host.cpu.cpu_max_mhz).to eq(3300.0)
      expect(host.cpu.cpu_min_mhz).to eq(1200.0)
      expect(host.cpu.hypervisor).to be_nil
      expect(host.cpu.virtualization_type).to be_nil
      # expect(host.cpu.l1d_cache).to eq("768 KiB")
      # expect(host.cpu.l1i_cache).to eq("768 KiB")
      # expect(host.cpu.l2_cache).to eq("6 MiB")
      # expect(host.cpu.l3_cache).to eq("60 MiB")
      expect(host.cpu.numa_nodes).to eq(2)
    end
  end
end
