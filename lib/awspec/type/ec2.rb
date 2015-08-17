module Awspec::Type
  class Ec2 < Base
    attr_reader :client, :instance

    def initialize(id)
      super
      @client = @ec2_client
      @instance = find_ec2(id)
      @id = @instance[:instance_id] if @instance
    end

    states = %w(
      pending running shutting-down
      terminated stopping stopped
    )

    states.each do |state|
      define_method state + '?' do
        @instance[:state][:name] == state
      end
    end

    def method_missing(name)
      describe = name.to_sym
      if @instance.members.include?(describe)
        @instance[describe]
      else
        super
      end
    end

    def has_eip?(ip_address = nil)
      option = {
        filters: [{ name: 'instance-id', values: [@id] }]
      }
      option[:public_ips] = [ip_address] if ip_address
      ret = @ec2_client.describe_addresses(option)
      return ret[:addresses].count == 1 if ip_address
      return ret[:addresses].count > 0 unless ip_address
    end

    def has_security_group?(sg_id)
      sgs = @instance[:security_groups]
      ret = sgs.find do |sg|
        sg[:group_id] == sg_id || sg[:group_name] == sg_id
      end
      return true if ret
      sg2 = find_security_group(sg_id)
      return false unless sg2.tag_name == sg_id
      sgs.find do |sg|
        sg[:group_id] == sg2[:group_id]
      end
    end

    def has_ebs?(volume_id)
      blocks = @instance[:block_device_mappings]
      ret = blocks.find do |block|
        next false unless block[:ebs]
        block[:ebs][:volume_id] == volume_id
      end
      return true if ret
      blocks2 = find_ebs(volume_id)
      blocks2[:attachments].find do |attachment|
        attachment.instance_id == @id
      end
    end
  end
end
