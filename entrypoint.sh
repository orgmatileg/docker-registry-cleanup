#!/bin/sh

while true; do
  ./cleanup.sh
  sleep $(( 60*60*24 ))  # Sleep for 24 hours
done