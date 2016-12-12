SparkleFormation.dynamic(:task_definition) do |_name, _config = {}|
  dynamic!(:ecs_task_definition, _name).properties do
    container_definitions _array(
      *_config[:container_definitions].map { |cd| registry!(:container_definition, cd) }
    )
    volumes _array(
      *_config.fetch(:volumes, []).map { |v| registry!(:volume, v)}
    )
  end
end