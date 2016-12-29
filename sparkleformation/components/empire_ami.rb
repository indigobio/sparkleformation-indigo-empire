SparkleFormation.component(:empire_ami) do
  mappings(:region_to_ami) do
    set!('us-east-1'.disable_camel!, :ami => 'ami-e16b77f6')
    set!('us-east-2'.disable_camel!, :ami => 'ami-fef4ae9b')
    set!('us-west-1'.disable_camel!, :ami => 'ami-6decbd0d')
    set!('us-west-2'.disable_camel!, :ami => 'ami-16d56476')
  end
end
