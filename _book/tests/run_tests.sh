#!/bin/sh

for q in $(quest list); do
  echo "Running tests for quest ${q}..."
  rspec $q\_spec.rb --tag solution --tag validation
done
