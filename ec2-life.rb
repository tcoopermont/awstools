#!/usr/bin/ruby
require 'aws-sdk'
require 'base64'

ascript = <<ADOC
#!/bin/sh
yum -y install epel-release zlib gcc

ADOC

list_running = []
input_options = ["start", "term","view"]
input = ARGV
if input.count != 1 || input_options.index(input[0]) == nil
  puts "options: #{input_options.to_s}"
  exit
else
  option = input[0]
end

ec2 = Aws::EC2::Client.new(region: 'us-west-2')

if  option == "start"
  st_resp = ec2.run_instances(
    min_count: 1,
    max_count: 1,
    #image_id: "ami-c125e0a1",
    image_id: "ami-d2c924b2",
    subnet_id: "subnet-34cf885c" ,
    #private_ip_address: "172.31.0.23",
    instance_type: "t2.micro",
    key_name: "alinux",
    user_data: Base64.encode64(ascript),
  )

  puts st_resp
end
resp = ec2.describe_instances()

resp.reservations.each do |res|
  puts res.reservation_id
  res.instances.each do |i|
    puts " #{i.instance_id} #{i.state.name} #{i.private_ip_address} public: #{i.public_ip_address}"
    if i.state.name == "running"
      list_running << i.instance_id
    end
  end
end


if  option == "term" && list_running.count > 0
  term_resp = ec2.terminate_instances(instance_ids: list_running)
  puts term_resp.to_s
end
