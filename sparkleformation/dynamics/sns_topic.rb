SparkleFormation.dynamic(:sns_topic) do |_name, _config = {}|

  conditions.set!(
    "#{_name}_sns_topic_has_name".to_sym,
    not!(equals!(ref!("#{_name}_sns_topic_name"), 'none'))
  )

  parameters("#{_name}_sns_topic_name".to_sym) do
    type 'String'
    allowed_pattern "[\\x20-\\x7E]*"
    default _name
    description 'The name of the termination SNS topic'
    constraint_description 'can only contain ASCII characters'
  end

  dynamic!(:s_n_s_topic, _name).properties do
    topic_name if!("#{_name}_sns_topic_has_name".to_sym, ref!("#{_name}_sns_topic_name".to_sym), no_value!)
    if _config.has_key?(:subscriber)
      subscription _array(
        -> {
          endpoint attr!(_config[:subscriber], :arn)
          protocol _config[:protocol]
        }
      )
    end
  end

  outputs("#{_name}_s_n_s_topic".to_sym) do
    description 'SNS Topic ARN'
    value ref!("#{_name}_s_n_s_topic".to_sym)
  end
end