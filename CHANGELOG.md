## Kanrisuru 1.0.0.beta1 (February 27, 2022) ##
*  Add parallel mode for cluster. Allows hosts to run commands concurrently, reducing time it takes due to the high I/O blocking nature of the network requests.
*  Add test cases for cluster parallel mode.
*  Clean up methods on cluster class to use map and each methods in a simplified manner.
*  Remove `/spec` dir from codecoverage.

## Kanrisuru 0.20.0 (February 21, 2022) ##
*  Allow hosts to be connected via proxy host. This is much like using a bastion / jump server. 
*  Add integration test cases for proxy host connection. 

## Kanrisuru 0.19.4 (February 19, 2022) ##
*  Add additional family types to `ss` command.

## Kanrisuru 0.19.3 (February 19, 2022) ##
*  Fix bug in `ss` command with passing opts to parser.

## Kanrisuru 0.19.2 (February 02, 2022) ##
*  Add `to_h` to result class.

## Kanrisuru 0.19.1 (February 02, 2022) ##
*  Fix `load_env` command with parsing output, use `to_a` for cleaner newline parsing.

## Kanrisuru 0.19.0 (January 25, 2022) ##
*  Add readonly version of `sysctl` command with test cases.

## Kanrisuru 0.18.0 (January 23, 2022) ##
*  Add `history` command with test cases.

## Kanrisuru 0.17.0 (January 20, 2022) ##
*  Add `nproc` command with test cases.

## Kanrisuru 0.16.17 (January 10, 2022) ##
*  Add additional options to `wget` command.
*  Rename some options to better reflect options from wget program.

## Kanrisuru 0.16.16 (January 08, 2022) ##
*  Fix issue with `download` command when downloading directories from remote server.

## Kanrisuru 0.16.15 (January 07, 2022) ##
*  Add recursive and all_targets opts to `umount` command.

## Kanrisuru 0.16.14 (January 02, 2022) ##
*  Fix `get_user` command by parsing output to get user name if uid is passed in. 

## Kanrisuru 0.16.13 (January 01, 2022) ##
*  Add `non_unique` and `system` opts to `create_group` command

## Kanrisuru 0.16.12 (January 01, 2022) ## 
*  Update date ranges for 2022 on license files.
*  Add unit test case for `Kanrisuru::Logger`.

## Kanrisuru 0.16.11 (December 28, 2021) ##
*  Add functional and integration test cases for the `Kanrisuru::Remote::Cluster` class.
*  Allow for passing a command instance into `execute` and `execute_shell` on a cluster instance, by deep copying a command object. 

## Kanrisuru 0.16.10 (December 28, 2021) ##
*  Add `iname` and `iregex` params to `find` command.

## Kanrisuru 0.16.9 (December 27, 2021) ##
*  Use cp intead of mv for recurisive dir overwrite on upload command.

## Kanrisuru 0.16.8 (December 27, 2021) ##
*  Fix return value of field for dmi parser.
*  Fix upload command to copy contents of directory when transfering directories from tmp location.

## Kanrisuru 0.16.7 (December 27, 2021) ##
*  Update homepage to docs website.

## Kanrisuru 0.16.6 (December 26, 2021) ##
*  Add `delete` to fstab class to delete an entry from the fstab.

## Kanrisuru 0.16.5 (December 25, 2021) ##
*  Refactor `dmi_field_translate` to reduce complexity.

## Kanrisuru 0.16.4 (December 25, 2021) ##
*  Refactor `Kanrisuru::Fstab::Entry` and `Kanrisuru::Fstab::Options` classes into separate files.

## Kanrisuru 0.16.3 (December 25, 2021) ##
*  Refactor `Kanrisuru::Mode::Permission` class into separate file.

