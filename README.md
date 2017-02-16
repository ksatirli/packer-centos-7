![Packer](https://cultivatedops-static.s3.amazonaws.com/thirdparty/packer/logo.png)

> Packer is a tool for creating machine and container images for multiple platforms from a single source configuration.

---

# Packer machine image for CentOS 7 AMI using make and Ansible.

This is a Packer machine image for AWS.

## Requirements

An up-to-date installation of the following software:

* [Golang](https://golang.org/doc/install)
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
AWS_PROFILE = cultivatedops
AWS_REGION = eu-west-1
```

### Maintainers

This image is currently maintained by the individuals listed below.

* [Kerim Satirli](mailto:kerim@cultivatedops.com)
* [Thomas Krag](mailto:thomas@cultivatedops.com)


### License

`packer-centos-7` is licensed under the _Apache 2.0_ license. A full copy of the license can be found on the [apache.org](http://www.apache.org/licenses/LICENSE-2.0) site.

In short, this license permits you to use this product commercially, distribute this software and make modifications.

The software is provided without warranty and any contributors cannot be held liable for damages. You are also not allowed to use any name, logo or trademark without prior consent.