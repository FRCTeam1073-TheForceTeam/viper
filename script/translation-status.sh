#!/bin/bash

set -e

(
	for file in www/*.html www/*/*.html
	do
		if grep -q main.js "$file"
		then
			if grep -LEq 'data-i18n|markdown.js' "$file"
			then
				echo "✅ $file"
			else
				echo "❌ $file"
			fi
		fi
	done
	for file in www/*.md www/*/*.md
	do
		if echo "$file" | grep -qEv '\.[a-z]{2}(_[a-z]{2})?\.md'
		then
			if [ ! -e "${file/.md/.pt.md}" ]
			then
				echo "❌ $file"
			else
				echo "✅ $file"
			fi
		fi
	done
) | sed -E 's|www/||g' | sort