## Kanrisuru 0.16.2 (December 19, 2021) ##
*  Organize functional ip specs
*  Log in realtime, debug output the stdout from the remote server, as opposed to waiting until after the command is done.
*  Fix the `opensuse_leap` for the stubnetwork rspec helper.
*  Refactor and cleanup the `append_array` method for the `Kanrisuru::Command` instance
*  Move `gpg_opts` for `zypper` command into re-usable method
*  Add functional test cases for `zypper` command. 

## Kanrisuru 0.16.1 (December 16, 2021) ##
*  Fix require class for `os_package`.

## Kanrisuru 0.16.0 (December 14, 2021) ##
*  Fix `append_array` for the `Kanrisuru::Command` class with negated check on Array type.
*  Add `to_f` method for `Kanrisuru::Command` and `Kanrisuru::Result` with unit test cases.
*  Refactor `lsblk_version` into seperate command namespace with it's own parser.
*  Add functional test cases for several core modules.
*  Add `return_value` option to `stub_command!` method for non-result return methods. These are few and far between, but need to be tested appropriately. 
*  Refactor several core modules with use of `command` calls for legibility.
*  Fix several issues with `create_user`, `update_user`, and `delete_user`.

## Kanrisuru 0.15.0 (December 13, 2021) ##
*  Add opts for `ip` command.
*  Refactor `ip` object commands into smaller methods. Refactor `version` for consistent use and stub ability in funcitonal test cases.
*  Add functional test cases for `ip` command.
*  Add `append_flag_no` to `Kanrisuru::Command` class. Adds no to value for `falsey` statements. The `no` flag is commonly appended to indicate a deactived state for many arguments passed to programs on the command line.
*  Fix test case `transfer` by appending the osname to the filename to avoid parallel overwrite.

## Kanrisuru 0.14.0 (December 08, 2021) ##
*  Add additional unit test cases for `util` methods.
*  Refactor the `core` module commands into smaller files, with each command split up. Also refactor parsing code into separate `Parser` class.
 
## Kanrisuru 0.13.0 (December 06, 2021) ##
*  Add functional test cases for `Kanrisuru::Result` class.
*  Refactor integration tests for better parallelization with the `parallel_tests` gem. This dropped overall test time from 35 minutes, to 22 minutes after first integration with 1 processor. After scaling upto 8 core machine, the run time dropped to 16 minutes, but was still sending the entire test file to a processor. By splitting up each host test into a seperate file, the run time dropped to a little over 9 minutes. There's probably a way to optimize which test gets run together, but overall a much better scenario.

## Kanrisuru 0.12.1 (December 05, 2021) ##
*  Fix typo in spec.
*  Cleanup bad code style.

## Kanrisuru 0.12.0 (December 05, 2021) ##
*  Add functional test cases for `mount` command.
*  Fix typos and command preperation for `mount` command.
*  Refactor `os_package` module into smaller modules for `Kanrisuru::OsPackage::Collection`, `Kanrisuru::OsPackage::Define`, and `Kanrisuru::OsPackage::Include`.
*  Add `append_array` to `command` class for easy string to array conversion for variable option passing.
*  Cleanup bad coding styles.
*  Add parallel testing support for long running integration tests on remote servers. 
*  Refactor specs to use variable spec_dir path for parallel testing on remote hosts with possible overwriting at the same time.

## Kanrisuru 0.11.1 (December 04, 2021) ##
*  Cleanup self-assignment branches
*  Fix linting issues.

## Kanrisuru 0.11.0 (December 04, 2021) ##
*  Add codequality badge, cleanup code linting issues.
*  Fix `fstab` issue with blkid device return type.
*  Fix `find` spec with sudo permissions.
*  Change `stub_network` result override to use `block.call` with a conditional check for indvidual command stubs.
*  Add `architecture` method to `cpu`.
*  Add functional test cases for `cpu` class.
*  Add more unit test cases.

