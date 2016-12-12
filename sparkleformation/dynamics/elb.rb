SparkleFormation.dynamic(:elb) do |_name, _config = {}|

  parameters("#{_name}_elb_name".to_sym) do
    type 'String'
    allowed_pattern "[\\x20-\\x7E]*"
    default _config.fetch(:lb_name, _name)
    description 'Name of public Elastic Load Balancer'
    constraint_description 'can only contain ASCII characters'
  end

  dynamic!(:elastic_load_balancing_load_balancer, _name).properties do
    cross_zone 'true'
    connection_settings do
      idle_timeout _config.fetch(:idle_timeout, '60')
    end
    load_balancer_name _config.fetch(:lb_name, ENV['lb_name'])
    listeners _array(
      *_config[:listeners].map { |l| -> {
        protocol l[:protocol]
        load_balancer_port l[:load_balancer_port]
        instance_protocol l[:instance_protocol]
        instance_port l[:instance_port]
        if l.has_key?(:policy_names)
          policy_names l[:policy_names]
        end
        if l.has_key?(:ssl_certificate_id)
          set!('SSLCertificateId', l[:ssl_certificate_id])
        end
        }
      }
    )
    health_check do
      healthy_threshold _config.fetch(:hc_healthy_threshold, 2)
      interval _config.fetch(:hc_interval, 10)
      target "TCP:#{_config[:listeners].first[:instance_port]}"
      timeout _config.fetch(:hc_timeout, 5)
      unhealthy_threshold _config.fetch(:hc_unhealthy_threshold, 3)
    end
    policies _array(
      *_config.fetch(:policies, []).map { |l| -> {
        policy_name  l[:policy_name]
        policy_type l[:policy_type]
        attributes _array(
          *l[:attributes].each { |k, v| -> {
            k v
          }
        })
        instance_ports l[:instance_ports]
      }
    })
    scheme _config.fetch(:scheme, 'internet-facing')
    subnets _config.fetch(:subnets, registry!(:my_public_subnet_ids))
    security_groups _config[:security_groups]
    tags _array(
           -> {
             key 'Purpose'
             value "#{_name.gsub('-','_')}_elb".to_sym
           },
           -> {
             key 'Environment'
             value ENV['environment']
           }
         )
  end
end