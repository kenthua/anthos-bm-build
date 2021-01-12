# add port forwarding rule for a service
sudo iptables -t nat -A PREROUTING -p tcp -i wlp2s0 --dport 8080 -j DNAT --to 10.10.0.211:80

# remove port forwarding rule
sudo iptables -t nat -D PREROUTING -p tcp -i wlp2s0 --dport 8080 -j DNAT --to 10.10.0.211:80

# flush the cache
sudo iptables -F -t nat

# readd the routing for the node instances
sudo iptables -t nat -A POSTROUTING -o wlp2s0 -j MASQUERADE

# debugging
sudo iptables -t nat --list
sudo iptables-save -c > /tmp/a
cat /tmp/a
