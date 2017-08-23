# hostsfile cookbook

[![Build Status](https://travis-ci.org/customink-webops/hostsfile.svg?branch=master)](https://travis-ci.org/customink-webops/hostsfile)

`hostsfile` provides a resource for managing your `/etc/hosts` (or Windows equivalent) file using Chef.

## Requirements

- Chef 12.7 or higher

## Attributes

Attribute  | Description                                             | Example              | Default
---------- | ------------------------------------------------------- | -------------------- | ------------------------------------
ip_address | (name attribute) the IP address for the entry           | 1.2.3.4              |
hostname   | (required) the hostname associated with the entry       | example.com          |
unique     | remove any existing entries that have the same hostname | true                 | false
aliases    | array of aliases for the entry                          | ['www.example.com']  | []
comment    | a comment to append to the end of the entry             | 'interal DNS server' | nil
priority   | the relative position of this entry                     | 20                   | (varies, see **Priorities** section)

## Actions

**Please note**: In `v0.1.2`, specifying a hostname or alias that existed in another automatically removed that hostname from the other entry before. In `v2.1.0`, the `unique` option was added to give the user case-by-case control of this behavior. For example, given an `/etc/hosts` file that contains:

```
1.2.3.4          example.com www.example.com
```

when the Chef recipe below is converged:

```ruby
hostsfile_entry '2.3.4.5' do
  hostname  'www.example.com'
  unique    true
end
```

then the `/etc/hosts` file will look like this:

```
1.2.3.4          example.com
2.3.4.5          www.example.com
```

Not specifying the `unique` parameter will result in duplicate hostsfile entries.

### `create`

Creates a new hosts file entry. If an entry already exists, it will be overwritten by this one.

```ruby
hostsfile_entry '1.2.3.4' do
  hostname  'example.com'
  action    :create
end
```

This will create an entry like this:

```
1.2.3.4          example.com
```

### `create_if_missing`

Create a new hosts file entry, only if one does not already exist for the given IP address. If one exists, this does nothing.

```ruby
hostsfile_entry '1.2.3.4' do
  hostname  'example.com'
  action    :create_if_missing
end
```

### `append`

Append a hostname or alias to an existing record. If the given IP address doesn't already exist in the hostsfile, this method behaves the same as create. Otherwise, it will append the additional hostname and aliases to the existing entry.

```
1.2.3.4         example.com www.example.com # Created by Chef
```

```ruby
hostsfile_entry '1.2.3.4' do
  hostname  'www2.example.com'
  aliases   ['foo.com', 'foobar.com']
  comment   'Append by Recipe X'
  action    :append
end
```

would yield:

```
1.2.3.4         example.com www.example.com www2.example.com foo.com foobar.com # Created by Chef, Appended by Recipe X
```

### `update`

Updates the given hosts file entry. Does nothing if the entry does not exist.

```ruby
hostsfile_entry '1.2.3.4' do
  hostname  'example.com'
  comment   'Update by Chef'
  action    :update
end
```

This will create an entry like this:

```
1.2.3.4           example # Updated by Chef
```

### `remove`

Removes an entry from the hosts file. Does nothing if the entry does not exist.

```ruby
hostsfile_entry '1.2.3.4' do
  action    :remove
end
```

This will remove the entry for `1.2.3.4`.

## Usage

If you're using [Berkshelf](http://berkshelf.com/), just add `hostsfile` to your `Berksfile`:

```ruby
cookbook 'hostsfile'
```

Otherwise, install the cookbook from the community site:

```
knife cookbook site install hostsfile
```

Have any other cookbooks _depend_ on hostsfile by editing editing the `metadata.rb` for your cookbook.

```ruby
# metadata.rb
depends 'hostsfile'
```

Note that you can specify a custom path to your hosts file in the `['hostsfile']['path']` node attribute. Otherwise, it defaults to sensible paths depending on your OS.

### Testing

If you are using [ChefSpec](https://github.com/sethvargo/chefspec) to unit test a cookbook that implements the `hostsfile_entry` resource, this cookbook packages customer matchers that you can use in your unit tests:

- `append_hostsfile_entry`
- `create_hostsfile_entry`
- `create_hostsfile_entry_if_missing`
- `remove_hostsfile_entry`
- `update_hostsfile_entry`

For example:

```ruby
it 'creates a hostsfile entry for the DNS server' do
  expect(chef_run).to create_hostsfile_entry('1.2.3.4')
    .with_hostname('dns.example.com')
end
```

## Priority

Priority is a relatively new addition to the cookbook. It gives you the ability to (somewhat) specify the relative order of entries. By default, the priority is calculated for you as follows:

82. 127.0.0.1
81. ::1
80. 127.0.0.0/8
60. IPV4
20. IPV6
00. default

However, you can override it using the `priority` option.

## License & Authors

- Author:: Seth Vargo (sethvargo@gmail.com)

```text
Copyright 2012-2013, Seth Vargo
Copyright 2012, CustomInk, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
