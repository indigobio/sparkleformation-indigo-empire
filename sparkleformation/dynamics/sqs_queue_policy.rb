SparkleFormation.dynamic(:sqs_queue_policy) do |_name, _config = {}|

  dynamic!(:s_q_s_queue_policy, _name).properties do
    queues _array( ref!(_config[:queue]) )
    policy_document do
      version '2012-10-17'
      id "#{_name}_queue_policy".to_sym
      statement _array(
        -> {
          effect 'Allow'
          principal '*'
          action %w( sqs:SendMessage )
          resource '*'
          condition do
            arn_equals do
              data!['aws:SourceArn'] = ref!(_config[:topic])
            end
          end
        }
      )
    end
  end
end