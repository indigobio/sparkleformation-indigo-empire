SfnRegistry.register(:minion_seed) do |_name, _config =  {}|
  {
    "EMPIRE_HOSTGROUP"         => "minion",
    "ECS_CLUSTER"              => ref!(:minion_ecs_cluster),
    "DOCKER_USER"              => ref!(:docker_user),
    "DOCKER_PASS"              => ref!(:docker_pass),
    "DOCKER_EMAIL"             => ref!(:docker_email),
    "DOCKER_REGISTRY"          => ref!(:docker_registry),
    "NEW_RELIC_LICENSE_KEY"    => ref!(:new_relic_license_key),
    "NEW_RELIC_SERVER_LABELS"  => ref!(:new_relic_server_labels),
    "SUMOLOGIC_ACCESS_ID"      => ref!(:sumologic_access_id),
    "SUMOLOGIC_ACCESS_KEY"     => ref!(:sumologic_access_key),
    "SUMOLOGIC_COLLECTOR_NAME" => ref!(:sumologic_collector_name),
    "ENABLE_SUMOLOGIC"         => ref!(:enable_sumologic),
    "EMPIRE_ENVIRONMENT"       => ENV['environment']
  }
end