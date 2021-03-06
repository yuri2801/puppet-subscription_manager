#!/usr/bin/ruby -S rspec
#
#  Test the class structure of the module as used.
#
#   Copyright 2016 WaveClaw <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.
#
require 'spec_helper_acceptance'

describe 'subscription_manager class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'subscription_manager': }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe package('subscription-manager') do
      it { should be_installed }
    end

    describe package('katello-ca-consumer') do
      it { should be_installed }
    end

    describe service('goferd') do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
