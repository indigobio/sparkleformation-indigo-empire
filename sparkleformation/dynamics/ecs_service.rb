SparkleFormation.dynamic(:service) do |_name, _config={}|
  dynamic!(:ecs_service, _name).properties do
    cluster ref!("#{_name}_ecs_cluster".to_sym)
    desired_count _config[:desired_count]
    load_balancers _array(
                          *_config[:load_balancers].map { |lb| {
                            'ContainerName' => lb[:container_name],
                            'ContainerPort' => lb[:container_port],
                            'LoadBalancerName' => ref!(lb[:load_balancer])
                          }
                         })
    role ref!(_config[:service_role])
    task_definition ref!(_config[:task_definition])
  end

  dynamic!(:ecs_service, _name).depends_on _array(_config[:ecs_cluster],
                                                  _config[:service_role],
                                                  _config[:service_policy],
                                                  _config[:auto_scaling_group]
                                                 )
end