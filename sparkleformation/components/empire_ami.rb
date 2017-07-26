SparkleFormation.component(:empire_ami) do
  mappings(:region_to_ami) do
    set!('us-east-1'.disable_camel!, :ami => 'ami-12085469')
    set!('us-east-2'.disable_camel!, :ami => 'ami-972505f2')
    set!('us-west-1'.disable_camel!, :ami => 'ami-5f9eb73f')
    set!('us-west-2'.disable_camel!, :ami => 'ami-0f6e7476')
  end
end
