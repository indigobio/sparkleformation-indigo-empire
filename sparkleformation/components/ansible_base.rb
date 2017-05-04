SparkleFormation.component(:ansible_base) do
  parameters(:ansible_version) do
    type 'String'
    default ENV.fetch('ansible_version', '2.3.0.0-1ppa')
  end
end
