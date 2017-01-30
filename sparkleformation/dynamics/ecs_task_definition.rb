SparkleFormation.dynamic(:task_definition) do |_name, _config = {}|
  dynamic!(:ecs_task_definition, _name).properties do
    if _config.has_key?(:task_role)
      task_role_arn attr!(_config[:task_role], :arn)
    end
    container_definitions _array(
      *_config[:container_definitions].map { |cd| registry!(:container_definition, cd) }
    )
    volumes _array(
      *_config.fetch(:volumes, []).map { |v| registry!(:volume, v)}
    )
  end
end