#!/usr/bin/ruby
#
#  Report the repos available to this system
#  This will be empty if the registration is bad.
#
#   Copyright 2016 Pat Riehecky <riehecky@fnal.gov>
#
#   See LICENSE for licensing.
#
require 'facter/util/cacheable'

module Facter::Util::Rhsm_available_repos
  @doc=<<EOF
  Available RHSM repos for this client.
EOF
  class << self
    def rhsm_available_repos
      value = []
      begin
        output = Facter::Util::Resolution.exec(
          '/usr/sbin/subscription-manager repos')
        output.split("\n").each { |line|
          if line =~ /Repo ID:\s+(\S+)/
            value.push($1.chomp)
          end
        }
      rescue Exception => e
          Facter.debug("#{e.backtrace[0]}: #{$!}.")
      end
      value
    end
  end
end

Facter.add(:rhsm_available_repos) do
  confine do
    File.exist? '/usr/sbin/subscription-manager'
  end
  setcode do
    # TODO: use another fact to set the TTL in userspace
    # right now this can be done by removing the cache files
    cache = Facter::Util::Cacheable.cached?(:rhsm_available_repos, 24 * 3600)
    if ! cache
      repos = Facter::Util::Rhsm_available_repos.rhsm_available_repos
      Facter::Util::Cacheable.cache(:rhsm_available_repos, repos)
      repos
    else
      if cache.is_a? Array
        cache
      else
        cache["rhsm_available_repos"]
      end
    end
  end
end
