import {
  to = module.environment.aws_s3_bucket_policy.data-policy
  id = "exsiting"
}
import {
  to = module.environment.aws_s3_bucket_policy.code-policy
  id = "i-abcd1234"
}
import {
  to = module.environment.aws_s3_bucket.finspace-data-bucket
  id = "i-abcd1234"
}
import {
  to = module.environment.aws_s3_bucket.finspace-code-bucket
  id = "i-abcd1234"
}
import {
  to = module.environment.aws_finspace_kx_environment.environment
  id = "i-abcd1234"
}
import {
  to = module.environment.aws_iam_role.finspace-test-role
  id = "i-abcd1234"
}



