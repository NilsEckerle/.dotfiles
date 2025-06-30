#!/bin/bash

set -e  # Exit on any error

kill $(cat ~/.camera_process.pid)
rm ~/.camera_process.pid

