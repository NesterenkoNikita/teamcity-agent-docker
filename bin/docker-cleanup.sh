#!/bin/sh
# Cleanup docker files: untagged containers and images.
#
# Use `docker-cleanup -n` for a dry run to see what would be deleted.

print_exited_containers_info() {
	docker ps -a --no-trunc | grep 'Exit' | awk '{print $0}'
}

print_exited_containers_ids() {
	docker ps -a --no-trunc | grep 'Exit' | awk '{print $1}'
}

print_untagged_images() {
	docker images -a -q --no-trunc
}

# Dry-run.
if [ "$1" = "-n" ]; then
	echo "=== Exited containers: ==="
	print_exited_containers_info
	echo

	echo "=== Untagged images: ==="
	print_untagged_images

	exit
fi
if [ -n "$1" ]; then
	echo "Cleanup docker files: remove exited containers and images."
	echo "Usage: ${0##*/} [-n]"
	echo "   -n: dry run: display what would get removed."
	exit 1
fi

echo "Removing exited containers:"
print_exited_containers_ids | xargs --no-run-if-empty -r docker rm


echo "Removing untagged images:"
# I can't find a way how to filter images which is not used by running containers
# that's why we are ignoring error output
print_untagged_images | xargs -r docker rmi 2>/dev/null