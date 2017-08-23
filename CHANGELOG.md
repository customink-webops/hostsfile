# hostsfile Cookbook CHANGELOG

This file is used to list changes made in each version of the hostsfile cookbook.

## v3.0.1 (2017-08-22)

- Add TESTING.md and CONTRIBUTING.md files
- Fix the readme to properly specify Chef 12.7+ as the Chef requirement
- Add a local delivery configuration and remove the existing rakefile
- Resolve _most_ of the ChefSpec failures

## v3.0.0 (2017-08-22)

- Converted the LWRP to a custom resource which increases the required Chef release to 12.7
- Namespaced the helper libraries under the HostsFile module to prevent method collisions with other resources or the chef-client itself

## v2.4.6 (2017-08-15)

- use openssl for FIPS compatibility
- Expand priority documentation in README
- Add ::1 loopback to test cases and priority settings

## v2.4.5 (2014-06-24)

- Fix notifications and why-run mode

## v2.4.4 (2014-02-25)

- Bump Berkshelf version
- Remove scope pieces from IPv6 addresses

## v2.4.3 (2014-02-01)

- Package custom ChefSpec matchers
- Update testing harness
- Avoid using `Chef::Application.fatal!`
- Use Chef::Resource::File for atomic updates

## v2.4.2

- Fix Travis CI integration
- Remove newline characters
- Allow specifying a custom hostsfile path

## v2.4.1

- Force a new upload to the community site

## v2.4.0

- Convert everything to Ruby 1.9 syntax because I'm tired of people removing trailing commas despite the **massive** warning in the README: ([#29](https://github.com/customink-webops/hostsfile/issues/29), [#30](https://github.com/customink-webops/hostsfile/issues/30), [#32](https://github.com/customink-webops/hostsfile/issues/32), [#33](https://github.com/customink-webops/hostsfile/issues/33), [#34](https://github.com/customink-webops/hostsfile/issues/34), [#35](https://github.com/customink-webops/hostsfile/issues/35), [#36](https://github.com/customink-webops/hostsfile/issues/36), [#38](https://github.com/customink-webops/hostsfile/issues/38), [#39](https://github.com/customink-webops/hostsfile/issues/39))
- Update to the latest and greatest testing gems and practices
- Remove strainer in favor of a purer solution
- Update `.gitignore` to ignore additional files
- Add more platforms to the `.kitchen.yml`
- Use `converge_by` and support whyruny mode

## v2.0.0

- Completely manage the hostsfile, ensuring no duplicate entries

## v1.0.2

- Support Windows (thanks @igantt-daptiv)
- Specs + Travis support
- Throw fatal error if hostsfile does not exist (@jkerzner)
- Write priorities in hostsfile so they are read on subsequent Chef runs

## v0.2.0

- Updated README to require Ruby 1.9
- Allow hypens in hostnames
- Ensure newline at end of file
- Allow priority ordering in hostsfile

## v0.1.1

- Fixed issue #1
- Better unique object filtering
- Better handing of aliases

## v0.1.0

- Initial release
