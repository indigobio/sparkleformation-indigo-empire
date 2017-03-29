SfnRegistry.register(:minion_seed) do |_name, _config = {}|
  {
    "EMPIRE_ENVIRONMENT"       => ENV['environment'],
    "EMPIRE_HOSTGROUP"         => 'minion',
    'ANSIBLE_LOCAL_TEMP'       => '$HOME/.ansible/tmp',
    'ANSIBLE_REMOTE_TEMP'      => '$HOME/.ansible/tmp',
    "ECS_CLUSTER"              => ref!(:minion_ecs_cluster),
    "ECS_AGENT_VERSION"        => ref!(:ecs_agent_version),
    "DOCKER_USER"              => ref!(:docker_user),
    "DOCKER_PASS"              => ref!(:docker_pass),
    "DOCKER_EMAIL"             => ref!(:docker_email),
    "DOCKER_REGISTRY"          => ref!(:docker_registry),
    "DOCKER_VERSION"           => ref!(:docker_version),
    "NEW_RELIC_LICENSE_KEY"    => ENV['new_relic_license_key'],
    "NEW_RELIC_SERVER_LABELS"  => ref!("#{_name}_new_relic_server_labels".to_sym),
    "SUMOLOGIC_ACCESS_ID"      => ENV['sumologic_access_id'],
    "SUMOLOGIC_ACCESS_KEY"     => ENV['sumologic_access_key'],
    "ENABLE_SUMOLOGIC"         => ref!(:enable_sumologic),
    "DD_AGENT_VERSION"         => ref!(:dd_agent_version),
    "DD_API_KEY"               => ENV['dd_api_key'],
    "ENABLE_DATADOG"           => ref!(:enable_datadog)
  }
end
