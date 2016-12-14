SfnRegistry.register(:ebs_volumes) do |options = {}|

  provisioned_iops   = options.fetch(:provisioned_iops, 300)
  root_volume_size   = options.fetch(:root_volume_size, '12')
  swap_volume_size   = options.fetch(:swap_volume_size, '16')
  volume_size        = options.fetch(:volume_size, '100')
  create_swap_volume = options.fetch(:create_swap_volume, false).to_s
  create_ebs_volume  = options.fetch(:create_ebs_volume, false).to_s

  bdm = [
    -> {
      device_name '/dev/sda1'
      ebs do
        delete_on_termination 'true'
        volume_type 'gp2'
        volume_size root_volume_size
      end
    }
  ]

  if create_swap_volume.to_s == 'true'
    bdm.push(
      -> {
        device_name '/dev/sdi'
        ebs do
          delete_on_termination true
          volume_type if!(options[:io1_condition], 'io1', 'gp2')
          iops if!(options[:io1_condition], provisioned_iops, no_value!)
          volume_size swap_volume_size
        end
      }
    )
  end

  if create_ebs_volume == 'true'
    bdm.push(
      -> {
        device_name '/dev/sdh'
        ebs do
          delete_on_termination true
          volume_type if!(options[:io1_condition], 'io1', 'gp2')
          iops if!(options[:io1_condition], provisioned_iops, no_value!)
          volume_size volume_size
        end
      }
    )
  end
  
  bdm
end
