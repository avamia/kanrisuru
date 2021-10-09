## Kanrisuru 0.8.14 (October 8, 20201)
* Update `Kanrisuru::Remote::Cluster` instantiation method to use array splat instead of passing array directly.

## Kanrisuru 0.8.13 (October 4, 20201)
* Fix `wc` command. Ensure result parsing is cast to integer values.

## Kanrisuru 0.8.12 (October 4, 20201)
* Refactor `rmdir` command to only work on empty directories. 

## Kanrisuru 0.8.11 (October 1, 20201)
* Allow `Kanrisuru::Mode` as mode type option in mkdir method.

## Kanrisuru 0.8.10 (August 24, 20201)
* Fix bug with rspec test case.

## Kanrisuru 0.8.9 (August 24, 2021)
* Fix spelling error exception `ArgumentError` in `Kanrisuru::Mode` class.

## Kanrisuru 0.8.8 (August 21, 2021) ##
* Add shorthand notation for tar command actions, such as `x` for `extract`, `t` for `list`, and `c` for `create`. 

## Kanrisuru 0.8.7 (August 21, 2021) ##
* Fix `FileInfo` field for ls command. Was set to `memory_blocks`, but was incorrect, corrected this to `hard_links`.

## Kanrisuru 0.8.6 (August 21, 2021) ##
* Add `minimum_io_size`, `physical_sector_size`, and `logical_sector_size` to the blkid low level disk probe for devices.

## Kanrisuru 0.8.5 (August 20, 2021) ##
* Add `summarize` option to `du` command. This will only output a total disk usage size for the entire directory versus disk usage for each file individually.

## Kanrisuru 0.8.4 (August 20, 2021) ##
* Convert `fsize` field to an `integer` for du disk module command.

## Kanrisuru 0.8.3 (August 20, 2021) ##
* Fix bug with disk usage, `du` command by escaping the awk variables in the command.
* Update `du` command to execute with shell user.

## Kanrisuru 0.8.2 (August 19, 2021) ##
* Convert `major` and `minor` device field values to an `integer` in lsblk disk module.

## Kanrisuru 0.8.1 (August 19, 2021) ##
* Fix `nodeps` flag value for `lsblk` command in disk module. 

## Kanrisuru 0.8.0 (August 18, 2021) ##
* Add last / lastb implementation in system core module. 

## Kanrisuru 0.7.3 (August 9, 2021) ##
* Fixed bug with zypper remove package, where the package names weren't being added to the linux command. 
* Test case added to ensure package is removed.

## Kanrisuru 0.7.2 (August 9, 2021) ##
* Fixed bug with the `os_method_cache` instance variable set in the namespaced instance of a host. This was causing collision issues inbetween host instances, where, hosts with the same aliased method name was getting overwritten (with a different OS), since the namespace instance variable existing on the host class definition wasn't getting reset inbetween host instantiations. Given that the `os_method_cache` is normally re-instantiated, this bug fix addresses this so that the `os_method_cache` is always defined on the host instance, ie:

  ```ruby
  host.instance_variable_get(:@os_method_cache)
  host.instance_variable_set(:@os_method_cache, os_method_cache)
  ```
  This is done instead of being saved on the namespace module. With the previous bug fix of using namespaced keys, there's no way for a method to be overwritten otherwise with a global `os_method_cache`.

## Kanrisuru 0.7.1 (August 8, 2021) ##
* Fix bug with `os_include` when caching namespace unbound methods, use the namespace in the 
cache key to avoid any namespace collisions with the same method name, namely:
```ruby
"#{namespace}.#{method_name}"
```

## Kanrisuru 0.7.0 (August 8, 2021) ##
* Simplify `FileInfo` struct for return object of `ls` command.
* Rename `size` to `fsize` for the `OpenFile` struct to avoid method naming conflicts of the struct class. 
* Allow `os_include` and `os_collection` to define multiple groupings of methods with the same namespace.
* Add `clear` method for remote env class, to remove any session based env variables.
* Add `to_s` method to result for quick analysis of string based return values. 
* Remove duplicate `numeric` method in the utils module.

## Kanrisuru 0.6.0 (August 1, 2021) ##
* Add `lsof` implementation in system core module
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
