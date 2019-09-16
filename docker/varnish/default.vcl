# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

import std;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "nginx";
    .port = "80";
    .connect_timeout = 1s;
    .probe = {
        .url = "/";
        .expected_response = 403;
        .timeout = 1s;
        .interval = 5s;
        .window = 5;
        .threshold = 3;
    }
}

acl local {
    "localhost";
}

sub vcl_recv {
    # Happens before we check if we have this in cache already.
    #
    # Typically you clean up the request here, removing cookies you don't need,
    # rewriting the request, etc.
    if (req.method == "PURGE") {
      if (client.ip ~ local) {
         return(purge);
      } else {
         return(synth(403, "Access denied."));
      }
    }

    if (std.healthy(req.backend_hint)) {
      # change the behavior for healthy backends: Cap grace to 10s
      set req.grace = 10s;
    }

    unset req.http.cookie;
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.
    unset beresp.http.set-cookie;
    set beresp.ttl = 6h;
    set beresp.grace = 24h;
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.
}

