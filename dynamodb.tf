resource "aws_dynamodb_table" "todos" {

  name     = "todos"
  hash_key = "ID"
  attribute {
    name = "ID"
    type = "N"
  }
  read_capacity  = 5
  write_capacity = 5
}

resource "aws_dynamodb_table" "users" {

  name     = "users"
  hash_key = "UserName"
  attribute {
    name = "UserName"
    type = "S"
  }
  read_capacity  = 5
  write_capacity = 5


}