## Kanrisuru 0.10.0 (December 03, 2021) ##
*  Add `stub_command` and `unstub_command` to mock indvidual command results from a remote server.
*  Add `count` and `delete` to `Kanrisuru::Remote::Env` class for managing environment variables.
*  Add unit and functional test cases for `Kanrisuru::Remote::Env`.
*  Add functional test cases for the `archive` command.
*  Fix typo bugs in the `archive` command. Fix `--exclude` opt field in `archive` command.
*  Add unit test cases for `Kanrisuru::Mode` class.

## Kanrisuru 0.9.2 (November 30, 2021) ##
*  Add unit test cases for all core commands.
*  Add unit test cases for `cluster` class. 
*  Add codecov xml output for coverage badge.

## Kanrisuru 0.9.1 (November 29, 2021) ##
*  Fix type on `address_sizes` for `Kanrisuru::Remote::Cpu` class.
*  Add unit test cases for the `cpu` class.

## Kanrisuru 0.9.0 (November 23, 2021) ##
*  Add `delete` to `Kanrisuru::Remote::Cluster` class to allow removal of hosts from cluster.
*  Add functional test cases for remote cluster class. 

## Kanrisuru 0.8.23 (November 19, 2021) ##
*  Add functional test cases for `yum` command
*  Add stub by operating system method, with support for `ubuntu` and `centos` os types. 
*  Fix `ArgumentError` typo in yum commands, `erase` and `remove`.

## Kanrisuru 0.8.22 (November 18, 2021) ##
*  Add functional test cases for `apt` command

## Kanrisuru 0.8.21 (November 15, 2021) ##
*  Fix bug with `Kanrisuru::Mode` class, lookup table had incorrect value for execute only symbolic to numeric field.

## Kanrisuru 0.8.20 (November 13, 2021) ##
*  Unstub network requests for full rspec test-suite run

## Kanrisuru 0.8.19 (October 31, 2021) ##
*  Add functional test cases for `ss` command.
*  Enforce contraints on `family` parameter for `ss` command.
*  Deprecating `string_join_array` in favor of `array_join_string`. Both methods do the same thing, and the `array_join_string` has a better nameing interface; will be removed in the next major release.
*  Replace `string_join_array` method calls in `apt`, `transfer`, `yum`, and `zypper` with `array_join_string`. 

## Kanrisuru 0.8.18 (October 19, 2021) ##
*  Add functional test cases for `find` commmand.
*  Add `regex_type` option for `find` command.
*  Fix bug with `size` option when using number in a string format, regex testing has been simplified on matching correctness for size with options like `100`, `+100`, `-100M` for comparitive fields.

## Kanrisuru 0.8.17 (October 16, 2021) ##
*  Add functional test cases for `transfer` module
*  Update wget command to accept hash for `headers` opt.

## Kanrisuru 0.8.16 (October 14, 2021) ##
*  Add functional test cases for `stream` and `path` modules
*  Create `expect_command`  helper for quick testing on raw command result

## Kanrisuru 0.8.15 (October 12, 20201) ##
*  Move functional specs to integration. Anything that performs an actual network request will be under the integrations test.
*  Create a `StubNetwork` to quickly monkey patch the `Kanrisuru::Remote::Host` to simulate a `Net::SSH` channel request. Will add additional functionality for different simulations later on.
*  Start with testing the `stat` command as a functional test.

## Kanrisuru 0.8.14 (October 8, 20201) ##
*  Update `Kanrisuru::Remote::Cluster` instantiation method to use array splat instead of passing array directly.

## Kanrisuru 0.8.13 (October 4, 20201) ##
*  Fix `wc` command. Ensure result parsing is cast to integer values.

## Kanrisuru 0.8.12 (October 4, 20201) ##
*  Refactor `rmdir` command to only work on empty directories. 

## Kanrisuru 0.8.11 (October 1, 20201) ##
*  Allow `Kanrisuru::Mode` as mode type option in mkdir method.

## Kanrisuru 0.8.10 (August 24, 20201) ##
*  Fix bug with rspec test case.

