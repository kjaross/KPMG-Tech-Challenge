#!/bin/bash

#Variables:
export DATA_KEY="instanceType"

#Query particular data key of an instance:
curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | python -c "import sys, json; print(json.load(sys.stdin))['$DATA_KEY']"


