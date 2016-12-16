SparkleFormation.component(:empire_ami) do
  mappings(:region_to_ami) do
    set!('us-east-1'.disable_camel!, :ami => 'ami-ffdcd5e8')
    set!('us-east-2'.disable_camel!, :ami => 'ami-89cb91ec')
    set!('us-west-1'.disable_camel!, :ami => 'ami-77d68017')
    set!('us-west-2'.disable_camel!, :ami => 'ami-5b51e43b')
  end
end