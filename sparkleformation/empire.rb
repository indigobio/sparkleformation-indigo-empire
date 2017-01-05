ENV['lb_name']            ||= "#{ENV['org']}-#{ENV['environment']}-empire-elb"
ENV['notification_topic'] ||= "#{ENV['org']}_#{ENV['environment']}_deregister_e_c_s_instance"
ENV['enable_sumologic']   ||= 'true'

SparkleFormation.new(:vpn, :provider => :aws).load(:base, :ansible_base, :ssh_key_pair, :empire_ami, :elb_security_policies).overrides do
  description <<"EOF"
Empire ECS cluster members, configured by Ansible. Empire controller ELB. Controller security
group. Empire minion security group. Route53 record: empire.#{ENV['public_domain']}.
EOF

  parameters(:vpc) do
    type 'String'
    default registry!(:my_vpc)
    allowed_values array!(registry!(:my_vpc))
  end

  parameters(:ansible_inventory) do
    type 'String'
    default ENV.fetch('ansible_inventory', 'ansible/hosts')
    allowed_pattern "[\\x20-\\x7E]*"
    description 'Git repository containing ansible playbook'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:ansible_playbook_repo) do
    type 'String'
    default ENV.fetch('ansible_playbook_repo', 'https://github.com/indigobio/sparkleformation-indigo-empire.git')
    allowed_pattern "[\\x20-\\x7E]*"
    description 'Git repository containing ansible playbook'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:ansible_playbook_branch) do
    type 'String'
    default ENV.fetch('ansible_playbook_branch', 'master')
    allowed_pattern "[\\x20-\\x7E]*"
    description 'Git repository branch'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:ansible_local_yaml_path) do
    type 'String'
    default ENV.fetch('ansible_local_yaml_path', 'ansible/local.yml')
    allowed_pattern "[\\x20-\\x7E]*"
    description 'Path, in the playbook repository, to find the local.yml file'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:ecs_agent_version) do
    type 'String'
    default 'v1.13.1'
    allowed_pattern "[\\x20-\\x7E]*"
    description 'Docker tag to specify the version of Empire to run'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:empire_version) do
    type 'String'
    default '0.10.1'
    allowed_pattern "[\\x20-\\x7E]*"
    description 'Docker tag to specify the version of Empire to run'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:empire_database_user) do
    type 'String'
    default ENV['empire_database_user']
    allowed_pattern "[\\x20-\\x7E]*"
    description 'Master password for Empire RDS instance'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:empire_database_password) do
    type 'String'
    default ENV['empire_database_password']
    allowed_pattern "[\\x20-\\x7E]*"
    description 'Master password for Empire RDS instance'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:empire_token_secret) do
    type 'String'
    default ENV['empire_token_secret']
    allowed_pattern "[\\x20-\\x7E]*"
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:docker_registry) do
    type 'String'
    default 'https://index.docker.io/v1/'
    allowed_pattern "[\\x20-\\x7E]*"
    description 'Docker private registry url'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:docker_user) do
    type 'String'
    default ''
    allowed_pattern "[\\x20-\\x7E]*"
    description 'Docker username for private registry'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:docker_pass) do
    type 'String'
    default ''
    allowed_pattern "[\\x20-\\x7E]*"
    description 'Docker password for private registry'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:docker_email) do
    type 'String'
    default ''
    allowed_pattern "[\\x20-\\x7E]*"
    description 'Docker private registry email'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:docker_version) do
    type 'String'
    default '1.11.2-0'
    description 'Version of docker to install'
    allowed_pattern "[0-9.-]+"
    constraint_description 'can only contain numbers, periods and dashes'
  end

  parameters(:github_client_id) do
    type 'String'
    default ''
    allowed_pattern "[\\x20-\\x7E]*"
    description 'A github application client ID, for OAuth'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:github_client_secret) do
    type 'String'
    default ''
    allowed_pattern "[\\x20-\\x7E]*"
    description 'A github application client secret, for OAuth'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:github_organization) do
    type 'String'
    default 'indigobio'
    allowed_pattern "[\\x20-\\x7E]*"
    description 'The github organization that the application ID has access to'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:new_relic_license_key) do
    type 'String'
    default ENV['new_relic_license_key']
    allowed_pattern "[\\x20-\\x7E]*"
    description 'New Relic license key for server monitoring'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:enable_sumologic) do
    type 'String'
    allowed_values %w(true false)
    default ENV['enable_sumologic']
    description 'Deploy the sumologic collector container to all instances'
  end

  parameters(:sumologic_access_id) do
    type 'String'
    default ENV['sumologic_access_id']
    allowed_pattern "[\\x20-\\x7E]*"
    description 'SumoLogic access ID for log collection'
    constraint_description 'can only contain ASCII characters'
  end

  parameters(:sumologic_access_key) do
    type 'String'
    default ENV['sumologic_access_key']
    allowed_pattern "[\\x20-\\x7E]*"
    description 'SumoLogic access key for log collection'
    constraint_description 'can only contain ASCII characters'
  end

  ######################################################################
  # Security groups and rules                                          #
  ######################################################################
  dynamic!(:vpc_security_group, 'controller',
           :ingress_rules =>
             [
               { :cidr_ip => '0.0.0.0/0', :ip_protocol => 'tcp', :from_port => '443', :to_port => '443' }
             ]
          )

  dynamic!(:vpc_security_group, 'minion',  :ingress_rules => [])

  # Not used, but if we ever created a domain for an app, then
  # Empire would create an "allow-all" rule in the public security group
  dynamic!(:vpc_security_group, 'empire_public', :ingress_rules => [])

  # Minions
  dynamic!(:security_group_ingress, 'nginx-to-empire-http',
           :source_sg => registry!(:my_security_group_id, 'nginx_sg'),
           :ip_protocol => 'tcp',
           :from_port => '80',
           :to_port => '80',
           :target_sg => attr!(:minion_ec2_security_group, 'GroupId')
          )

  dynamic!(:security_group_ingress, 'empire-to-private-mzconvert-http',
           :source_sg => attr!(:minion_ec2_security_group, 'GroupId'),
           :ip_protocol => 'tcp',
           :from_port => '80',
           :to_port => '80',
           :target_sg => registry!(:my_security_group_id, 'private_sg')
          )

  dynamic!(:security_group_ingress, 'empire-to-private-mongodb',
           :source_sg => attr!(:minion_ec2_security_group, 'GroupId'),
           :ip_protocol => 'tcp',
           :from_port => '27017',
           :to_port => '27017',
           :target_sg => registry!(:my_security_group_id, 'private_sg')
          )

  dynamic!(:security_group_ingress, 'empire-to-private-postgresql',
           :source_sg => attr!(:minion_ec2_security_group, 'GroupId'),
           :ip_protocol => 'tcp',
           :from_port => '5432',
           :to_port => '5432',
           :target_sg => registry!(:my_security_group_id, 'private_sg')
          )

  dynamic!(:security_group_ingress, 'empire-to-private-rabbitmq',
           :source_sg => attr!(:minion_ec2_security_group, 'GroupId'),
           :ip_protocol => 'tcp',
           :from_port => '5672',
           :to_port => '5672',
           :target_sg => registry!(:my_security_group_id, 'private_sg')
          )

  dynamic!(:security_group_ingress, 'empire-to-private-couchbase',
           :source_sg => attr!(:minion_ec2_security_group, 'GroupId'),
           :ip_protocol => 'tcp',
           :from_port => '11311',
           :to_port => '11311',
           :target_sg => registry!(:my_security_group_id, 'private_sg')
          )

  # TODO: this seems like overkill.  Maybe I can just put the Chronicle
  # RDS instance into the private security group.
  dynamic!(:security_group_ingress, 'empire-to-chronicle-postgres',
           :source_sg => attr!(:minion_ec2_security_group, 'GroupId'),
           :ip_protocol => 'tcp',
           :from_port => '5432',
           :to_port => '5432',
           :target_sg => registry!(:my_security_group_id, 'chronicle_sg')
          )

  dynamic!(:security_group_ingress, 'empire-to-nat-all',
           :source_sg => attr!(:minion_ec2_security_group, 'GroupId'),
           :ip_protocol => '-1',
           :from_port => '-1',
           :to_port => '-1',
           :target_sg => registry!(:my_security_group_id, 'nat_sg')
          )

  dynamic!(:security_group_ingress, 'vpn-to-empire-all',
           :source_sg => registry!(:my_security_group_id,  'vpn_sg'),
           :ip_protocol => '-1',
           :from_port => '-1',
           :to_port => '-1',
           :target_sg => attr!(:minion_ec2_security_group, 'GroupId')
          )

  # Controllers
  dynamic!(:security_group_ingress, 'controller-to-empireDB-all',
           :source_sg => attr!(:controller_ec2_security_group, 'GroupId'),
           :ip_protocol => 'tcp',
           :from_port => '5432',
           :to_port => '5432',
           :target_sg => registry!(:my_security_group_id, 'empireDB_sg')
          )

  dynamic!(:security_group_ingress, 'controller-to-nat-all',
           :source_sg => attr!(:controller_ec2_security_group, 'GroupId'),
           :ip_protocol => '-1',
           :from_port => '-1',
           :to_port => '-1',
           :target_sg => registry!(:my_security_group_id, 'nat_sg')
          )

  dynamic!(:security_group_ingress, 'vpn-to-controller-all',
           :source_sg => registry!(:my_security_group_id,  'vpn_sg'),
           :ip_protocol => '-1',
           :from_port => '-1',
           :to_port => '-1',
           :target_sg => attr!(:controller_ec2_security_group, 'GroupId')
          )

  ######################################################################
  # ACTUAL STUFF: Controllers and their accoutrements                  #
  ######################################################################
  dynamic!(:elb, 'controller',
           :listeners => [
             { :instance_port => '8080', :instance_protocol => 'http', :load_balancer_port => '443', :protocol => 'https', :ssl_certificate_id => registry!(:my_acm_server_certificate), :policy_names => [ref!(:elb_security_policy)] }
           ],
           :policies => [],
           :security_groups => _array( attr!(:controller_ec2_security_group, 'GroupId') ),
           :idle_timeout => '600',
           :subnets => registry!(:my_public_subnet_ids),
           :lb_name => ENV['lb_name'],
           :ssl_certificate_ids => registry!(:my_acm_server_certificate)
          )

  dynamic!(:iam_instance_profile, 'controller', :policy_statements => [ :controller_policy_statements ])


  dynamic!(:launch_config, 'controller',
           :iam_instance_profile => 'ControllerIAMInstanceProfile',
           :iam_role => 'ControllerIAMRole',
           :public_ips => 'false',
           :security_groups => _array(ref!(:controller_ec2_security_group)),
           :ansible_seed => registry!(:controller_seed, 'controller'),
           :create_swap_volume => false,
           :create_ebs_volume => true
          )

  dynamic!(:auto_scaling_group, 'controller',
           :min_size => 0,
           :launch_config => :controller_auto_scaling_launch_configuration,
           :subnet_ids => registry!(:my_private_subnet_ids),
           :notification_topic => registry!(:my_sns_topics, ENV['notification_topic'])
          )

  dynamic!(:ecs_cluster, 'controller')

  dynamic!(:service,
           'controller',
           :desired_count => 2,
           :ecs_cluster => 'ControllerEcsCluster',
           :load_balancers => [
             { :container_name => 'empire_controller',
               :container_port => '8080',
               :load_balancer => 'ControllerElasticLoadBalancingLoadBalancer' }
           ],
           :service_role => 'ControllerIAMRole',
           :service_policy => 'ControllerIAMPolicy',
           :task_definition => 'ControllerEcsTaskDefinition',
           :auto_scaling_group => 'ControllerAutoScalingAutoScalingGroup'
          )

  # Some notes are in order, here.  EMPIRE_GITHUB_CLIENT_ID and EMPIRE_GITHUB_CLIENT_SECRET need to be
  # OAuth keys that you can use to log into EMPIRE_GITHUB_ORGANIZATION as an OAuth App.
  # See http://empire.readthedocs.org/en/latest/production_best_practices/#securing-the-api
  dynamic!(:task_definition,
           'controller',
           :container_definitions => [
             {
               :name => 'empire_controller',
               :image => join!('remind101/empire', ref!(:empire_version), {:options => { :delimiter => ':'}}),
               :command => [ 'server', '--automigrate=true' ],
               :memory => 256,
               :port_mappings => [ { :container_port => '8080', :host_port => '8080' } ],
               :mount_points => [
                 { :source_volume => 'dockerSocket', :container_path => '/var/run/docker.sock', :read_only => false},
                 { :source_volume => 'dockerCfg', :container_path => '/root/.dockercfg', :read_only => false}
               ],
               :essential => true,
               :environment => [
                 { :name => 'AWS_REGION', :value => region! },
                 { :name => 'EMPIRE_DATABASE_URL', :value => join!('postgres://', ref!(:empire_database_user), ':', ref!(:empire_database_password), '@empire-rds.', ENV['private_domain'], '/empire') },
                 { :name => 'EMPIRE_GITHUB_CLIENT_ID', :value => ref!(:github_client_id) },
                 { :name => 'EMPIRE_GITHUB_CLIENT_SECRET', :value => ref!(:github_client_secret) },
                 { :name => 'EMPIRE_GITHUB_ORGANIZATION', :value => ref!(:github_organization) },
                 { :name => 'EMPIRE_TOKEN_SECRET', :value => ref!(:empire_token_secret) },
                 { :name => 'EMPIRE_PORT', :value => '8080' },
                 { :name => 'EMPIRE_ECS_CLUSTER', :value => ref!(:minion_ecs_cluster) },
                 { :name => 'EMPIRE_ELB_VPC_ID', :value => registry!(:my_vpc) },
                 { :name => 'EMPIRE_ELB_SG_PRIVATE', :value => attr!(:minion_ec2_security_group, 'GroupId') },
                 { :name => 'EMPIRE_ELB_SG_PUBLIC', :value => attr!(:empire_public_ec2_security_group, 'GroupId') },
                 { :name => 'EMPIRE_ROUTE53_INTERNAL_ZONE_ID', :value => registry!(:my_hosted_zone, ENV['private_domain']) },
                 { :name => 'EMPIRE_EC2_SUBNETS_PRIVATE', :value => join!(registry!(:my_private_subnet_ids), {:options => { :delimiter => ','}}) },
                 { :name => 'EMPIRE_EC2_SUBNETS_PUBLIC', :value => join!(registry!(:my_public_subnet_ids), {:options => { :delimiter => ','}}) },
                 { :name => 'EMPIRE_ECS_SERVICE_ROLE', :value => ref!(:controller_i_a_m_role) }
               ]
             }
           ],
           :volumes => [
             { :name => 'dockerSocket', :source_path => '/var/run/docker.sock' },
             { :name => 'dockerCfg', :source_path => '/etc/empire/dockercfg' }
           ]
         )

  dynamic!(:record_set, 'controller',
           :record => 'empire',
           :target => :controller_elastic_load_balancing_load_balancer,
           :domain_name => ENV['public_domain'],
           :attr => 'CanonicalHostedZoneName',
           :ttl => '60'
          )

  ######################################################################
  # Empire Minions                                                     #
  ######################################################################

  dynamic!(:iam_instance_profile, 'minion', :policy_statements => [ :minion_policy_statements ])

  dynamic!(:launch_config, 'minion',
           :iam_instance_profile => 'MinionIAMInstanceProfile',
           :iam_role => 'MinionIAMRole',
           :public_ips => 'false',
           :security_groups => _array(ref!(:minion_ec2_security_group)),
           :ansible_seed => registry!(:minion_seed, 'minion'),
           :create_swap_volume => true,
           :create_ebs_volume => true
          )

  dynamic!(:auto_scaling_group, 'minion',
           :min_size => 0,
           :launch_config => :minion_auto_scaling_launch_configuration,
           :subnet_ids => registry!(:my_private_subnet_ids),
           :notification_topic => registry!(:my_sns_topics, ENV['notification_topic'])
          )

  dynamic!(:ecs_cluster, 'minion')
end
