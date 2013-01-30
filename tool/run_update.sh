#!/bin/bash

stty -echo
dart tool/update.dart "$@"
stty echo