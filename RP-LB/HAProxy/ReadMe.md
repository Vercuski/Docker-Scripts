Frontend: http://localhost:8100 (round-robins between the Nginx and Apache web server stacks)<br>
Stats: http://localhost:8404<br>
Edit `haproxy.cfg`, then `docker kill -s HUP haproxy` to reload.
