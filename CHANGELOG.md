## Kanrisuru 0.6.0 (August 1, 2021) ##
* Add lsof implementation in system core module
* Fix changelog formatting
* Add changelog url to gemspec

## Kanrisuru 0.5.2 (July 30, 2021) ##
* Add changelog documentation
* Update documentation table with new tested core module 
* Deprecating `cpu_info` with replacement of `lscpu`. `cpu_info` will be removed in the next major release.

## Kanrisuru 0.5.1 (July 29, 2021) ##

* Unit test cases for core module structs, constants and types. 

## Kanrisuru 0.5.0 (July 29, 2021) ##
* Add `zypper` package manager core module
* Add `dmi` core module. Support for getting hardware information from virtual and physical machines.
* Add only options for test_hosts to filter on which hosts to use for function style test cases. This is used within a test case and takes priority over command line `HOSTS=` and `EXCLUDE=` env variables. 
* Add additional bit conversion string handling in the util module, such as kib, mib, and gib.
* Remove redudant namespacing in struct names, such as 
`Kanrisuru::Core::Yum::YumPackageOverview`, to `Kanrisuru::Core::Yum::PackageOverview`.
* Fix backups test case for `cp` command with the correct filename.
* Use 0755 as expected numeric mode for all OS functional tests in the `mkdir` test case.
* Fix bug with `lscpu` regex match on cpus with more than 9 cores, ie `/cpu\d/` to `/cpu\d+/`

 
## Kanrisuru 0.4.1 (July 26, 2021) ##
* Add `kernel_statistics` to system core module. 

## Kanrisuru 0.4.0 (July 25, 2021) ##
* Update internal exit code of command from 0, to array of accpeted exit codes, with 0 being the default value.
* Add `append_exit_code` to command, allowing additional exit codes to be considered true for `success?` return value.
* Add `@port` to `Net::SSH.start` method
* Fix test case with `host.os` return value of `opensuse_leap`.
* Add `cpu_flags` method to `cpu` module

## Kanrisuru 0.3.2 (July 23, 2021) ##
* Fix typo from `key` to `signal` in hash fetch method. 

## Kanrisuru 0.3.1 (July 22, 2021) ##
* Add additional methods to `cpu` pulling from `lscpu` struct.
* Fix `address_size` in `cpu` method call.

## Kanrisuru 0.3.0 (July 22, 2021) ##

* Add `lscpu` system core module 
* Replace `cpu` module internal fetching of data from `cpu_info` to `lscpu` struct.
 
## Kanrisuru 0.2.9 (July 20, 2021) ##

* Fix fstab entry from `entry` to `entry[:entry]` in the `for_each`iteration. 

## Kanrisuru 0.2.8 (July 20, 2021) ##

* Update gem development and runtime depedencies with stricter depencies.

## Kanrisuru 0.2.7 (July 18, 2021) ##

* Set opensuse upstream to sles (Suse Enterprise Linux) in `os_family`

## Kanrisuru 0.2.6 (July 17, 2021) ##
* Force "-" to "\_" from `os-release` release name in `host.os` module.

## Kanrisuru 0.2.5 (July 16, 2021) ##
* Update gem depedencies to non-zero values
* Change summary and description fields for `apt` 
* Move `normalize_size` from `apt` core module, to 
`Kanrisuru::Util::Bits` class.
* Add additional test cases for `apt` core module.
* Add `-hi` to `who` command to explicility print out ip address for user.
* Update `inode?` command to execute without shell user. 
* Add `yum` package manager core module

## Kanrisuru 0.2.4 (July 10, 2021) ##
* Fix error in `ip_rule` and `ip_address` sub modules with command typo. 

## Kanrisuru 0.2.3 (July 07, 2021) ##
* Add `apt` package manager core module

## Kanrisuru 0.2.2 (June 16, 2021) ##
* Fix `read_file_chunk` on checking bounds for start and end line values.

## Kanrisuru 0.2.1 (June 16, 2021) ##
* Add first working release on rubygems.org

## Kanrisuru 0.2.0 (June 16, 2021) [YANKED] ##

## Kanrisuru 0.1.0 (December 12, 2020) ##
* Initialize repository, start working on project.
