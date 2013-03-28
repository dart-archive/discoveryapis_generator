#!/bin/bash

#####
# Type Analysis

ANA="dart_analyzer --enable_type_checks --fatal-type-errors --extended-exit-code --type-checks-for-inferred-types --incremental"

echo
echo "Type Analysis, running dart_analyzer..."

EXITSTATUS=0
WARNINGS=0
FAILURES=0
PASSING=0

####
# test files one at a time
#
for file in lib/*.dart
do
  results=`$ANA $file 2>&1`
  exit_code=$?
  if [ $exit_code -eq 2 ]; then
  	let FAILURES++
    EXITSTATUS=1
    echo "$results"
    echo "$file: FAILURE."
  elif [ $exit_code -eq 1 ]; then
  	let WARNINGS++
	echo "$results"
    echo "$file: WARNING."
  elif [ $exit_code -eq 0 ]; then
  	let PASSING++
	echo "$file: Passed analysis."
  else 
	echo "$file: exit code = $exit_code"
fi
done

# This application is not ready until dependencies are updated. 
GENERATED_OUTPUT_DIR=output_drone
rm -rf ${GENERATED_OUTPUT_DIR}
dart bin/generate.dart --all --output ${GENERATED_OUTPUT_DIR}
for package in ${GENERATED_OUTPUT_DIR}/*
do
	echo
	echo "run dart_analyzer on $package"
	if [ -d "$package" ]; then
		pub_result=`pushd $package && pub install && popd`
		# we relax the analyzer here cause the 
		# autogen packages have more dynamic nature to them. 
		cmd="dart_analyzer --enable_type_checks --extended-exit-code --type-checks-for-inferred-types  --package-root $package/packages"
		files="${package}/lib/*.dart"
		for file in $files
		do
			results=`$cmd $file 2>&1`
			exit_code=$?
			if [ $exit_code -eq 2 ]; then
				let FAILURES++
			    EXITSTATUS=1
			    echo "$results"
			    echo "$file: FAILURE."
			elif [ $exit_code -eq 1 ]; then
				let WARNINGS++
				echo "$results"
			    echo "$file: WARNING."
			elif [ $exit_code -eq 0 ]; then
				let PASSING++
				echo "$file: Passed analysis."
			else 
				echo "$file: exit code = $exit_code"
			fi
		done
	fi
done

echo "####################################################"
echo "PASSING = $PASSING"
echo "WARNINGS = $WARNINGS"
echo "FAILURES = $FAILURES"
echo "####################################################"

exit $EXITSTATUS