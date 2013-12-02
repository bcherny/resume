#!/bin/bash -x

clear

# start stylus
stylus --watch stylus --out css &

# start coffee
coffee -cwo js coffee &