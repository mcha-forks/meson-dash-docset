#!/usr/bin/env sh

# shellcheck source=./lib/create_table
. "$(dirname "$0")"/lib/create_table
# shellcheck source=./lib/insert
. "$(dirname "$0")"/lib/insert

TYPE="$1"
shift
CATEGORY="$1" # should refer to how the href is "Reference-manual_$CATEGORY"
shift
DB_PATH="$1"
shift

insert_index_terms() {
	# Get each term from an index page and insert
	while [ -n "$1" ]; do
		while read -r line; do
			if echo "$line" | pup -p 'a' | grep -Eoq "Reference-manual_$CATEGORY"; then
				insert_term "$line"
			fi
		done < "$1"

		shift
	done
}

insert_term() {
	LINK="$1"
	NAME="$(echo "$LINK" | pup -p 'a text{}' | sed 's/\"\"//g' | tr -d \\n)"
	PAGE_PATH="$(echo "$LINK" | pup -p 'a attr{href}')"

	insert "$DB_PATH" "$NAME" "$TYPE" "$PAGE_PATH"
}

create_table "$DB_PATH"
insert_index_terms "$@"
