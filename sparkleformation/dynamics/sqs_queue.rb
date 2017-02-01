SparkleFormation.dynamic(:sqs_queue) do |_name, _config = {}|

  _config[:visibility_timeout] ||= 1800

  dynamic!(:s_q_s_queue, _name).properties do
    visibility_timeout _config[:visibility_timeout]
  end
end