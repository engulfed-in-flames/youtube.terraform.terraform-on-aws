locals {
  users = csvdecode(file("data/users.csv"))
}

resource "aws_iam_group_membership" "education" {
  name = "tf-education-group-membership"

  group = aws_iam_group.education.name
  users = [for user in aws_iam_user.users : user.name if user.tags.Department == "Education"]
}

resource "aws_iam_user" "users" {
  for_each = { for user in local.users : user.first_name => user }

  name = lower("${substr(each.value.first_name, 0, 1)}${each.value.last_name}")
  path = "/users/"

  tags = {
    "DisplayName" = "${each.value.first_name} ${each.value.last_name}"
    "Department"  = each.value.department
    "JobTitle"    = each.value.job_title
  }
}

resource "aws_iam_user_login_profile" "users" {
  for_each = aws_iam_user.users

  user                    = each.value.name
  password_reset_required = true
}

resource "aws_iam_group" "education" {
  name = "Education"
  path = "/education/"
}
