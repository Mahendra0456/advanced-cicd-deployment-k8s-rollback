#!/bin/bash

set -e

echo "Running application test..."

test -f index.html

grep -q "Week 9 DevOps CI/CD Pipeline" index.html

echo "Application test passed successfully."
