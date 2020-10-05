# agent-check of HAProxy
This code & HAProxy example configuration provides a way to expose the health
of HAProxy itself.

It should NOT be confused with the agent-check functionality that HAProxy can
use to check backend servers.

The output is formatted to be similar to the agent-check TCP check used by
HAProxy, but sent via HTTP rather than TCP.

The exampe configuration uses two files which can be used to set the output
into `MAINT` or `DRAIN` states. The files are `haproxy_maint.acl`,
`haproxy_drain.acl` respectively.

One example usage might be checking the state of HAProxy from a seperate L4
load balancer layer [#L4LB]. 
- If HAProxy is up AND ready, new connections should be delivered to HAProxy. 
- If HAProxy is up, but going down soon, no new connections should be accepted,
  but it may be desirable to let long-running connections continue (e.g.
  in-flight uploads/downloads)

Beware that if you naively connect the `DOWN`/`DRAIN`/`MAINT` states to some
BGP announcement, but have in-flight active connections, the BGP route being
withdrawn may then cause the connections to break.

## TODO:
- Implement `weight` output
- Implement `maxconn` output

## References:
### agent-check
- https://cbonte.github.io/haproxy-dconv/1.8/configuration.html#5.2-agent-check
- https://www.haproxy.com/blog/using-haproxy-as-an-api-gateway-part-3-health-checks/#gauging-health-with-an-external-agent
### L4 load balancer (L4LB)
- [Wragg, D. 2020 & Cloudflare. (2020/09/20). Unimog - Cloudflare's edge load balancer](https://blog.cloudflare.com/unimog-cloudflares-edge-load-balancer/)
- [Daniel E. Eisenbud, Cheng Yi, Carlo Contavalli, Cody Smith, Roman Kononov, Eric Mann-Hielscher, Ardas Cilingiroglu, Bin Cheyney, Wentao Shang, & Jinnah Dylan Hosein (2016). Maglev: A Fast and Reliable Software Network Load Balancer. In 13th USENIX Symposium on Networked Systems Design and Implementation (NSDI 16) (pp. 523–535). USENIX Association.](https://www.usenix.org/conference/nsdi16/technical-sessions/presentation/eisenbud)
- [GitHub Engineering. (2016/09/22). Introducing the GitHub Load Balancer](https://github.blog/2016-09-22-introducing-glb/)
- [Bernat, V. (2018/05/23). Multi-tier load-balancing with Linux](https://vincent.bernat.ch/en/blog/2018-multi-tier-loadbalancer)

## License & Copyright.
This code is licensed under BSD 2-Clause "Simplified" License, (SPDX:BSD-2-Clause).
Copyright (c) 2020, Robin H. Johnson <rjohnson@digitalocean.com> & DigitalOcean.
