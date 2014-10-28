#
# create_resources_hash_from.rb
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Puppet::Parser::Functions
  newfunction(:create_resources_hash_from, :type => :rvalue, :doc => <<-EOS
Given:
    A formatted string (to use as the resource name)
    An array to loop through (because puppet cannot loop)

This function will return a hash of hashes that can be used with the
create_resources function.

*Examples:*
    $resource_name = "user %s"
    $users = ['foo', 'bar']

    $created_resource_hash = create_resources_hash_from($resource_name, $users)

$created_resource_hash would equal:
    {
      'user foo' => {
        name => 'foo',
        home => '/home/foo'
      },
      'user bar' => {
        name => 'bar',
        home => '/home/bar'
      }
    }

$created_resource_hash could then be used with create_resources

    create_resources(user, $created_resource_hash)

To create a bunch of resources in a way that would only otherwise be possible
with a loop of some description.
    EOS
  ) do |arguments|

    raise Puppet::ParseError, "create_resources_hash_from(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)" if arguments.size < 1 or arguments.size > 1

    loop_array = arguments[0]

    unless loop_array.is_a?(Array)
      raise(Puppet::ParseError, 'create_resources_hash_from(): second argument must be an array')
    end

    result = {}

    loop_array.each do |i|
      my_resource_hash = {
        'name' => i,
        'home' => "/home/#{i}"
      }
      result[i] = my_resource_hash
    end

    result
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
