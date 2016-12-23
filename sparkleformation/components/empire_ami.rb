SparkleFormation.component(:empire_ami) do
  mappings(:region_to_ami) do
    set!('us-east-1'.disable_camel!, :ami => 'ami-cbe6f0dc')
    set!('us-east-2'.disable_camel!, :ami => 'ami-88c59fed')
    set!('us-west-1'.disable_camel!, :ami => 'ami-9f6d3cff')
    set!('us-west-2'.disable_camel!, :ami => 'ami-694ff809')
  end
end
