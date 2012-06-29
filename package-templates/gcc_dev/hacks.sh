#!/bin/sh

# keep everything except shared libraries
find . -mindepth 1 -name '*.so*' -delete
