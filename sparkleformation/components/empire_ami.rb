SparkleFormation.component(:empire_ami) do
  mappings(:region_to_ami) do
    set!('us-east-1'.disable_camel!, :ami => 'ami-0615bc10')
    set!('us-east-2'.disable_camel!, :ami => 'ami-a25e7ac7')
    set!('us-west-1'.disable_camel!, :ami => 'ami-d3540cb3')
    set!('us-west-2'.disable_camel!, :ami => 'ami-efb33a8f')
  end
end
