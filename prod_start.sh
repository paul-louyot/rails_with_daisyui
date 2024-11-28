#!/bin/bash

# Start the background job
nohup bin/jobs &

# Now start the Rails server
bin/rails server -b 0.0.0.0 -p 8080
