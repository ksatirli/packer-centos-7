# Packer Image for CentOS 7 AMI using make and Ansible.

This is a Packer machine image for AWS.

## This project is no longer maintained

This repository is no longer actively maintained and is only made available here for reference.

What follows is the original `README.md`:

---

## Requirements

An up-to-date installation of the following software:

* [Go](https://golang.org/doc/install)
* [Packer](https://www.packer.io/downloads.html)
* [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)

## Usage

### Installation

Clone this repository to your local machine.
Run `make check` to check for initial dependencies.
Run `make install-dependencies` to install missing dependencies.

### Creating AMI

Edit the `Makefile` and change the following variables to fit your AWS configuration:

```
AWS_PROFILE = your-profile
AWS_REGION = eu-west-1
```

## Author Information

This module was maintained by the contributors listed on [GitHub](https://github.com/operatehappy/terraform-aws-route53-github-verification/graphs/contributors)

## License

Licensed under the Apache License, Version 2.0 (the "License").

You may obtain a copy of the License at [apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an _"AS IS"_ basis, without WARRANTIES or conditions of any kind, either express or implied.

See the License for the specific language governing permissions and limitations under the License.
