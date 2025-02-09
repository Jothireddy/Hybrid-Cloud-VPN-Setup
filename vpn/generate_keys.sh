#!/bin/bash
wg genkey | tee privatekey | wg pubkey > publickey
echo "WireGuard keys generated: privatekey and publickey"
