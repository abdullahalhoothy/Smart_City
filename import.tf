import {
  to = aws_iam_access_key.accesskey_res
  id = "AKIA47CR255UJPSHH2TL"
}

resource "aws_iam_access_key" "accesskey_res" {
  user    = aws_iam_user.user_resource.name

}
