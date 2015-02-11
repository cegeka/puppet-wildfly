#!/usr/bin/env rspec

require 'spec_helper'

describe 'wildfly' do
  it { should contain_class 'wildfly' }
end
