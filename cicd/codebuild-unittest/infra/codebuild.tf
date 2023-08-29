module "codebuild_build" {
  source = "./modules/codebuildProject"
  file = "buildspec.yml.tmpl"
  codepipeline_bucket_artifacts_arn = aws_s3_bucket.codepipeline_bucket.arn
  project = "build"
}

module "codebuild_test" {
  source = "./modules/codebuildProject"
  codepipeline_bucket_artifacts_arn = aws_s3_bucket.codepipeline_bucket.arn
  file = "buildspec_test.yml.tmpl"
  project = "test"
}