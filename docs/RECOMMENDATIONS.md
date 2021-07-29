# Recommendations

> **Preface:** The following are very loose recommendations that are contingent on service planning and capacity.  
> They should be taken with a grain of salt!


## For infrax
- **Certbot installation should be baked into images using whatever build tools image maintainers already use, e.g., shell scripts, ansible, salt-stack.**   
  + This means users won't need to know or care how certbot was installed.  
  + For this strategy to be broadly usable across university services, images should be available for cloud services beyond OpenShift, e.g., via [AWS ECR](https://aws.amazon.com/ecr/).
  + The idea would be to minimize service owners using any arbitrary image (e.g., `amazonlinux`) and then needing to manually install certbot, troubleshoot it, and register Sectigo (more on this below.)
- **Sectigo registration should also be baked in via secrets to override the default Let's Encrypt ACME server and prevent service owners from dealing with authentication.**  
  + This seems like a tricky policy question wrt: pre-scoping cert domains to VMs or containers, but something like [Hashicorp's Vault](https://www.vaultproject.io/) could be used as a middle layer to manage authentication and environment variables securely.  
  + Regardless, the idea is to make Sectigo the default ACME server with scoped NYU credentials to increase visibility/discovery for more centralized cert management. This could be semi-manual (like the process for incoming cert requests now) in the meantime.

## For servers

- **Documentation cookbooks should be provided for server service owners to actually _use_ certbot.**  
  This should link out to [Cerbot docs](https://certbot.eff.org/instructions) where possible to keep current, and, because Certbot would be preinstalled and Sectigo would be pre-registed (see above), this should theoretically be as simple as:  
  1. instructions to provision a cert (e.g., running `certbot --apache --email <service-user.email>`
  2. instructions to validate server configuiration
  3. instructions to set up the crontab  
+ This would keep the line between infrastructure maintainers and application maintainers distinct: the latter is still responsible for any cerbot steps that require server-specific configuration.
  

## For clusters

- I didn't get particularly far in thinking about automation for autoscaling clusters, but [kubernetes cert-manager](https://cert-manager.io/docs/) includes an [ACME-compliant Issuer type](https://cert-manager.io/docs/configuration/acme/) that looks promising.
