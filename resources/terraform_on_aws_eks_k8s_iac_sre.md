## ☁️ Terraform on AWS EKS Kubernetes IaC SRE

[🔙 Home Page](https://github.com/Valaraucoo/engineering-notes/)

| Title         | Docker and Kubernetes: The Complete Guide                                                                              |
|---------------|------------------------------------------------------------------------------------------------------------------------|
| Source        | [Udemy](https://www.udemy.com/course/terraform-on-aws-eks-kubernetes-iac-sre-50-real-world-demos/)                     |
| Author        | [Kalyan Reddy Daida](https://www.udemy.com/user/kalyan-reddy-9/)                                                       |
| What to learn | `K8s`, `DevOps`, `AWS`, `IaaC`                                                                                         |
| Scope/Topic   | `Software Development`                                                                                                 |
| Description   | AWS EKS IAM, Ingress, EBS CSI, EFS CSI, VPC, Fargate, Application & Network Load Balancer, Autoscaling (CA, HPA, VPA). |
| Status        | `In Progress`                                                                                                          |
| Language      | 🇵🇱 Polish                                                                                                            |
| Last update   | 07.08.2022                                                                                                             |


Trzy kroki podczas konfiguracji Terraform:

- **Inicjalizacja**
- **Walidacja**
- **Planowanie** — pozwala na przejrzenie planowanych zmian przed ich zaakceptowaniem
- **Apply** — wprowadzenie zmian zaplanowanych podczas planowania, tworzy, aktualizuje lub niszczy zasoby
- **Destroy** — usuwanie wprowadzonych zmian oraz całej infrastruktury.

Gdy rozpoczyna się projekt w CWD tworzony jest folder `.terraform`, który przechowuje informacje o wersjach stosowanych modułów i providerów.

Typowe pliki w konfiguracji infrastruktury:

- `main.tf` — definicja i deklaracja zasobów
- `versions.tf` — definicja bloku `terraform`, który definiuje providerów usługi i jego wersję wymaganą w konfiguracji
- `variables.tf` — zmienne wykorzystywane do inputu podczas tworzenia i aktualizacji infrastruktury
- `outputs.tf` — plik ze zdefiniowanymi wyjściami, które są przydatne w procesach wdrożeniowych: `terraform output`

<aside>
⚠️ Terraform automatycznie wykrywa plik z rozszerzeniem `.tf` i na jego podstawie tworzy i zarządza infrastrukturą.

</aside>

### 2.2 Terrraform podstawowe komendy

```bash
# 1. initialize tf backend, providers plugins
# pobierane są paczki i zasoby potrzebne do obsługi wybranego providera
**terraform init**
# tworzony jest plik    .terraform.lock.hcl
# tworozny jest katalog .terraform 
# - zawiera on cache z pluginami i modulami dla wybranego providera
# - oraz dodatkowe pliki konfiguracyjne

# 2. Walidacja poprawności konfiguracji
**terraform validate**

# 3. Plan - tworzy plan wykonania i wdrożenia infrastruktury w AWS Cloud
# w planie określane są operacje, które będą wykonane:
# - create  -> tworzenie nowych zasobów
# - update  -> aktualizacja zasobów i ich parametrów
# - destroy -> usuwanie zasobów
**terraform plan**

# 4. Apply - wdrożenie zmian do Cloud Provider
**terraform apply**

# 5. Destroy
**terraform deastroy**
```

### Terraform Syntax

```bash
# HCL - HashiCorp Language
# Terraform Syntax:
# - Blocks -> e.g. resource, provider
# - Arguments
# - Identifiers
# - Comments

<BLOCK TYPE> "<BLOCK LABEL>" "<BLOCK LABEL>" {
   # block body
   <IDENTIFIER> = <EXPRESSION> # Arguments
   # Arg name   = arg value
}

# AWS Example
resource "aws_instance" "ec2test" {
   ami           = "..."
   instance_type = "t2.micro"
}
```

- **Argumenty** — służą do konfiguracji konkretnego zasobu (`resource`)
    - Argument może być `required` lub `optional`
- **Atrybuty** — to *exposed* wartości dla danego zasobu/bloku, można do nich się odwoływać i korzystać z ich wartości przy pomocy: `resource_type.resource_name.attribute_name`
    - Atrybuty często są przypisywane do zasobów przez providera, np. id zasobu `resource.aws_instance.arn`
- **Meta-argumenty** — zmieniają zachowanie zasobu i nie są specyficzne/typowe dla danego typu zasobu (są **natywne dla tf** nie zasobu), np. `count` and `for_each` , które służą do tworzenia wielu zasobów

**Top-Level Block** — to każdy blok, który może znajdować się na zewnątrz każdego innego bloku (czyli nie może występować wewnątrz innego bloku).

### **Terraform Top-Level Blocks**

- **Fundamental Blocks**
    - Terraform Settings Block
    - Providers Block
    - Resources Block
- **Variable Blocks**
    - Input Variables Block
    - Output Values Block
    - Local Values Block
- **Calling / Referencing Blocks**
    - Data Sources Block
    - Modules Block

**Terraform Block** — specjalny blok, służący do konfiguracji zachowania terraform:

- wymagana jest wersja terraforma
- wymagana jest lista providerów
- wymagany jest terraform backend

**Provider Block** — HEART of Terraform, zasoby potrzebne przez providera muszą być pobrane przed ich użyciem, dlatego należy zdefiniować jakiego oraz jakiej wersji providera będzie się używać.

- Terraform polega na providerach, żeby być w interakcji ze zdalnymi systemami
- Deklaracja providera → instalacja → użycie

```jsx
provider "aws" {
  region = "eu-west-1"
  profile = "default" // or env AWS_PROFILE
}
```

**Resource Block** — opisuje jeden lub więcej obiekt infrastruktury.

Przykłady:

```bash
terraform {
  required_version = "~> 1.2.6"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.25"
    }
  } 
} 

provider "aws" {
	profile = "priv"
  region = "eu-west-1"
  alias = "aws-eu-west-1"
  access_key = "..." // or AWS_ACCESS_KEY_ID
  secret_key = "..." // or AWS_SECRET_ACCESS_KEY
}

# "ec2test" is a local resource name that can be used in module's scope
resource "aws_instance" "ec2test" {
  *provider = aws.aws-eu-west-1*
  ami = "ami-0742b4e673072066f"
  instance_type = "t3.micro"
  tags = {
    "Name" = "EC2 Demo"
  }
}
```

### Resource behavior & Terraform State Basis

- Create Resource
- Destroy Resource
- Update in-place Resource
- Destroy and re-create Resource

**Terraform State** — status konfiguracji infrastruktury, używany jest do porównania prawdziwej/fizycznej infrastruktury z tą która jest w plikach konfiguracyjnych. 

- Każda operacja `apply` wywołuje zmiany w infrastrukturze → podczas tej operacji zmieniany jest również state terraforma
- Status jest przetrzymywany w pliku `terraform.tfstate`
- Zmiany w zasobach *create, destroy, update* muszą być trackowane w state, tak aby podczas kolejnego `apply` tf wiedział co się działo w poprzednich wdrożeniach

### Variables

- **Input Variables**

```jsx
// Basic Example
variable "image_id" {
  type        = string
	default     = "..."
	sensitive   = false
  description = "The id of the machine image (AMI) to use for the server."
}

// Usage
resource "some_resource" "a" {
  image    = var.image_id
}

// Another Example
variable "user_information" {
  type = object({
    name    = string
    address = string
  })
  sensitive = true
}

resource "some_resource" "a" {
  name    = var.user_information.name
  address = var.user_information.address
}

More: https://www.terraform.io/language/values/variables#variables-on-the-command-line
```

- **Output Variables** — służą do:
    - wyświetlanie konkretnych wartości po wykonaniu `apply`
    - *child modules* mogą przekazać swoje outputs do modułu rodzica
    - do zarządzania state
    
    ```jsx
    output "instance_public_ip" {
      value       = aws_instance.example.public_ip
      description = "EC2 Instance Public IP"
      sesitive    = false
    }
    ```
    
- **Local Variables**

### Datasources

**Datasource** — pozwalają Terraform użyć informacji zdefiniowanych w zewnętrznych serwisach, przez inne konfiguracje lub inne funkcje.

```jsx
  data "aws_ami" "example" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  tags = {
    Name   = "app-server"
    Tested = "true"
  }
}
```

Blok `data` prosi TF o odczytanie danych z podanego źródła *aws_ami* i wyeksportowanie rezultatu do lokalnej nazwy *example.* Ta **nazwa może być użyta w zasobach (`resource`) w tym module, np. pobranie interesującego nas ami obrazu z aws.

```jsx
// Example usage
resource "aws_instance" "example" {
  ami           = data.aws_ami.example.id
  instance_type = var.instance_type
  tags = {
	  "Name" = "Example EC2"
  }
}
```

Datasources wspierają `count` i `for_each`, przez co możemy ich używać tak samo jak innymi zasobami.

### Loops, MetaArguments, Splat Operator and Functions

- Variable lists, maps

```jsx
variable "instance_type_list" {
  description = "..."
	type = list(string)
	default = ["t3.micro", "t3.small", "t3.large"]
}

variable "instance_type_map" {
	description = "..."
	type = map(string)
	default = {
		"dev"  = "t3.micro"
		"sta"  = "t3.small"
		"prod" = "t3.large"
	}
}

// Usage:
var.instance_type_list[0]
var.instance_type_map["sta"]
```

- Count (metaArgument) — gdy chcemy utworzyć kilka zasobów tego samego typu

```jsx
resource "aws_instance" "example" {
  count         = 2
  ami           = data.aws_ami.latest.id
  instance_type = var.instance_type_list[count.index]

	tags = {
		"Name" = "Example-${count.index}"
	}
}
```

- For loop with output list/map

```jsx
output "example_list_for_loop" {
  description = "..."
  value = [for instance in aws_instance.example: instance.public_ip]
}

output "example_map_for_loop" {
  description = "..."
  value = {
		for instance in aws_instance.example: instance.id => instance.public_ip
	}
}

```

- Splat operator

```jsx
output "example_splat" {
  description = "..."
	value = aws_instance.example.public_ip // if count in rsrc
// same as 	value = aws_instance.example.*.public_ip
}
```

### Example: Implement AZ Datasources & for_each MetaAttribute usage

```jsx
data "aws_availability_zones" "zones" {
	filter { 
		name   = "opt-in-status"
		values = ["opt-in-not-required"]
	}
}

locals {
	zones = toset(data.aws_availability_zones.zones.names)
}

resource "aws_instance" "example" {
  ami                    = data.aws_ami.latest.id
  instance_type          = var.instance_type_map["sta"]
	key_name               = var.instance_keypair
	vpc_security_group_ids = [...]

	for_each          = local.zones
	availability_zone = each.key

	tags = {
		"Name" = "Example-For-Each-${each.key}"
	}
}

output "instance_public_ips" {
	description = "..."
	value = toset([
		for instance in aws_instance.example: instance.public_ip
	])
}

output "instance_public_dns_map" {
	description = "..."
	value = tomap({
		for az, instance in aws_instance.example:
		az => instance.public_dns
	})
}
```

### Example: Utility for EC2 in multiple AZ

```jsx
# Datasource
data "aws_ami" "example" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  tags = {
    Name   = "app-server"
    Tested = "true"
  }
}

data "aws_availability_zones" "zones" {
	filter {
		name   = "opt-in-status"
		values = ["opt-in-not-required"]
	}
}

data "aws_ec2_instance_type_offerings" "offerings" {
  for_each = toset(data.aws_availability_zones.zones.names)
  location_type = "availability-zone-id"

  filter {
    name   = "instance-type"
    values = ["t2.micro", "t3.micro"]
  }

  filter {
    name   = "location"
    values = [each.key]
  }

}

# Outputs
output "instance_type" {
  value = keys({
    for az, details in data.aws_ec2_instance_type_offerings.offerings:
    az => details.instance_types if length(details.instance_types) > 0
  })
}
```