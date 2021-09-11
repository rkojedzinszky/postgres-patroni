#!/bin/sh

T_POSTFIXES=

FULLTAG=$(git describe --tags)
if [ "$DRONE_BUILD_EVENT" != "tag" ]; then
	FULLTAG=${FULLTAG%.*}
	T_POSTFIXES="latest $(TZ=UTC date +%Y%m%d)"
fi

# Generate different tags
tags=
tag=$FULLTAG
while : ; do
	tags="$tags $tag"
	next=${tag%.*}
	if [ "$next" = "$tag" ]; then
		break
	fi
	tag=$next
done

TAGS=

if [ -z "$T_POSTFIXES" ]; then
	TAGS="$tags"
else
	for t in $tags; do
		for p in $T_POSTFIXES; do
			TAGS="$TAGS $t-$p"
		done
	done
fi

FINAL_TAGS=
if [ $# -eq 0 ]; then
	FINAL_TAGS="$TAGS"
else
	# Append command line suffixes
	for t in $TAGS; do
		for cmdsuffix ; do
			FINAL_TAGS="$FINAL_TAGS $t-$cmdsuffix"
		done
	done
fi

echo $FINAL_TAGS | sed -e 's/ /,/g'
