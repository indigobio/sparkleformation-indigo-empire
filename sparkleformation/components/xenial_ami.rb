SparkleFormation.component(:xenial_ami) do
  mappings(:region_to_ami) do
    set!('us-east-1'.disable_camel!, :ami => 'ami-4cd4fe5b')
    set!('us-east-2'.disable_camel!, :ami => 'ami-16752f73')
    set!('us-west-1'.disable_camel!, :ami => 'ami-22db8e42')
    set!('us-west-2'.disable_camel!, :ami => 'ami-8f78d5ef')
  end
end