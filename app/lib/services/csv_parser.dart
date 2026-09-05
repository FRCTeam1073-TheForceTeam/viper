/// Matches the JavaScript csvToArrayOfMaps behavior
List<Map<String, dynamic>> csvToArrayOfMaps(String csv) {
	final List<Map<String, dynamic>> arr = [];
	final List<String> lines = csv.split(RegExp(r'[\r\n]+'));

	if (lines.isEmpty) return arr;

	// Parse header
	final List<String> headers = lines[0].split(',');

	// Parse data rows
	for (int i = 1; i < lines.length; i++) {
		if (lines[i].trim().isEmpty) continue;

		final List<String> data = lines[i].split(',').map((s) => s.trim()).toList();
		final Map<String, dynamic> map = {};

		for (int j = 0; j < data.length; j++) {
			if (j < headers.length) {
				final String value = data[j];
				// Try to parse as integer if it's all digits
				if (RegExp(r'^[0-9]+$').hasMatch(value)) {
					map[headers[j]] = int.parse(value);
				} else {
					map[headers[j]] = unescapeField(value);
				}
			}
		}

		arr.add(map);
	}

	return arr;
}

/// Unescape CSV field values
String unescapeField(String s) {
	return s
		.replaceAll('⏎', '\n')
		.replaceAll('״', '"')
		.replaceAll('،', ',');
}
