#!/bin/sh

for q in $(quest list); do
  rspec $q\_spec.rb --tag solution --tag validation
done
