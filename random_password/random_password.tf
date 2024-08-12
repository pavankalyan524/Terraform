resource "random_password" "name" {

    length = 16
    special = true
    upper = true
    lower = true
    numeric = true 
    min_lower = 1
    min_numeric = 1
    min_special = 1
    min_upper = 1

}

output "Generated_password" {

    value = random_password.name.result
}



