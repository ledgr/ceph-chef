#
# Author: Chris Jones <cjones303@bloomberg.net>
# Cookbook: ceph
#
# Copyright 2016, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'ceph-chef::repo' if node['ceph']['install_repo']
include_recipe 'ceph-chef::conf'

# Tools needed by cookbook
node['ceph']['packages'].each do |pck|
  package pck
end

# NOTE: The location of netaddr-1.5.1.gem is defaulted to /tmp. If one exists there then it will install that gem. If not,
# then it will install from the net. The purpose is to be able to supply all pre-reqs for those environments that
# are not allowed to access the net.

# FYI: If you're behind a firewall or no net access then you can install netaddr with the following after then node
# has been bootstrapped with Chef - /opt/chef/embedded/bin/gem install --force --local /tmp/netaddr-1.5.1.gem
# Of course, this means you have downloaded the gem from: https://rubygems.org/downloads/netaddr-1.5.1.gem and then
# copied it to your /tmp directory.
chef_gem 'netaddr_source' do
  source '/tmp/netaddr-1.5.1.gem'
  action :install
  compile_time true
  only_if 'test -f /tmp/netaddr-1.5.1.gem'
end

chef_gem 'netaddr' do
  action :install
  compile_time true
  not_if 'test -f /tmp/netaddr-1.5.1.gem'
end

if node['ceph']['pools']['radosgw']['federated_enable']
  ceph_chef_build_federated_pool('radosgw')
end
