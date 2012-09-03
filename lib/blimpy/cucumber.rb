require 'rubygems'
require 'blimpy/cucumber/api'


World(Blimpy::Cucumber::API)

Given /^I have an empty (.*?) machine$/ do |type|
  expect(vm(type)).to_not be_nil
end

When /^I provision the host$/ do
  File.open(File.join(manifest_path, 'site.pp'), 'w') do |f|
    f.write("node default {\n")
    resources.each do |r|
      f.write("#{r}\n")
    end
    f.write("}\n")
  end

  start_vms
end
