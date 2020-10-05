-- HAProxy Lua module for agent-check style healthchecks of HAProxy
-- SPDX-License-Identifier: BSD-2-Clause

--
-- Authors:
-- Robin Johnson <rjohnson@digitalocean.com>
--
-- License: This file is copyright under BSD-2 license:
-- Copyright (c) 2020, Robin H. Johnson <rjohnson@digitalocean.com>
-- Copyright (c) 2020, DigitalOcean
-- All rights reserved.
--
-- If you want to check some other server from HAProxy, this is probably not
-- what you're looking for.
--
-- Applet: haproxy_health.service_health_up
-- Applet: haproxy_health.service_health_ready
-- Applet: haproxy_health.service_health_down
-- Applet: haproxy_health.service_health_maint
-- Applet: haproxy_health.service_health_drain
-- ----------------------------------------------
-- Generate agent-check style healthcheck responses in HTTP reason & HTTP response-body


-- TODO: 
-- - this should offer weight & maxconn
-- - DOWN states support an optional message inside them
--
-- Open question: 
-- - What numeric HTTP codes are meaningful for ExaBGP
--   healthchecks as they stand, and in future? Esp for DRAIN & MAINT states.
--
-- Helpful docs:
-- https://cbonte.github.io/haproxy-dconv/1.8/configuration.html#5.2-agent-check
-- https://www.haproxy.com/blog/using-haproxy-as-an-api-gateway-part-3-health-checks/#gauging-health-with-an-external-agent
-- States:
-- GOOD: UP, READY
-- BAD: DRAIN, MAINT, DOWN|FAILED|STOPPED
-- SPECIAL: maxconn:N, (1-100)%
--



--
-- Namespace for exported objs
--
haproxy_health = {}
haproxy_health.version = '0.1.0'
--
-- Configuration:
--
haproxy_health.conf = {}

-- Helpers:
haproxy_health._service_health = function(applet, status, reason, extra_headers)
  local content_type = 'text/plain'
  local response = core.concat()
  response:add(reason)
  response:add("\n")
  local response_str = response:dump()
  applet:set_status(status, reason)
  -- Important, having a content-length is important for keepalive situation to
  -- know when the response is complete.
  applet:add_header("Content-Length", string.len(response_str))
  applet:add_header("Content-Type", content_type)
  applet:start_response()
  applet:send(response_str)
end

-- Applets:
haproxy_health.service_health_up = function(applet)
  return haproxy_health._service_health(applet, 200, "UP", {})
end

haproxy_health.service_health_ready = function(applet)
  return haproxy_health._service_health(applet, 200, "READY", {})
end

haproxy_health.service_health_down = function(applet)
  return haproxy_health._service_health(applet, 503, "DOWN", {})
end

haproxy_health.service_health_drain = function(applet)
  return haproxy_health._service_health(applet, 503, "DRAIN", {})
end

haproxy_health.service_health_maint = function(applet)
  return haproxy_health._service_health(applet, 503, "MAINT", {})
end

-- Services:
core.register_service("health_up", "http", haproxy_health.service_health_up)
core.register_service("health_ready", "http", haproxy_health.service_health_ready)
core.register_service("health_down", "http", haproxy_health.service_health_down)
core.register_service("health_drain", "http", haproxy_health.service_health_drain)
core.register_service("health_maint", "http", haproxy_health.service_health_maint)
