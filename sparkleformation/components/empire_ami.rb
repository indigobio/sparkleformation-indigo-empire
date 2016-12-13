SparkleFormation.component(:empire_ami) do
  mappings(:region_to_ami) do
    set!('us-east-1'.disable_camel!, :ami => 'ami-3ccfc32b')
    set!('us-east-2'.disable_camel!, :ami => 'ami-eca7fd89')
    set!('us-west-1'.disable_camel!, :ami => 'ami-287f2948')
    set!('us-west-2'.disable_camel!, :ami => 'ami-db5ef4bb')
  end
end