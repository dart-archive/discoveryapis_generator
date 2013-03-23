#!/bin/bash

#####
# Type Analysis

ANA="dart_analyzer --enable_type_checks --fatal-type-errors --extended-exit-code --type-checks-for-inferred-types --incremental"

echo
echo "Type Analysis, running dart_analyzer..."

EXITSTATUS=0

####
# test files one at a time
#
for file in lib/*.dart
do
  results=`$ANA $file 2>&1`
  if [ -n "$results" ]; then
    EXITSTATUS=1
    echo "$results"
    echo "$file: FAILURE."
  else
    echo "$file: Passed analysis."
  fi
done

exit $EXITSTATUS

# This application is not ready until dependencies are updated. 
GENERATED_OUTPUT_DIR=./ci_api_test

dart bin/generate.dart --all --output ${GENERATED_OUTPUT_DIR}
for package in ${GENERATED_OUTPUT_DIR}/*
do
	if [ -d "$package" ]; then
		pub_result=`pushd $package && pub install && popd`
		cmd="$ANA --package-root $package/packages"
		files="${package}/lib/*.dart"
		for file in $files
		do
			#echo $cmd $file
			results=`$cmd $file 2>&1`
			if [ -n "$results" ]; then
			    EXITSTATUS=1
			    echo "$results"
			    echo "$file: FAILURE."
			else
			    echo "$file: Passed analysis."
			fi
		done
	fi
done