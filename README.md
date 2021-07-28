# acme-certbot-demo

## Purpose

This repo provides documentation and a proof-of-concept scaffold for cert automation using the [ACME protocol](https://sectigo.com/resource-library/what-is-acme-protocol).

The poc (currently deployed at http://dco01la-1692s.cfs.its.nyu.edu/) can be recreated by following along with [Steps to Reproduce](docs/STEPS_TO_REPRODUCE.md) on a Red Hat 7 VM.

It uses [Certbot](https://certbot.eff.org/) to (1) provision and manage SSL certificates and (2) configure Apache2 to use them.

Certbot's default ACME server is Boulder (from Let's Encrypt), but it can register other ACME-compliant CAs including [Sectigo](https://sectigo.com/).

This poc employs a semi-manual process that can be automated at a later date with better shell scripts or a provisioning tool like [Ansible](https://www.ansible.com/). (see: [Recommendations](docs/RECOMMENDATIONS.md)).

## ToC
- [Steps to Reproduce](docs/STEPS_TO_REPRODUCE.md)
- [Additional Resources](docs/RESOURCES.md)
- [Recommendations](docs/RECOMMENDATIONS.md)
