action "aws_cloudfront_create_invalidation" "web" {
  config {
    distribution_id = aws_cloudfront_distribution.web.id
    paths           = ["/*"]
  }
}