## Kanrisuru 0.8.9 (August 24, 2021) ##
*  Fix spelling error exception `ArgumentError` in `Kanrisuru::Mode` class.

## Kanrisuru 0.8.8 (August 21, 2021) ##
*  Add shorthand notation for tar command actions, such as `x` for `extract`, `t` for `list`, and `c` for `create`. 

## Kanrisuru 0.8.7 (August 21, 2021) ##
*  Fix `FileInfo` field for ls command. Was set to `memory_blocks`, but was incorrect, corrected this to `hard_links`.

## Kanrisuru 0.8.6 (August 21, 2021) ##
*  Add `minimum_io_size`, `physical_sector_size`, and `logical_sector_size` to the blkid low level disk probe for devices.

## Kanrisuru 0.8.5 (August 20, 2021) ##
*  Add `summarize` option to `du` command. This will only output a total disk usage size for the entire directory versus disk usage for each file individually.

## Kanrisuru 0.8.4 (August 20, 2021) ##
*  Convert `fsize` field to an `integer` for du disk module command.

## Kanrisuru 0.8.3 (August 20, 2021) ##
*  Fix bug with disk usage, `du` command by escaping the awk variables in the command.
*  Update `du` command to execute with shell user.

## Kanrisuru 0.8.2 (August 19, 2021) ##
*  Convert `major` and `minor` device field values to an `integer` in lsblk disk module.

## Kanrisuru 0.8.1 (August 19, 2021) ##
*  Fix `nodeps` flag value for `lsblk` command in disk module. 

## Kanrisuru 0.8.0 (August 18, 2021) ##
*  Add last / lastb implementation in system core module. 

## Kanrisuru 0.7.3 (August 9, 2021) ##
*  Fixed bug with zypper remove package, where the package names weren't being added to the linux command. 
*  Test case added to ensure package is removed.

## Kanrisuru 0.7.2 (August 9, 2021) ##
*  Fixed bug with the `os_method_cache` instance variable set in the namespaced instance of a host. This was causing collision issues inbetween host instances, where, hosts with the same aliased method name was getting overwritten (with a different OS), since the namespace instance variable existing on the host class definition wasn't getting reset inbetween host instantiations. Given that the `os_method_cache` is normally re-instantiated, this bug fix addresses this so that the `os_method_cache` is always defined on the host instance, ie:

  ```ruby
  host.instance_variable_get(:@os_method_cache)
  host.instance_variable_set(:@os_method_cache, os_method_cache)
  ```
  This is done instead of being saved on the namespace module. With the previous bug fix of using namespaced keys, there's no way for a method to be overwritten otherwise with a global `os_method_cache`.

## Kanrisuru 0.7.1 (August 8, 2021) ##
*  Fix bug with `os_include` when caching namespace unbound methods, use the namespace in the 
cache key to avoid any namespace collisions with the same method name, namely:
```ruby
"#{namespace}.#{method_name}"
```

## Kanrisuru 0.7.0 (August 8, 2021) ##
*  Simplify `FileInfo` struct for return object of `ls` command.
*  Rename `size` to `fsize` for the `OpenFile` struct to avoid method naming conflicts of the struct class. 
*  Allow `os_include` and `os_collection` to define multiple groupings of methods with the same namespace.
*  Add `clear` method for remote env class, to remove any session based env variables.
*  Add `to_s` method to result for quick analysis of string based return values. 
*  Remove duplicate `numeric` method in the utils module.

## Kanrisuru 0.6.0 (August 1, 2021) ##
*  Add `lsof` implementation in system core module
*  Fix changelog formatting
*  Add changelog url to gemspec

## Kanrisuru 0.5.2 (July 30, 2021) ##
*  Add changelog documentation
*  Update documentation table with new tested core module 
*  Deprecating `cpu_info` with replacement of `lscpu`. `cpu_info` will be removed in the next major release.

