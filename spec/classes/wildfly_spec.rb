#!/usr/bin/env rspec

require 'spec_helper'

describe 'wildfly' do
  let(:params) { { :version => '8.2.0-1.cgk.el6' } }
  it { should contain_class 'wildfly' }
end
