data "external" "example" {
  program = ["pwsh", "./program.ps1"]

  query = {
    # arbitrary map from strings to strings, passed
    # to the external program as the data query.
    name = "Dan"
  }
}

output "result" {
    value = data.external.example.result
}

output "message" {
    value = data.external.example.result["Message"]
}