variable "librato_token" {
	description = "The librato token to use"
}


##### Terraform config#####


# The s3 bucket to store terraform config
terraform {
  backend "s3" {
    bucket = "broadly-serverless-deploys"
    region = "us-east-1"
  }
}


##### Define providers #####


provider "aws" {
    region = "us-east-1"
}

provider "librato" {
	email = "assaf@broadly.com"
	token = "${var.librato_token}"
}


##### Define Librato metrics #####


resource "librato_metric" "backend_traffic" {
	name = "statuspage.traffic.backend"
	type = "composite"

	description = "Measure the number of messages deleted"
	attributes {
		display_stacked = false
		display_units_short = "msgs"
		display_units_long	= "messages"
	}

	composite = <<EOF
		sum([
			series("AWS.SQS.NumberOfMessagesDeleted", "aws.us-east-1.*", {function:"sum",period:"300"})
		])
	EOF
}

resource "librato_metric" "web_traffic" {
	name = "statuspage.traffic.web"
	type = "composite"

	description = "Measure the number of heroku requests"
	attributes {
		display_stacked = false
		display_units_short = "rqsts"
		display_units_long	= "requestsa"
	}

	composite = <<EOF
		sum([
			series("router.service", "*", {function:"count",period:"300"})
		])
	EOF
}
