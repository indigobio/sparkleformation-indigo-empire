SparkleFormation.dynamic(:bucket) do |_name, _config = {}|

  parameters("#{_name}_acl".to_sym) do
    type 'String'
    allowed_values %w(AuthenticatedRead BucketOwnerRead BucketOwnerFullControl LogDeliveryWrite Private PublicRead PublicReadWrite)
    default _config.fetch(:acl, 'Private')
    description 'Canned ACL to apply to the bucket. http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl'
  end

  dynamic!(:s3_bucket, _name).properties do
    access_control ref!("#{_name}_acl".to_sym)
    if _config.has_key?(:bucket_name)
      bucket_name _config[:bucket_name]
    end
    tags _array(
           -> {
             key 'Environment'
             value ENV['environment']
           },
           -> {
             key 'Purpose'
             value _config.fetch(:purpose, _name)
           }
         )
  end
end