## Kanrisuru 0.5.1 (July 29, 2021) ##
*  Unit test cases for core module structs, constants and types. 

## Kanrisuru 0.5.0 (July 29, 2021) ##
*  Add `zypper` package manager core module
*  Add `dmi` core module. Support for getting hardware information from virtual and physical machines.
*  Add only options for test_hosts to filter on which hosts to use for function style test cases. This is used within a test case and takes priority over command line `HOSTS=` and `EXCLUDE=` env variables. 
*  Add additional bit conversion string handling in the util module, such as kib, mib, and gib.
*  Remove redudant namespacing in struct names, such as 
`Kanrisuru::Core::Yum::YumPackageOverview`, to `Kanrisuru::Core::Yum::PackageOverview`.
*  Fix backups test case for `cp` command with the correct filename.
*  Use 0755 as expected numeric mode for all OS functional tests in the `mkdir` test case.
*  Fix bug with `lscpu` regex match on cpus with more than 9 cores, ie `/cpu\d/` to `/cpu\d+/`

 
## Kanrisuru 0.4.1 (July 26, 2021) ##
*  Add `kernel_statistics` to system core module. 

## Kanrisuru 0.4.0 (July 25, 2021) ##
*  Update internal exit code of command from 0, to array of accpeted exit codes, with 0 being the default value.
*  Add `append_exit_code` to command, allowing additional exit codes to be considered true for `success?` return value.
*  Add `@port` to `Net::SSH.start` method
*  Fix test case with `host.os` return value of `opensuse_leap`.
*  Add `cpu_flags` method to `cpu` module

## Kanrisuru 0.3.2 (July 23, 2021) ##
*  Fix typo from `key` to `signal` in hash fetch method. 

## Kanrisuru 0.3.1 (July 22, 2021) ##
*  Add additional methods to `cpu` pulling from `lscpu` struct.
*  Fix `address_size` in `cpu` method call.

## Kanrisuru 0.3.0 (July 22, 2021) ##
*  Add `lscpu` system core module 
*  Replace `cpu` module internal fetching of data from `cpu_info` to `lscpu` struct.
 
## Kanrisuru 0.2.9 (July 20, 2021) ##
*  Fix fstab entry from `entry` to `entry[:entry]` in the `for_each`iteration. 

## Kanrisuru 0.2.8 (July 20, 2021) ##
*  Update gem development and runtime depedencies with stricter depencies.

## Kanrisuru 0.2.7 (July 18, 2021) ##
*  Set opensuse upstream to sles (Suse Enterprise Linux) in `os_family`

## Kanrisuru 0.2.6 (July 17, 2021) ##
*  Force "-" to "\_" from `os-release` release name in `host.os` module.

## Kanrisuru 0.2.5 (July 16, 2021) ##
*  Update gem depedencies to non-zero values.
*  Change summary and description fields for `apt`. 
*  Move `normalize_size` from `apt` core module, to `Kanrisuru::Util::Bits` class.
*  Add additional test cases for `apt` core module.
*  Add `-hi` to `who` command to explicility print out ip address for user.
*  Update `inode?` command to execute without shell user. 
*  Add `yum` package manager core module

## Kanrisuru 0.2.4 (July 10, 2021) ##
*  Fix error in `ip_rule` and `ip_address` sub modules with command typo. 

## Kanrisuru 0.2.3 (July 07, 2021) ##
*  Add `apt` package manager core module

## Kanrisuru 0.2.2 (June 16, 2021) ##
*  Fix `read_file_chunk` on checking bounds for start and end line values.

## Kanrisuru 0.2.1 (June 16, 2021) ##
*  Add first working release on rubygems.org

## Kanrisuru 0.2.0 (June 16, 2021) [YANKED] ##

## Kanrisuru 0.1.0 (December 12, 2020) ##
*  Initialize repository, start working on project.
