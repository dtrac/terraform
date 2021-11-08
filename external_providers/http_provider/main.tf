data "http" "my_ip" {
  url = "http://ifconfig.me"
}

output "my_ip" {
  value = data.http.my_ip.body
}

output "response_header" {
  value = data.http.my_ip.response_headers
}

output "response_date" {
  value = data.http.my_ip.response_headers["Date"]
}


# ============

resource "random_integer" "priority" {
  min = 1
  max = 826

  keepers = {
      data = data.http.my_ip.response_headers["Date"]
  }
}

data "http" "rick_and_morty_api" {
  url = "https://rickandmortyapi.com/api/character/${random_integer.priority.result}"
}

output "r_m_body" {
  value = data.http.rick_and_morty_api.body
}

output "r_m_name" {
  value = jsondecode(data.http.rick_and_morty_api.body)["name"]
}