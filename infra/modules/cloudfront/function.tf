resource "aws_cloudfront_function" "basic_auth" {
  name    = "${var.service_name}-basic-auth"
  runtime = "cloudfront-js-2.0"
  publish = true
  code = templatefile("${path.module}/basic_auth.js", {
    credentials = base64encode("${var.basic_auth_username}:${var.basic_auth_password}")
  })
}
