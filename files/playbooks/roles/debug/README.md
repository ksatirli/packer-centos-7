# debug

An Ansible role to easily print debug information.

## Requirements

* Ansible 2.1 or newer

## Role Variables

This role supports the following variables:

| variable           | description                                           |
|--------------------|-------------------------------------------------------|
| `verbosity_level`  | Verbosity Level at which to display debug information |

## Dependencies

This role has no (external) dependencies.

## Example Playbook

The following example will output debug information when run with verbosity level _2_ (`-vv`):

```
  - hosts: localhost
    roles:
      - role: debug
        vars:
          verbosity_level: 2
```

## Author Information

This role is currently maintained by the individuals listed below.

* [Kerim Satirli](mailto:kerim@cultivatedops.com)

## License

`ansible-role-debug` is licensed under the _Apache 2.0_ license. A full copy of the license can be found on the [apache.org](http://www.apache.org/licenses/LICENSE-2.0) site.

In short, this license permits you to use this product commercially, distribute this software and make modifications.

The software is provided without warranty and any contributors cannot be held liable for damages. You are also not allowed to use any name, logo or trademark without prior consent.
