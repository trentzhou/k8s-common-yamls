#!/usr/bin/env bash

kubectl apply -f yamls

# get local IP address
LOCAL_IP=`ip -4 addr show dev eth0 | sed -n 's/.*inet \(.*\)\/.*/\1/p'`

KIBANA_PORT=5901
GRAFANA_PORT=5902

if [ -n "$LOCAL_IP" ]; then
    # add external port for dashboard
    kubectl patch service kubernetes-dashboard -n kube-system --type=json -p="[{\"op\": \"add\", \"path\": \"/spec/externalIPs\", \"value\": [\"$LOCAL_IP\"]}]"
    # add external port for kibana
    kubectl patch service kibana --type=json -p="[{\"op\": \"replace\", \"path\": \"/spec/ports/0/port\", \"value\": $KIBANA_PORT}]"
    kubectl patch service kibana --type=json -p="[{\"op\": \"add\", \"path\": \"/spec/externalIPs\", \"value\": [\"$LOCAL_IP\"]}]"
    # add external port for monitoringgrafana
    kubectl patch service monitoring-grafana -n kube-system --type=json -p="[{\"op\": \"replace\", \"path\": \"/spec/ports/0/port\", \"value\": $GRAFANA_PORT}]"
    kubectl patch service monitoring-grafana -n kube-system --type=json -p="[{\"op\": \"add\", \"path\": \"/spec/externalIPs\", \"value\": [\"$LOCAL_IP\"]}]"

    # tell the user
    echo "You can access the services with:"
    echo "  dashboard: https://$LOCAL_IP"
    echo "  kibana:    http://$LOCAL_IP:$KIBANA_PORT"
    echo "  grafana:   http://$LOCAL_IP:$GRAFANA_PORT"
fi

