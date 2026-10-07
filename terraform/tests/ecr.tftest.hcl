mock_provider "aws" {}
run "immutable_scanned_images" {
  command = plan
  module { source = "./modules/ecr" }
  variables { repository_names = ["goldenpath-test/backstage", "goldenpath-test/service-v0"] }
  assert {
    condition     = alltrue([for repository in aws_ecr_repository.application : repository.image_tag_mutability == "IMMUTABLE" && repository.image_scanning_configuration[0].scan_on_push])
    error_message = "Images must be scanned and existing tags must not be overwritten."
  }
}
