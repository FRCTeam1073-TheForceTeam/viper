// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scout_database.dart';

// ignore_for_file: type=lint
class $ServerConfigTable extends ServerConfig
		with TableInfo<$ServerConfigTable, ServerConfigData> {
	@override
	final GeneratedDatabase attachedDatabase;
	final String? _alias;
	$ServerConfigTable(this.attachedDatabase, [this._alias]);
	static const VerificationMeta _idMeta = const VerificationMeta('id');
	@override
	late final GeneratedColumn<int> id = GeneratedColumn<int>(
		'id',
		aliasedName,
		false,
		hasAutoIncrement: true,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
		defaultConstraints: GeneratedColumn.constraintIsAlways(
			'PRIMARY KEY AUTOINCREMENT',
		),
	);
	static const VerificationMeta _backendUrlMeta = const VerificationMeta(
		'backendUrl',
	);
	@override
	late final GeneratedColumn<String> backendUrl = GeneratedColumn<String>(
		'backend_url',
		aliasedName,
		false,
		type: DriftSqlType.string,
		requiredDuringInsert: true,
	);
	static const VerificationMeta _usernameMeta = const VerificationMeta(
		'username',
	);
	@override
	late final GeneratedColumn<String> username = GeneratedColumn<String>(
		'username',
		aliasedName,
		true,
		type: DriftSqlType.string,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _passwordMeta = const VerificationMeta(
		'password',
	);
	@override
	late final GeneratedColumn<String> password = GeneratedColumn<String>(
		'password',
		aliasedName,
		true,
		type: DriftSqlType.string,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _selectedEventIdMeta = const VerificationMeta(
		'selectedEventId',
	);
	@override
	late final GeneratedColumn<String> selectedEventId = GeneratedColumn<String>(
		'selected_event_id',
		aliasedName,
		true,
		type: DriftSqlType.string,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _selectedTeamMeta = const VerificationMeta(
		'selectedTeam',
	);
	@override
	late final GeneratedColumn<String> selectedTeam = GeneratedColumn<String>(
		'selected_team',
		aliasedName,
		true,
		type: DriftSqlType.string,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _scouterNameMeta = const VerificationMeta(
		'scouterName',
	);
	@override
	late final GeneratedColumn<String> scouterName = GeneratedColumn<String>(
		'scouter_name',
		aliasedName,
		true,
		type: DriftSqlType.string,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _lastEventChangeDateMeta =
			const VerificationMeta('lastEventChangeDate');
	@override
	late final GeneratedColumn<DateTime> lastEventChangeDate =
			GeneratedColumn<DateTime>(
				'last_event_change_date',
				aliasedName,
				true,
				type: DriftSqlType.dateTime,
				requiredDuringInsert: false,
			);
	@override
	List<GeneratedColumn> get $columns => [
		id,
		backendUrl,
		username,
		password,
		selectedEventId,
		selectedTeam,
		scouterName,
		lastEventChangeDate,
	];
	@override
	String get aliasedName => _alias ?? actualTableName;
	@override
	String get actualTableName => $name;
	static const String $name = 'server_config';
	@override
	VerificationContext validateIntegrity(
		Insertable<ServerConfigData> instance, {
		bool isInserting = false,
	}) {
		final context = VerificationContext();
		final data = instance.toColumns(true);
		if (data.containsKey('id')) {
			context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
		}
		if (data.containsKey('backend_url')) {
			context.handle(
				_backendUrlMeta,
				backendUrl.isAcceptableOrUnknown(data['backend_url']!, _backendUrlMeta),
			);
		} else if (isInserting) {
			context.missing(_backendUrlMeta);
		}
		if (data.containsKey('username')) {
			context.handle(
				_usernameMeta,
				username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
			);
		}
		if (data.containsKey('password')) {
			context.handle(
				_passwordMeta,
				password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
			);
		}
		if (data.containsKey('selected_event_id')) {
			context.handle(
				_selectedEventIdMeta,
				selectedEventId.isAcceptableOrUnknown(
					data['selected_event_id']!,
					_selectedEventIdMeta,
				),
			);
		}
		if (data.containsKey('selected_team')) {
			context.handle(
				_selectedTeamMeta,
				selectedTeam.isAcceptableOrUnknown(
					data['selected_team']!,
					_selectedTeamMeta,
				),
			);
		}
		if (data.containsKey('scouter_name')) {
			context.handle(
				_scouterNameMeta,
				scouterName.isAcceptableOrUnknown(
					data['scouter_name']!,
					_scouterNameMeta,
				),
			);
		}
		if (data.containsKey('last_event_change_date')) {
			context.handle(
				_lastEventChangeDateMeta,
				lastEventChangeDate.isAcceptableOrUnknown(
					data['last_event_change_date']!,
					_lastEventChangeDateMeta,
				),
			);
		}
		return context;
	}

	@override
	Set<GeneratedColumn> get $primaryKey => {id};
	@override
	ServerConfigData map(Map<String, dynamic> data, {String? tablePrefix}) {
		final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
		return ServerConfigData(
			id: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}id'],
			)!,
			backendUrl: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}backend_url'],
			)!,
			username: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}username'],
			),
			password: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}password'],
			),
			selectedEventId: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}selected_event_id'],
			),
			selectedTeam: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}selected_team'],
			),
			scouterName: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}scouter_name'],
			),
			lastEventChangeDate: attachedDatabase.typeMapping.read(
				DriftSqlType.dateTime,
				data['${effectivePrefix}last_event_change_date'],
			),
		);
	}

	@override
	$ServerConfigTable createAlias(String alias) {
		return $ServerConfigTable(attachedDatabase, alias);
	}
}

class ServerConfigData extends DataClass
		implements Insertable<ServerConfigData> {
	final int id;
	final String backendUrl;
	final String? username;
	final String? password;
	final String? selectedEventId;
	final String? selectedTeam;
	final String? scouterName;
	final DateTime? lastEventChangeDate;
	const ServerConfigData({
		required this.id,
		required this.backendUrl,
		this.username,
		this.password,
		this.selectedEventId,
		this.selectedTeam,
		this.scouterName,
		this.lastEventChangeDate,
	});
	@override
	Map<String, Expression> toColumns(bool nullToAbsent) {
		final map = <String, Expression>{};
		map['id'] = Variable<int>(id);
		map['backend_url'] = Variable<String>(backendUrl);
		if (!nullToAbsent || username != null) {
			map['username'] = Variable<String>(username);
		}
		if (!nullToAbsent || password != null) {
			map['password'] = Variable<String>(password);
		}
		if (!nullToAbsent || selectedEventId != null) {
			map['selected_event_id'] = Variable<String>(selectedEventId);
		}
		if (!nullToAbsent || selectedTeam != null) {
			map['selected_team'] = Variable<String>(selectedTeam);
		}
		if (!nullToAbsent || scouterName != null) {
			map['scouter_name'] = Variable<String>(scouterName);
		}
		if (!nullToAbsent || lastEventChangeDate != null) {
			map['last_event_change_date'] = Variable<DateTime>(lastEventChangeDate);
		}
		return map;
	}

	ServerConfigCompanion toCompanion(bool nullToAbsent) {
		return ServerConfigCompanion(
			id: Value(id),
			backendUrl: Value(backendUrl),
			username: username == null && nullToAbsent
					? const Value.absent()
					: Value(username),
			password: password == null && nullToAbsent
					? const Value.absent()
					: Value(password),
			selectedEventId: selectedEventId == null && nullToAbsent
					? const Value.absent()
					: Value(selectedEventId),
			selectedTeam: selectedTeam == null && nullToAbsent
					? const Value.absent()
					: Value(selectedTeam),
			scouterName: scouterName == null && nullToAbsent
					? const Value.absent()
					: Value(scouterName),
			lastEventChangeDate: lastEventChangeDate == null && nullToAbsent
					? const Value.absent()
					: Value(lastEventChangeDate),
		);
	}

	factory ServerConfigData.fromJson(
		Map<String, dynamic> json, {
		ValueSerializer? serializer,
	}) {
		serializer ??= driftRuntimeOptions.defaultSerializer;
		return ServerConfigData(
			id: serializer.fromJson<int>(json['id']),
			backendUrl: serializer.fromJson<String>(json['backendUrl']),
			username: serializer.fromJson<String?>(json['username']),
			password: serializer.fromJson<String?>(json['password']),
			selectedEventId: serializer.fromJson<String?>(json['selectedEventId']),
			selectedTeam: serializer.fromJson<String?>(json['selectedTeam']),
			scouterName: serializer.fromJson<String?>(json['scouterName']),
			lastEventChangeDate: serializer.fromJson<DateTime?>(
				json['lastEventChangeDate'],
			),
		);
	}
	@override
	Map<String, dynamic> toJson({ValueSerializer? serializer}) {
		serializer ??= driftRuntimeOptions.defaultSerializer;
		return <String, dynamic>{
			'id': serializer.toJson<int>(id),
			'backendUrl': serializer.toJson<String>(backendUrl),
			'username': serializer.toJson<String?>(username),
			'password': serializer.toJson<String?>(password),
			'selectedEventId': serializer.toJson<String?>(selectedEventId),
			'selectedTeam': serializer.toJson<String?>(selectedTeam),
			'scouterName': serializer.toJson<String?>(scouterName),
			'lastEventChangeDate': serializer.toJson<DateTime?>(lastEventChangeDate),
		};
	}

	ServerConfigData copyWith({
		int? id,
		String? backendUrl,
		Value<String?> username = const Value.absent(),
		Value<String?> password = const Value.absent(),
		Value<String?> selectedEventId = const Value.absent(),
		Value<String?> selectedTeam = const Value.absent(),
		Value<String?> scouterName = const Value.absent(),
		Value<DateTime?> lastEventChangeDate = const Value.absent(),
	}) => ServerConfigData(
		id: id ?? this.id,
		backendUrl: backendUrl ?? this.backendUrl,
		username: username.present ? username.value : this.username,
		password: password.present ? password.value : this.password,
		selectedEventId: selectedEventId.present
				? selectedEventId.value
				: this.selectedEventId,
		selectedTeam: selectedTeam.present ? selectedTeam.value : this.selectedTeam,
		scouterName: scouterName.present ? scouterName.value : this.scouterName,
		lastEventChangeDate: lastEventChangeDate.present
				? lastEventChangeDate.value
				: this.lastEventChangeDate,
	);
	ServerConfigData copyWithCompanion(ServerConfigCompanion data) {
		return ServerConfigData(
			id: data.id.present ? data.id.value : this.id,
			backendUrl: data.backendUrl.present
					? data.backendUrl.value
					: this.backendUrl,
			username: data.username.present ? data.username.value : this.username,
			password: data.password.present ? data.password.value : this.password,
			selectedEventId: data.selectedEventId.present
					? data.selectedEventId.value
					: this.selectedEventId,
			selectedTeam: data.selectedTeam.present
					? data.selectedTeam.value
					: this.selectedTeam,
			scouterName: data.scouterName.present
					? data.scouterName.value
					: this.scouterName,
			lastEventChangeDate: data.lastEventChangeDate.present
					? data.lastEventChangeDate.value
					: this.lastEventChangeDate,
		);
	}

	@override
	String toString() {
		return (StringBuffer('ServerConfigData(')
					..write('id: $id, ')
					..write('backendUrl: $backendUrl, ')
					..write('username: $username, ')
					..write('password: $password, ')
					..write('selectedEventId: $selectedEventId, ')
					..write('selectedTeam: $selectedTeam, ')
					..write('scouterName: $scouterName, ')
					..write('lastEventChangeDate: $lastEventChangeDate')
					..write(')'))
				.toString();
	}

	@override
	int get hashCode => Object.hash(
		id,
		backendUrl,
		username,
		password,
		selectedEventId,
		selectedTeam,
		scouterName,
		lastEventChangeDate,
	);
	@override
	bool operator ==(Object other) =>
			identical(this, other) ||
			(other is ServerConfigData &&
					other.id == this.id &&
					other.backendUrl == this.backendUrl &&
					other.username == this.username &&
					other.password == this.password &&
					other.selectedEventId == this.selectedEventId &&
					other.selectedTeam == this.selectedTeam &&
					other.scouterName == this.scouterName &&
					other.lastEventChangeDate == this.lastEventChangeDate);
}

class ServerConfigCompanion extends UpdateCompanion<ServerConfigData> {
	final Value<int> id;
	final Value<String> backendUrl;
	final Value<String?> username;
	final Value<String?> password;
	final Value<String?> selectedEventId;
	final Value<String?> selectedTeam;
	final Value<String?> scouterName;
	final Value<DateTime?> lastEventChangeDate;
	const ServerConfigCompanion({
		this.id = const Value.absent(),
		this.backendUrl = const Value.absent(),
		this.username = const Value.absent(),
		this.password = const Value.absent(),
		this.selectedEventId = const Value.absent(),
		this.selectedTeam = const Value.absent(),
		this.scouterName = const Value.absent(),
		this.lastEventChangeDate = const Value.absent(),
	});
	ServerConfigCompanion.insert({
		this.id = const Value.absent(),
		required String backendUrl,
		this.username = const Value.absent(),
		this.password = const Value.absent(),
		this.selectedEventId = const Value.absent(),
		this.selectedTeam = const Value.absent(),
		this.scouterName = const Value.absent(),
		this.lastEventChangeDate = const Value.absent(),
	}) : backendUrl = Value(backendUrl);
	static Insertable<ServerConfigData> custom({
		Expression<int>? id,
		Expression<String>? backendUrl,
		Expression<String>? username,
		Expression<String>? password,
		Expression<String>? selectedEventId,
		Expression<String>? selectedTeam,
		Expression<String>? scouterName,
		Expression<DateTime>? lastEventChangeDate,
	}) {
		return RawValuesInsertable({
			if (id != null) 'id': id,
			if (backendUrl != null) 'backend_url': backendUrl,
			if (username != null) 'username': username,
			if (password != null) 'password': password,
			if (selectedEventId != null) 'selected_event_id': selectedEventId,
			if (selectedTeam != null) 'selected_team': selectedTeam,
			if (scouterName != null) 'scouter_name': scouterName,
			if (lastEventChangeDate != null)
				'last_event_change_date': lastEventChangeDate,
		});
	}

	ServerConfigCompanion copyWith({
		Value<int>? id,
		Value<String>? backendUrl,
		Value<String?>? username,
		Value<String?>? password,
		Value<String?>? selectedEventId,
		Value<String?>? selectedTeam,
		Value<String?>? scouterName,
		Value<DateTime?>? lastEventChangeDate,
	}) {
		return ServerConfigCompanion(
			id: id ?? this.id,
			backendUrl: backendUrl ?? this.backendUrl,
			username: username ?? this.username,
			password: password ?? this.password,
			selectedEventId: selectedEventId ?? this.selectedEventId,
			selectedTeam: selectedTeam ?? this.selectedTeam,
			scouterName: scouterName ?? this.scouterName,
			lastEventChangeDate: lastEventChangeDate ?? this.lastEventChangeDate,
		);
	}

	@override
	Map<String, Expression> toColumns(bool nullToAbsent) {
		final map = <String, Expression>{};
		if (id.present) {
			map['id'] = Variable<int>(id.value);
		}
		if (backendUrl.present) {
			map['backend_url'] = Variable<String>(backendUrl.value);
		}
		if (username.present) {
			map['username'] = Variable<String>(username.value);
		}
		if (password.present) {
			map['password'] = Variable<String>(password.value);
		}
		if (selectedEventId.present) {
			map['selected_event_id'] = Variable<String>(selectedEventId.value);
		}
		if (selectedTeam.present) {
			map['selected_team'] = Variable<String>(selectedTeam.value);
		}
		if (scouterName.present) {
			map['scouter_name'] = Variable<String>(scouterName.value);
		}
		if (lastEventChangeDate.present) {
			map['last_event_change_date'] = Variable<DateTime>(
				lastEventChangeDate.value,
			);
		}
		return map;
	}

	@override
	String toString() {
		return (StringBuffer('ServerConfigCompanion(')
					..write('id: $id, ')
					..write('backendUrl: $backendUrl, ')
					..write('username: $username, ')
					..write('password: $password, ')
					..write('selectedEventId: $selectedEventId, ')
					..write('selectedTeam: $selectedTeam, ')
					..write('scouterName: $scouterName, ')
					..write('lastEventChangeDate: $lastEventChangeDate')
					..write(')'))
				.toString();
	}
}

class $EventTable extends Event with TableInfo<$EventTable, EventData> {
	@override
	final GeneratedDatabase attachedDatabase;
	final String? _alias;
	$EventTable(this.attachedDatabase, [this._alias]);
	static const VerificationMeta _eventIdMeta = const VerificationMeta(
		'eventId',
	);
	@override
	late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
		'event_id',
		aliasedName,
		false,
		type: DriftSqlType.string,
		requiredDuringInsert: true,
	);
	static const VerificationMeta _nameMeta = const VerificationMeta('name');
	@override
	late final GeneratedColumn<String> name = GeneratedColumn<String>(
		'name',
		aliasedName,
		false,
		type: DriftSqlType.string,
		requiredDuringInsert: true,
	);
	static const VerificationMeta _locationMeta = const VerificationMeta(
		'location',
	);
	@override
	late final GeneratedColumn<String> location = GeneratedColumn<String>(
		'location',
		aliasedName,
		true,
		type: DriftSqlType.string,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _startDateMeta = const VerificationMeta(
		'startDate',
	);
	@override
	late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
		'start_date',
		aliasedName,
		true,
		type: DriftSqlType.dateTime,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _endDateMeta = const VerificationMeta(
		'endDate',
	);
	@override
	late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
		'end_date',
		aliasedName,
		true,
		type: DriftSqlType.dateTime,
		requiredDuringInsert: false,
	);
	@override
	List<GeneratedColumn> get $columns => [
		eventId,
		name,
		location,
		startDate,
		endDate,
	];
	@override
	String get aliasedName => _alias ?? actualTableName;
	@override
	String get actualTableName => $name;
	static const String $name = 'event';
	@override
	VerificationContext validateIntegrity(
		Insertable<EventData> instance, {
		bool isInserting = false,
	}) {
		final context = VerificationContext();
		final data = instance.toColumns(true);
		if (data.containsKey('event_id')) {
			context.handle(
				_eventIdMeta,
				eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
			);
		} else if (isInserting) {
			context.missing(_eventIdMeta);
		}
		if (data.containsKey('name')) {
			context.handle(
				_nameMeta,
				name.isAcceptableOrUnknown(data['name']!, _nameMeta),
			);
		} else if (isInserting) {
			context.missing(_nameMeta);
		}
		if (data.containsKey('location')) {
			context.handle(
				_locationMeta,
				location.isAcceptableOrUnknown(data['location']!, _locationMeta),
			);
		}
		if (data.containsKey('start_date')) {
			context.handle(
				_startDateMeta,
				startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
			);
		}
		if (data.containsKey('end_date')) {
			context.handle(
				_endDateMeta,
				endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
			);
		}
		return context;
	}

	@override
	Set<GeneratedColumn> get $primaryKey => {eventId};
	@override
	EventData map(Map<String, dynamic> data, {String? tablePrefix}) {
		final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
		return EventData(
			eventId: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}event_id'],
			)!,
			name: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}name'],
			)!,
			location: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}location'],
			),
			startDate: attachedDatabase.typeMapping.read(
				DriftSqlType.dateTime,
				data['${effectivePrefix}start_date'],
			),
			endDate: attachedDatabase.typeMapping.read(
				DriftSqlType.dateTime,
				data['${effectivePrefix}end_date'],
			),
		);
	}

	@override
	$EventTable createAlias(String alias) {
		return $EventTable(attachedDatabase, alias);
	}
}

class EventData extends DataClass implements Insertable<EventData> {
	final String eventId;
	final String name;
	final String? location;
	final DateTime? startDate;
	final DateTime? endDate;
	const EventData({
		required this.eventId,
		required this.name,
		this.location,
		this.startDate,
		this.endDate,
	});
	@override
	Map<String, Expression> toColumns(bool nullToAbsent) {
		final map = <String, Expression>{};
		map['event_id'] = Variable<String>(eventId);
		map['name'] = Variable<String>(name);
		if (!nullToAbsent || location != null) {
			map['location'] = Variable<String>(location);
		}
		if (!nullToAbsent || startDate != null) {
			map['start_date'] = Variable<DateTime>(startDate);
		}
		if (!nullToAbsent || endDate != null) {
			map['end_date'] = Variable<DateTime>(endDate);
		}
		return map;
	}

	EventCompanion toCompanion(bool nullToAbsent) {
		return EventCompanion(
			eventId: Value(eventId),
			name: Value(name),
			location: location == null && nullToAbsent
					? const Value.absent()
					: Value(location),
			startDate: startDate == null && nullToAbsent
					? const Value.absent()
					: Value(startDate),
			endDate: endDate == null && nullToAbsent
					? const Value.absent()
					: Value(endDate),
		);
	}

	factory EventData.fromJson(
		Map<String, dynamic> json, {
		ValueSerializer? serializer,
	}) {
		serializer ??= driftRuntimeOptions.defaultSerializer;
		return EventData(
			eventId: serializer.fromJson<String>(json['eventId']),
			name: serializer.fromJson<String>(json['name']),
			location: serializer.fromJson<String?>(json['location']),
			startDate: serializer.fromJson<DateTime?>(json['startDate']),
			endDate: serializer.fromJson<DateTime?>(json['endDate']),
		);
	}
	@override
	Map<String, dynamic> toJson({ValueSerializer? serializer}) {
		serializer ??= driftRuntimeOptions.defaultSerializer;
		return <String, dynamic>{
			'eventId': serializer.toJson<String>(eventId),
			'name': serializer.toJson<String>(name),
			'location': serializer.toJson<String?>(location),
			'startDate': serializer.toJson<DateTime?>(startDate),
			'endDate': serializer.toJson<DateTime?>(endDate),
		};
	}

	EventData copyWith({
		String? eventId,
		String? name,
		Value<String?> location = const Value.absent(),
		Value<DateTime?> startDate = const Value.absent(),
		Value<DateTime?> endDate = const Value.absent(),
	}) => EventData(
		eventId: eventId ?? this.eventId,
		name: name ?? this.name,
		location: location.present ? location.value : this.location,
		startDate: startDate.present ? startDate.value : this.startDate,
		endDate: endDate.present ? endDate.value : this.endDate,
	);
	EventData copyWithCompanion(EventCompanion data) {
		return EventData(
			eventId: data.eventId.present ? data.eventId.value : this.eventId,
			name: data.name.present ? data.name.value : this.name,
			location: data.location.present ? data.location.value : this.location,
			startDate: data.startDate.present ? data.startDate.value : this.startDate,
			endDate: data.endDate.present ? data.endDate.value : this.endDate,
		);
	}

	@override
	String toString() {
		return (StringBuffer('EventData(')
					..write('eventId: $eventId, ')
					..write('name: $name, ')
					..write('location: $location, ')
					..write('startDate: $startDate, ')
					..write('endDate: $endDate')
					..write(')'))
				.toString();
	}

	@override
	int get hashCode => Object.hash(eventId, name, location, startDate, endDate);
	@override
	bool operator ==(Object other) =>
			identical(this, other) ||
			(other is EventData &&
					other.eventId == this.eventId &&
					other.name == this.name &&
					other.location == this.location &&
					other.startDate == this.startDate &&
					other.endDate == this.endDate);
}

class EventCompanion extends UpdateCompanion<EventData> {
	final Value<String> eventId;
	final Value<String> name;
	final Value<String?> location;
	final Value<DateTime?> startDate;
	final Value<DateTime?> endDate;
	final Value<int> rowid;
	const EventCompanion({
		this.eventId = const Value.absent(),
		this.name = const Value.absent(),
		this.location = const Value.absent(),
		this.startDate = const Value.absent(),
		this.endDate = const Value.absent(),
		this.rowid = const Value.absent(),
	});
	EventCompanion.insert({
		required String eventId,
		required String name,
		this.location = const Value.absent(),
		this.startDate = const Value.absent(),
		this.endDate = const Value.absent(),
		this.rowid = const Value.absent(),
	}) : eventId = Value(eventId),
		name = Value(name);
	static Insertable<EventData> custom({
		Expression<String>? eventId,
		Expression<String>? name,
		Expression<String>? location,
		Expression<DateTime>? startDate,
		Expression<DateTime>? endDate,
		Expression<int>? rowid,
	}) {
		return RawValuesInsertable({
			if (eventId != null) 'event_id': eventId,
			if (name != null) 'name': name,
			if (location != null) 'location': location,
			if (startDate != null) 'start_date': startDate,
			if (endDate != null) 'end_date': endDate,
			if (rowid != null) 'rowid': rowid,
		});
	}

	EventCompanion copyWith({
		Value<String>? eventId,
		Value<String>? name,
		Value<String?>? location,
		Value<DateTime?>? startDate,
		Value<DateTime?>? endDate,
		Value<int>? rowid,
	}) {
		return EventCompanion(
			eventId: eventId ?? this.eventId,
			name: name ?? this.name,
			location: location ?? this.location,
			startDate: startDate ?? this.startDate,
			endDate: endDate ?? this.endDate,
			rowid: rowid ?? this.rowid,
		);
	}

	@override
	Map<String, Expression> toColumns(bool nullToAbsent) {
		final map = <String, Expression>{};
		if (eventId.present) {
			map['event_id'] = Variable<String>(eventId.value);
		}
		if (name.present) {
			map['name'] = Variable<String>(name.value);
		}
		if (location.present) {
			map['location'] = Variable<String>(location.value);
		}
		if (startDate.present) {
			map['start_date'] = Variable<DateTime>(startDate.value);
		}
		if (endDate.present) {
			map['end_date'] = Variable<DateTime>(endDate.value);
		}
		if (rowid.present) {
			map['rowid'] = Variable<int>(rowid.value);
		}
		return map;
	}

	@override
	String toString() {
		return (StringBuffer('EventCompanion(')
					..write('eventId: $eventId, ')
					..write('name: $name, ')
					..write('location: $location, ')
					..write('startDate: $startDate, ')
					..write('endDate: $endDate, ')
					..write('rowid: $rowid')
					..write(')'))
				.toString();
	}
}

class $ScoutTable extends Scout with TableInfo<$ScoutTable, ScoutData> {
	@override
	final GeneratedDatabase attachedDatabase;
	final String? _alias;
	$ScoutTable(this.attachedDatabase, [this._alias]);
	static const VerificationMeta _eventMeta = const VerificationMeta('event');
	@override
	late final GeneratedColumn<String> event = GeneratedColumn<String>(
		'event',
		aliasedName,
		false,
		type: DriftSqlType.string,
		requiredDuringInsert: true,
	);
	static const VerificationMeta _matchMeta = const VerificationMeta('match');
	@override
	late final GeneratedColumn<String> match = GeneratedColumn<String>(
		'match',
		aliasedName,
		false,
		type: DriftSqlType.string,
		requiredDuringInsert: true,
	);
	static const VerificationMeta _teamMeta = const VerificationMeta('team');
	@override
	late final GeneratedColumn<String> team = GeneratedColumn<String>(
		'team',
		aliasedName,
		false,
		type: DriftSqlType.string,
		requiredDuringInsert: true,
	);
	static const VerificationMeta _startingPositionMeta = const VerificationMeta(
		'startingPosition',
	);
	@override
	late final GeneratedColumn<String> startingPosition = GeneratedColumn<String>(
		'starting_position',
		aliasedName,
		true,
		type: DriftSqlType.string,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _noShowMeta = const VerificationMeta('noShow');
	@override
	late final GeneratedColumn<bool> noShow = GeneratedColumn<bool>(
		'no_show',
		aliasedName,
		false,
		type: DriftSqlType.bool,
		requiredDuringInsert: false,
		defaultConstraints: GeneratedColumn.constraintIsAlways(
			'CHECK ("no_show" IN (0, 1))',
		),
		defaultValue: const Constant(false),
	);
	static const VerificationMeta _autoFuelAllianceMeta = const VerificationMeta(
		'autoFuelAlliance',
	);
	@override
	late final GeneratedColumn<int> autoFuelAlliance = GeneratedColumn<int>(
		'auto_fuel_alliance',
		aliasedName,
		true,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _autoFuelNeutralMeta = const VerificationMeta(
		'autoFuelNeutral',
	);
	@override
	late final GeneratedColumn<int> autoFuelNeutral = GeneratedColumn<int>(
		'auto_fuel_neutral',
		aliasedName,
		true,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _autoFuelOpponentMeta = const VerificationMeta(
		'autoFuelOpponent',
	);
	@override
	late final GeneratedColumn<int> autoFuelOpponent = GeneratedColumn<int>(
		'auto_fuel_opponent',
		aliasedName,
		true,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _autoFuelDepotMeta = const VerificationMeta(
		'autoFuelDepot',
	);
	@override
	late final GeneratedColumn<int> autoFuelDepot = GeneratedColumn<int>(
		'auto_fuel_depot',
		aliasedName,
		true,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _autoFuelOutpostMeta = const VerificationMeta(
		'autoFuelOutpost',
	);
	@override
	late final GeneratedColumn<int> autoFuelOutpost = GeneratedColumn<int>(
		'auto_fuel_outpost',
		aliasedName,
		true,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _autoClimbLevelMeta = const VerificationMeta(
		'autoClimbLevel',
	);
	@override
	late final GeneratedColumn<int> autoClimbLevel = GeneratedColumn<int>(
		'auto_climb_level',
		aliasedName,
		true,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _autoTrenchDepotAllianceToNeutralMeta =
			const VerificationMeta('autoTrenchDepotAllianceToNeutral');
	@override
	late final GeneratedColumn<int> autoTrenchDepotAllianceToNeutral =
			GeneratedColumn<int>(
				'auto_trench_depot_alliance_to_neutral',
				aliasedName,
				false,
				type: DriftSqlType.int,
				requiredDuringInsert: false,
				defaultValue: const Constant(0),
			);
	static const VerificationMeta _autoBumpDepotAllianceToNeutralMeta =
			const VerificationMeta('autoBumpDepotAllianceToNeutral');
	@override
	late final GeneratedColumn<int> autoBumpDepotAllianceToNeutral =
			GeneratedColumn<int>(
				'auto_bump_depot_alliance_to_neutral',
				aliasedName,
				false,
				type: DriftSqlType.int,
				requiredDuringInsert: false,
				defaultValue: const Constant(0),
			);
	static const VerificationMeta _autoBumpOutpostAllianceToNeutralMeta =
			const VerificationMeta('autoBumpOutpostAllianceToNeutral');
	@override
	late final GeneratedColumn<int> autoBumpOutpostAllianceToNeutral =
			GeneratedColumn<int>(
				'auto_bump_outpost_alliance_to_neutral',
				aliasedName,
				false,
				type: DriftSqlType.int,
				requiredDuringInsert: false,
				defaultValue: const Constant(0),
			);
	static const VerificationMeta _autoTrenchOutpostAllianceToNeutralMeta =
			const VerificationMeta('autoTrenchOutpostAllianceToNeutral');
	@override
	late final GeneratedColumn<int> autoTrenchOutpostAllianceToNeutral =
			GeneratedColumn<int>(
				'auto_trench_outpost_alliance_to_neutral',
				aliasedName,
				false,
				type: DriftSqlType.int,
				requiredDuringInsert: false,
				defaultValue: const Constant(0),
			);
	static const VerificationMeta _autoTrenchDepotNeutralToAllianceMeta =
			const VerificationMeta('autoTrenchDepotNeutralToAlliance');
	@override
	late final GeneratedColumn<int> autoTrenchDepotNeutralToAlliance =
			GeneratedColumn<int>(
				'auto_trench_depot_neutral_to_alliance',
				aliasedName,
				false,
				type: DriftSqlType.int,
				requiredDuringInsert: false,
				defaultValue: const Constant(0),
			);
	static const VerificationMeta _autoBumpDepotNeutralToAllianceMeta =
			const VerificationMeta('autoBumpDepotNeutralToAlliance');
	@override
	late final GeneratedColumn<int> autoBumpDepotNeutralToAlliance =
			GeneratedColumn<int>(
				'auto_bump_depot_neutral_to_alliance',
				aliasedName,
				false,
				type: DriftSqlType.int,
				requiredDuringInsert: false,
				defaultValue: const Constant(0),
			);
	static const VerificationMeta _autoBumpOutpostNeutralToAllianceMeta =
			const VerificationMeta('autoBumpOutpostNeutralToAlliance');
	@override
	late final GeneratedColumn<int> autoBumpOutpostNeutralToAlliance =
			GeneratedColumn<int>(
				'auto_bump_outpost_neutral_to_alliance',
				aliasedName,
				false,
				type: DriftSqlType.int,
				requiredDuringInsert: false,
				defaultValue: const Constant(0),
			);
	static const VerificationMeta _autoTrenchOutpostNeutralToAllianceMeta =
			const VerificationMeta('autoTrenchOutpostNeutralToAlliance');
	@override
	late final GeneratedColumn<int> autoTrenchOutpostNeutralToAlliance =
			GeneratedColumn<int>(
				'auto_trench_outpost_neutral_to_alliance',
				aliasedName,
				false,
				type: DriftSqlType.int,
				requiredDuringInsert: false,
				defaultValue: const Constant(0),
			);
	static const VerificationMeta _autoFuelScoreMeta = const VerificationMeta(
		'autoFuelScore',
	);
	@override
	late final GeneratedColumn<int> autoFuelScore = GeneratedColumn<int>(
		'auto_fuel_score',
		aliasedName,
		false,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
		defaultValue: const Constant(0),
	);
	static const VerificationMeta _autoFuelNeutralAlliancePassMeta =
			const VerificationMeta('autoFuelNeutralAlliancePass');
	@override
	late final GeneratedColumn<int> autoFuelNeutralAlliancePass =
			GeneratedColumn<int>(
				'auto_fuel_neutral_alliance_pass',
				aliasedName,
				false,
				type: DriftSqlType.int,
				requiredDuringInsert: false,
				defaultValue: const Constant(0),
			);
	static const VerificationMeta _autoCollectOutpostMeta =
			const VerificationMeta('autoCollectOutpost');
	@override
	late final GeneratedColumn<bool> autoCollectOutpost = GeneratedColumn<bool>(
		'auto_collect_outpost',
		aliasedName,
		false,
		type: DriftSqlType.bool,
		requiredDuringInsert: false,
		defaultConstraints: GeneratedColumn.constraintIsAlways(
			'CHECK ("auto_collect_outpost" IN (0, 1))',
		),
		defaultValue: const Constant(false),
	);
	static const VerificationMeta _autoCollectDepotMeta = const VerificationMeta(
		'autoCollectDepot',
	);
	@override
	late final GeneratedColumn<bool> autoCollectDepot = GeneratedColumn<bool>(
		'auto_collect_depot',
		aliasedName,
		false,
		type: DriftSqlType.bool,
		requiredDuringInsert: false,
		defaultConstraints: GeneratedColumn.constraintIsAlways(
			'CHECK ("auto_collect_depot" IN (0, 1))',
		),
		defaultValue: const Constant(false),
	);
	static const VerificationMeta _autoAllianceTimeMeta = const VerificationMeta(
		'autoAllianceTime',
	);
	@override
	late final GeneratedColumn<int> autoAllianceTime = GeneratedColumn<int>(
		'auto_alliance_time',
		aliasedName,
		false,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
		defaultValue: const Constant(0),
	);
	static const VerificationMeta _autoNeutralTimeMeta = const VerificationMeta(
		'autoNeutralTime',
	);
	@override
	late final GeneratedColumn<int> autoNeutralTime = GeneratedColumn<int>(
		'auto_neutral_time',
		aliasedName,
		false,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
		defaultValue: const Constant(0),
	);
	static const VerificationMeta _autoTimelineEventsMeta =
			const VerificationMeta('autoTimelineEvents');
	@override
	late final GeneratedColumn<String> autoTimelineEvents =
			GeneratedColumn<String>(
				'auto_timeline_events',
				aliasedName,
				true,
				type: DriftSqlType.string,
				requiredDuringInsert: false,
			);
	static const VerificationMeta _teleopFuelAllianceMeta =
			const VerificationMeta('teleopFuelAlliance');
	@override
	late final GeneratedColumn<int> teleopFuelAlliance = GeneratedColumn<int>(
		'teleop_fuel_alliance',
		aliasedName,
		true,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _teleopFuelNeutralMeta = const VerificationMeta(
		'teleopFuelNeutral',
	);
	@override
	late final GeneratedColumn<int> teleopFuelNeutral = GeneratedColumn<int>(
		'teleop_fuel_neutral',
		aliasedName,
		true,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _teleopFuelOpponentMeta =
			const VerificationMeta('teleopFuelOpponent');
	@override
	late final GeneratedColumn<int> teleopFuelOpponent = GeneratedColumn<int>(
		'teleop_fuel_opponent',
		aliasedName,
		true,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _teleopClimbLevelMeta = const VerificationMeta(
		'teleopClimbLevel',
	);
	@override
	late final GeneratedColumn<int> teleopClimbLevel = GeneratedColumn<int>(
		'teleop_climb_level',
		aliasedName,
		true,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _teleopAlliancePassesMeta =
			const VerificationMeta('teleopAlliancePasses');
	@override
	late final GeneratedColumn<int> teleopAlliancePasses = GeneratedColumn<int>(
		'teleop_alliance_passes',
		aliasedName,
		true,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _teleopOpponentPassesMeta =
			const VerificationMeta('teleopOpponentPasses');
	@override
	late final GeneratedColumn<int> teleopOpponentPasses = GeneratedColumn<int>(
		'teleop_opponent_passes',
		aliasedName,
		true,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _teleopZoneInteractionsMeta =
			const VerificationMeta('teleopZoneInteractions');
	@override
	late final GeneratedColumn<String> teleopZoneInteractions =
			GeneratedColumn<String>(
				'teleop_zone_interactions',
				aliasedName,
				true,
				type: DriftSqlType.string,
				requiredDuringInsert: false,
			);
	static const VerificationMeta _climbPositionMeta = const VerificationMeta(
		'climbPosition',
	);
	@override
	late final GeneratedColumn<String> climbPosition = GeneratedColumn<String>(
		'climb_position',
		aliasedName,
		true,
		type: DriftSqlType.string,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _climbMethodMeta = const VerificationMeta(
		'climbMethod',
	);
	@override
	late final GeneratedColumn<String> climbMethod = GeneratedColumn<String>(
		'climb_method',
		aliasedName,
		true,
		type: DriftSqlType.string,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _shootOnMoveMeta = const VerificationMeta(
		'shootOnMove',
	);
	@override
	late final GeneratedColumn<bool> shootOnMove = GeneratedColumn<bool>(
		'shoot_on_move',
		aliasedName,
		false,
		type: DriftSqlType.bool,
		requiredDuringInsert: false,
		defaultConstraints: GeneratedColumn.constraintIsAlways(
			'CHECK ("shoot_on_move" IN (0, 1))',
		),
		defaultValue: const Constant(false),
	);
	static const VerificationMeta _shootWhileCollectingMeta =
			const VerificationMeta('shootWhileCollecting');
	@override
	late final GeneratedColumn<bool> shootWhileCollecting = GeneratedColumn<bool>(
		'shoot_while_collecting',
		aliasedName,
		false,
		type: DriftSqlType.bool,
		requiredDuringInsert: false,
		defaultConstraints: GeneratedColumn.constraintIsAlways(
			'CHECK ("shoot_while_collecting" IN (0, 1))',
		),
		defaultValue: const Constant(false),
	);
	static const VerificationMeta _climbingMeta = const VerificationMeta(
		'climbing',
	);
	@override
	late final GeneratedColumn<bool> climbing = GeneratedColumn<bool>(
		'climbing',
		aliasedName,
		false,
		type: DriftSqlType.bool,
		requiredDuringInsert: false,
		defaultConstraints: GeneratedColumn.constraintIsAlways(
			'CHECK ("climbing" IN (0, 1))',
		),
		defaultValue: const Constant(false),
	);
	static const VerificationMeta _fuelStrategyMeta = const VerificationMeta(
		'fuelStrategy',
	);
	@override
	late final GeneratedColumn<String> fuelStrategy = GeneratedColumn<String>(
		'fuel_strategy',
		aliasedName,
		true,
		type: DriftSqlType.string,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _shootingLocationsMeta = const VerificationMeta(
		'shootingLocations',
	);
	@override
	late final GeneratedColumn<String> shootingLocations =
			GeneratedColumn<String>(
				'shooting_locations',
				aliasedName,
				true,
				type: DriftSqlType.string,
				requiredDuringInsert: false,
			);
	static const VerificationMeta _damageStateMeta = const VerificationMeta(
		'damageState',
	);
	@override
	late final GeneratedColumn<int> damageState = GeneratedColumn<int>(
		'damage_state',
		aliasedName,
		true,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _defenseRatingMeta = const VerificationMeta(
		'defenseRating',
	);
	@override
	late final GeneratedColumn<String> defenseRating = GeneratedColumn<String>(
		'defense_rating',
		aliasedName,
		true,
		type: DriftSqlType.string,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _defenseMethodsMeta = const VerificationMeta(
		'defenseMethods',
	);
	@override
	late final GeneratedColumn<String> defenseMethods = GeneratedColumn<String>(
		'defense_methods',
		aliasedName,
		true,
		type: DriftSqlType.string,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _defenseImpactMeta = const VerificationMeta(
		'defenseImpact',
	);
	@override
	late final GeneratedColumn<String> defenseImpact = GeneratedColumn<String>(
		'defense_impact',
		aliasedName,
		true,
		type: DriftSqlType.string,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _shootingMissesRangeMeta =
			const VerificationMeta('shootingMissesRange');
	@override
	late final GeneratedColumn<int> shootingMissesRange = GeneratedColumn<int>(
		'shooting_misses_range',
		aliasedName,
		true,
		type: DriftSqlType.int,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _scouterNameMeta = const VerificationMeta(
		'scouterName',
	);
	@override
	late final GeneratedColumn<String> scouterName = GeneratedColumn<String>(
		'scouter_name',
		aliasedName,
		true,
		type: DriftSqlType.string,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _commentsMeta = const VerificationMeta(
		'comments',
	);
	@override
	late final GeneratedColumn<String> comments = GeneratedColumn<String>(
		'comments',
		aliasedName,
		true,
		type: DriftSqlType.string,
		requiredDuringInsert: false,
	);
	static const VerificationMeta _reviewRequestMeta = const VerificationMeta(
		'reviewRequest',
	);
	@override
	late final GeneratedColumn<bool> reviewRequest = GeneratedColumn<bool>(
		'review_request',
		aliasedName,
		false,
		type: DriftSqlType.bool,
		requiredDuringInsert: false,
		defaultConstraints: GeneratedColumn.constraintIsAlways(
			'CHECK ("review_request" IN (0, 1))',
		),
		defaultValue: const Constant(false),
	);
	static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
	@override
	late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
		'synced',
		aliasedName,
		false,
		type: DriftSqlType.bool,
		requiredDuringInsert: false,
		defaultConstraints: GeneratedColumn.constraintIsAlways(
			'CHECK ("synced" IN (0, 1))',
		),
		defaultValue: const Constant(false),
	);
	static const VerificationMeta _createdAtMeta = const VerificationMeta(
		'createdAt',
	);
	@override
	late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
		'created_at',
		aliasedName,
		false,
		type: DriftSqlType.dateTime,
		requiredDuringInsert: false,
		clientDefault: () => DateTime.now(),
	);
	static const VerificationMeta _updatedAtMeta = const VerificationMeta(
		'updatedAt',
	);
	@override
	late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
		'updated_at',
		aliasedName,
		false,
		type: DriftSqlType.dateTime,
		requiredDuringInsert: false,
		clientDefault: () => DateTime.now(),
	);
	static const VerificationMeta _syncedAtMeta = const VerificationMeta(
		'syncedAt',
	);
	@override
	late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
		'synced_at',
		aliasedName,
		true,
		type: DriftSqlType.dateTime,
		requiredDuringInsert: false,
	);
	@override
	List<GeneratedColumn> get $columns => [
		event,
		match,
		team,
		startingPosition,
		noShow,
		autoFuelAlliance,
		autoFuelNeutral,
		autoFuelOpponent,
		autoFuelDepot,
		autoFuelOutpost,
		autoClimbLevel,
		autoTrenchDepotAllianceToNeutral,
		autoBumpDepotAllianceToNeutral,
		autoBumpOutpostAllianceToNeutral,
		autoTrenchOutpostAllianceToNeutral,
		autoTrenchDepotNeutralToAlliance,
		autoBumpDepotNeutralToAlliance,
		autoBumpOutpostNeutralToAlliance,
		autoTrenchOutpostNeutralToAlliance,
		autoFuelScore,
		autoFuelNeutralAlliancePass,
		autoCollectOutpost,
		autoCollectDepot,
		autoAllianceTime,
		autoNeutralTime,
		autoTimelineEvents,
		teleopFuelAlliance,
		teleopFuelNeutral,
		teleopFuelOpponent,
		teleopClimbLevel,
		teleopAlliancePasses,
		teleopOpponentPasses,
		teleopZoneInteractions,
		climbPosition,
		climbMethod,
		shootOnMove,
		shootWhileCollecting,
		climbing,
		fuelStrategy,
		shootingLocations,
		damageState,
		defenseRating,
		defenseMethods,
		defenseImpact,
		shootingMissesRange,
		scouterName,
		comments,
		reviewRequest,
		synced,
		createdAt,
		updatedAt,
		syncedAt,
	];
	@override
	String get aliasedName => _alias ?? actualTableName;
	@override
	String get actualTableName => $name;
	static const String $name = 'scout';
	@override
	VerificationContext validateIntegrity(
		Insertable<ScoutData> instance, {
		bool isInserting = false,
	}) {
		final context = VerificationContext();
		final data = instance.toColumns(true);
		if (data.containsKey('event')) {
			context.handle(
				_eventMeta,
				event.isAcceptableOrUnknown(data['event']!, _eventMeta),
			);
		} else if (isInserting) {
			context.missing(_eventMeta);
		}
		if (data.containsKey('match')) {
			context.handle(
				_matchMeta,
				match.isAcceptableOrUnknown(data['match']!, _matchMeta),
			);
		} else if (isInserting) {
			context.missing(_matchMeta);
		}
		if (data.containsKey('team')) {
			context.handle(
				_teamMeta,
				team.isAcceptableOrUnknown(data['team']!, _teamMeta),
			);
		} else if (isInserting) {
			context.missing(_teamMeta);
		}
		if (data.containsKey('starting_position')) {
			context.handle(
				_startingPositionMeta,
				startingPosition.isAcceptableOrUnknown(
					data['starting_position']!,
					_startingPositionMeta,
				),
			);
		}
		if (data.containsKey('no_show')) {
			context.handle(
				_noShowMeta,
				noShow.isAcceptableOrUnknown(data['no_show']!, _noShowMeta),
			);
		}
		if (data.containsKey('auto_fuel_alliance')) {
			context.handle(
				_autoFuelAllianceMeta,
				autoFuelAlliance.isAcceptableOrUnknown(
					data['auto_fuel_alliance']!,
					_autoFuelAllianceMeta,
				),
			);
		}
		if (data.containsKey('auto_fuel_neutral')) {
			context.handle(
				_autoFuelNeutralMeta,
				autoFuelNeutral.isAcceptableOrUnknown(
					data['auto_fuel_neutral']!,
					_autoFuelNeutralMeta,
				),
			);
		}
		if (data.containsKey('auto_fuel_opponent')) {
			context.handle(
				_autoFuelOpponentMeta,
				autoFuelOpponent.isAcceptableOrUnknown(
					data['auto_fuel_opponent']!,
					_autoFuelOpponentMeta,
				),
			);
		}
		if (data.containsKey('auto_fuel_depot')) {
			context.handle(
				_autoFuelDepotMeta,
				autoFuelDepot.isAcceptableOrUnknown(
					data['auto_fuel_depot']!,
					_autoFuelDepotMeta,
				),
			);
		}
		if (data.containsKey('auto_fuel_outpost')) {
			context.handle(
				_autoFuelOutpostMeta,
				autoFuelOutpost.isAcceptableOrUnknown(
					data['auto_fuel_outpost']!,
					_autoFuelOutpostMeta,
				),
			);
		}
		if (data.containsKey('auto_climb_level')) {
			context.handle(
				_autoClimbLevelMeta,
				autoClimbLevel.isAcceptableOrUnknown(
					data['auto_climb_level']!,
					_autoClimbLevelMeta,
				),
			);
		}
		if (data.containsKey('auto_trench_depot_alliance_to_neutral')) {
			context.handle(
				_autoTrenchDepotAllianceToNeutralMeta,
				autoTrenchDepotAllianceToNeutral.isAcceptableOrUnknown(
					data['auto_trench_depot_alliance_to_neutral']!,
					_autoTrenchDepotAllianceToNeutralMeta,
				),
			);
		}
		if (data.containsKey('auto_bump_depot_alliance_to_neutral')) {
			context.handle(
				_autoBumpDepotAllianceToNeutralMeta,
				autoBumpDepotAllianceToNeutral.isAcceptableOrUnknown(
					data['auto_bump_depot_alliance_to_neutral']!,
					_autoBumpDepotAllianceToNeutralMeta,
				),
			);
		}
		if (data.containsKey('auto_bump_outpost_alliance_to_neutral')) {
			context.handle(
				_autoBumpOutpostAllianceToNeutralMeta,
				autoBumpOutpostAllianceToNeutral.isAcceptableOrUnknown(
					data['auto_bump_outpost_alliance_to_neutral']!,
					_autoBumpOutpostAllianceToNeutralMeta,
				),
			);
		}
		if (data.containsKey('auto_trench_outpost_alliance_to_neutral')) {
			context.handle(
				_autoTrenchOutpostAllianceToNeutralMeta,
				autoTrenchOutpostAllianceToNeutral.isAcceptableOrUnknown(
					data['auto_trench_outpost_alliance_to_neutral']!,
					_autoTrenchOutpostAllianceToNeutralMeta,
				),
			);
		}
		if (data.containsKey('auto_trench_depot_neutral_to_alliance')) {
			context.handle(
				_autoTrenchDepotNeutralToAllianceMeta,
				autoTrenchDepotNeutralToAlliance.isAcceptableOrUnknown(
					data['auto_trench_depot_neutral_to_alliance']!,
					_autoTrenchDepotNeutralToAllianceMeta,
				),
			);
		}
		if (data.containsKey('auto_bump_depot_neutral_to_alliance')) {
			context.handle(
				_autoBumpDepotNeutralToAllianceMeta,
				autoBumpDepotNeutralToAlliance.isAcceptableOrUnknown(
					data['auto_bump_depot_neutral_to_alliance']!,
					_autoBumpDepotNeutralToAllianceMeta,
				),
			);
		}
		if (data.containsKey('auto_bump_outpost_neutral_to_alliance')) {
			context.handle(
				_autoBumpOutpostNeutralToAllianceMeta,
				autoBumpOutpostNeutralToAlliance.isAcceptableOrUnknown(
					data['auto_bump_outpost_neutral_to_alliance']!,
					_autoBumpOutpostNeutralToAllianceMeta,
				),
			);
		}
		if (data.containsKey('auto_trench_outpost_neutral_to_alliance')) {
			context.handle(
				_autoTrenchOutpostNeutralToAllianceMeta,
				autoTrenchOutpostNeutralToAlliance.isAcceptableOrUnknown(
					data['auto_trench_outpost_neutral_to_alliance']!,
					_autoTrenchOutpostNeutralToAllianceMeta,
				),
			);
		}
		if (data.containsKey('auto_fuel_score')) {
			context.handle(
				_autoFuelScoreMeta,
				autoFuelScore.isAcceptableOrUnknown(
					data['auto_fuel_score']!,
					_autoFuelScoreMeta,
				),
			);
		}
		if (data.containsKey('auto_fuel_neutral_alliance_pass')) {
			context.handle(
				_autoFuelNeutralAlliancePassMeta,
				autoFuelNeutralAlliancePass.isAcceptableOrUnknown(
					data['auto_fuel_neutral_alliance_pass']!,
					_autoFuelNeutralAlliancePassMeta,
				),
			);
		}
		if (data.containsKey('auto_collect_outpost')) {
			context.handle(
				_autoCollectOutpostMeta,
				autoCollectOutpost.isAcceptableOrUnknown(
					data['auto_collect_outpost']!,
					_autoCollectOutpostMeta,
				),
			);
		}
		if (data.containsKey('auto_collect_depot')) {
			context.handle(
				_autoCollectDepotMeta,
				autoCollectDepot.isAcceptableOrUnknown(
					data['auto_collect_depot']!,
					_autoCollectDepotMeta,
				),
			);
		}
		if (data.containsKey('auto_alliance_time')) {
			context.handle(
				_autoAllianceTimeMeta,
				autoAllianceTime.isAcceptableOrUnknown(
					data['auto_alliance_time']!,
					_autoAllianceTimeMeta,
				),
			);
		}
		if (data.containsKey('auto_neutral_time')) {
			context.handle(
				_autoNeutralTimeMeta,
				autoNeutralTime.isAcceptableOrUnknown(
					data['auto_neutral_time']!,
					_autoNeutralTimeMeta,
				),
			);
		}
		if (data.containsKey('auto_timeline_events')) {
			context.handle(
				_autoTimelineEventsMeta,
				autoTimelineEvents.isAcceptableOrUnknown(
					data['auto_timeline_events']!,
					_autoTimelineEventsMeta,
				),
			);
		}
		if (data.containsKey('teleop_fuel_alliance')) {
			context.handle(
				_teleopFuelAllianceMeta,
				teleopFuelAlliance.isAcceptableOrUnknown(
					data['teleop_fuel_alliance']!,
					_teleopFuelAllianceMeta,
				),
			);
		}
		if (data.containsKey('teleop_fuel_neutral')) {
			context.handle(
				_teleopFuelNeutralMeta,
				teleopFuelNeutral.isAcceptableOrUnknown(
					data['teleop_fuel_neutral']!,
					_teleopFuelNeutralMeta,
				),
			);
		}
		if (data.containsKey('teleop_fuel_opponent')) {
			context.handle(
				_teleopFuelOpponentMeta,
				teleopFuelOpponent.isAcceptableOrUnknown(
					data['teleop_fuel_opponent']!,
					_teleopFuelOpponentMeta,
				),
			);
		}
		if (data.containsKey('teleop_climb_level')) {
			context.handle(
				_teleopClimbLevelMeta,
				teleopClimbLevel.isAcceptableOrUnknown(
					data['teleop_climb_level']!,
					_teleopClimbLevelMeta,
				),
			);
		}
		if (data.containsKey('teleop_alliance_passes')) {
			context.handle(
				_teleopAlliancePassesMeta,
				teleopAlliancePasses.isAcceptableOrUnknown(
					data['teleop_alliance_passes']!,
					_teleopAlliancePassesMeta,
				),
			);
		}
		if (data.containsKey('teleop_opponent_passes')) {
			context.handle(
				_teleopOpponentPassesMeta,
				teleopOpponentPasses.isAcceptableOrUnknown(
					data['teleop_opponent_passes']!,
					_teleopOpponentPassesMeta,
				),
			);
		}
		if (data.containsKey('teleop_zone_interactions')) {
			context.handle(
				_teleopZoneInteractionsMeta,
				teleopZoneInteractions.isAcceptableOrUnknown(
					data['teleop_zone_interactions']!,
					_teleopZoneInteractionsMeta,
				),
			);
		}
		if (data.containsKey('climb_position')) {
			context.handle(
				_climbPositionMeta,
				climbPosition.isAcceptableOrUnknown(
					data['climb_position']!,
					_climbPositionMeta,
				),
			);
		}
		if (data.containsKey('climb_method')) {
			context.handle(
				_climbMethodMeta,
				climbMethod.isAcceptableOrUnknown(
					data['climb_method']!,
					_climbMethodMeta,
				),
			);
		}
		if (data.containsKey('shoot_on_move')) {
			context.handle(
				_shootOnMoveMeta,
				shootOnMove.isAcceptableOrUnknown(
					data['shoot_on_move']!,
					_shootOnMoveMeta,
				),
			);
		}
		if (data.containsKey('shoot_while_collecting')) {
			context.handle(
				_shootWhileCollectingMeta,
				shootWhileCollecting.isAcceptableOrUnknown(
					data['shoot_while_collecting']!,
					_shootWhileCollectingMeta,
				),
			);
		}
		if (data.containsKey('climbing')) {
			context.handle(
				_climbingMeta,
				climbing.isAcceptableOrUnknown(data['climbing']!, _climbingMeta),
			);
		}
		if (data.containsKey('fuel_strategy')) {
			context.handle(
				_fuelStrategyMeta,
				fuelStrategy.isAcceptableOrUnknown(
					data['fuel_strategy']!,
					_fuelStrategyMeta,
				),
			);
		}
		if (data.containsKey('shooting_locations')) {
			context.handle(
				_shootingLocationsMeta,
				shootingLocations.isAcceptableOrUnknown(
					data['shooting_locations']!,
					_shootingLocationsMeta,
				),
			);
		}
		if (data.containsKey('damage_state')) {
			context.handle(
				_damageStateMeta,
				damageState.isAcceptableOrUnknown(
					data['damage_state']!,
					_damageStateMeta,
				),
			);
		}
		if (data.containsKey('defense_rating')) {
			context.handle(
				_defenseRatingMeta,
				defenseRating.isAcceptableOrUnknown(
					data['defense_rating']!,
					_defenseRatingMeta,
				),
			);
		}
		if (data.containsKey('defense_methods')) {
			context.handle(
				_defenseMethodsMeta,
				defenseMethods.isAcceptableOrUnknown(
					data['defense_methods']!,
					_defenseMethodsMeta,
				),
			);
		}
		if (data.containsKey('defense_impact')) {
			context.handle(
				_defenseImpactMeta,
				defenseImpact.isAcceptableOrUnknown(
					data['defense_impact']!,
					_defenseImpactMeta,
				),
			);
		}
		if (data.containsKey('shooting_misses_range')) {
			context.handle(
				_shootingMissesRangeMeta,
				shootingMissesRange.isAcceptableOrUnknown(
					data['shooting_misses_range']!,
					_shootingMissesRangeMeta,
				),
			);
		}
		if (data.containsKey('scouter_name')) {
			context.handle(
				_scouterNameMeta,
				scouterName.isAcceptableOrUnknown(
					data['scouter_name']!,
					_scouterNameMeta,
				),
			);
		}
		if (data.containsKey('comments')) {
			context.handle(
				_commentsMeta,
				comments.isAcceptableOrUnknown(data['comments']!, _commentsMeta),
			);
		}
		if (data.containsKey('review_request')) {
			context.handle(
				_reviewRequestMeta,
				reviewRequest.isAcceptableOrUnknown(
					data['review_request']!,
					_reviewRequestMeta,
				),
			);
		}
		if (data.containsKey('synced')) {
			context.handle(
				_syncedMeta,
				synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
			);
		}
		if (data.containsKey('created_at')) {
			context.handle(
				_createdAtMeta,
				createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
			);
		}
		if (data.containsKey('updated_at')) {
			context.handle(
				_updatedAtMeta,
				updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
			);
		}
		if (data.containsKey('synced_at')) {
			context.handle(
				_syncedAtMeta,
				syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
			);
		}
		return context;
	}

	@override
	Set<GeneratedColumn> get $primaryKey => {event, match, team};
	@override
	ScoutData map(Map<String, dynamic> data, {String? tablePrefix}) {
		final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
		return ScoutData(
			event: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}event'],
			)!,
			match: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}match'],
			)!,
			team: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}team'],
			)!,
			startingPosition: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}starting_position'],
			),
			noShow: attachedDatabase.typeMapping.read(
				DriftSqlType.bool,
				data['${effectivePrefix}no_show'],
			)!,
			autoFuelAlliance: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_fuel_alliance'],
			),
			autoFuelNeutral: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_fuel_neutral'],
			),
			autoFuelOpponent: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_fuel_opponent'],
			),
			autoFuelDepot: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_fuel_depot'],
			),
			autoFuelOutpost: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_fuel_outpost'],
			),
			autoClimbLevel: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_climb_level'],
			),
			autoTrenchDepotAllianceToNeutral: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_trench_depot_alliance_to_neutral'],
			)!,
			autoBumpDepotAllianceToNeutral: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_bump_depot_alliance_to_neutral'],
			)!,
			autoBumpOutpostAllianceToNeutral: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_bump_outpost_alliance_to_neutral'],
			)!,
			autoTrenchOutpostAllianceToNeutral: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_trench_outpost_alliance_to_neutral'],
			)!,
			autoTrenchDepotNeutralToAlliance: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_trench_depot_neutral_to_alliance'],
			)!,
			autoBumpDepotNeutralToAlliance: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_bump_depot_neutral_to_alliance'],
			)!,
			autoBumpOutpostNeutralToAlliance: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_bump_outpost_neutral_to_alliance'],
			)!,
			autoTrenchOutpostNeutralToAlliance: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_trench_outpost_neutral_to_alliance'],
			)!,
			autoFuelScore: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_fuel_score'],
			)!,
			autoFuelNeutralAlliancePass: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_fuel_neutral_alliance_pass'],
			)!,
			autoCollectOutpost: attachedDatabase.typeMapping.read(
				DriftSqlType.bool,
				data['${effectivePrefix}auto_collect_outpost'],
			)!,
			autoCollectDepot: attachedDatabase.typeMapping.read(
				DriftSqlType.bool,
				data['${effectivePrefix}auto_collect_depot'],
			)!,
			autoAllianceTime: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_alliance_time'],
			)!,
			autoNeutralTime: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}auto_neutral_time'],
			)!,
			autoTimelineEvents: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}auto_timeline_events'],
			),
			teleopFuelAlliance: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}teleop_fuel_alliance'],
			),
			teleopFuelNeutral: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}teleop_fuel_neutral'],
			),
			teleopFuelOpponent: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}teleop_fuel_opponent'],
			),
			teleopClimbLevel: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}teleop_climb_level'],
			),
			teleopAlliancePasses: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}teleop_alliance_passes'],
			),
			teleopOpponentPasses: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}teleop_opponent_passes'],
			),
			teleopZoneInteractions: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}teleop_zone_interactions'],
			),
			climbPosition: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}climb_position'],
			),
			climbMethod: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}climb_method'],
			),
			shootOnMove: attachedDatabase.typeMapping.read(
				DriftSqlType.bool,
				data['${effectivePrefix}shoot_on_move'],
			)!,
			shootWhileCollecting: attachedDatabase.typeMapping.read(
				DriftSqlType.bool,
				data['${effectivePrefix}shoot_while_collecting'],
			)!,
			climbing: attachedDatabase.typeMapping.read(
				DriftSqlType.bool,
				data['${effectivePrefix}climbing'],
			)!,
			fuelStrategy: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}fuel_strategy'],
			),
			shootingLocations: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}shooting_locations'],
			),
			damageState: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}damage_state'],
			),
			defenseRating: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}defense_rating'],
			),
			defenseMethods: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}defense_methods'],
			),
			defenseImpact: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}defense_impact'],
			),
			shootingMissesRange: attachedDatabase.typeMapping.read(
				DriftSqlType.int,
				data['${effectivePrefix}shooting_misses_range'],
			),
			scouterName: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}scouter_name'],
			),
			comments: attachedDatabase.typeMapping.read(
				DriftSqlType.string,
				data['${effectivePrefix}comments'],
			),
			reviewRequest: attachedDatabase.typeMapping.read(
				DriftSqlType.bool,
				data['${effectivePrefix}review_request'],
			)!,
			synced: attachedDatabase.typeMapping.read(
				DriftSqlType.bool,
				data['${effectivePrefix}synced'],
			)!,
			createdAt: attachedDatabase.typeMapping.read(
				DriftSqlType.dateTime,
				data['${effectivePrefix}created_at'],
			)!,
			updatedAt: attachedDatabase.typeMapping.read(
				DriftSqlType.dateTime,
				data['${effectivePrefix}updated_at'],
			)!,
			syncedAt: attachedDatabase.typeMapping.read(
				DriftSqlType.dateTime,
				data['${effectivePrefix}synced_at'],
			),
		);
	}

	@override
	$ScoutTable createAlias(String alias) {
		return $ScoutTable(attachedDatabase, alias);
	}
}

class ScoutData extends DataClass implements Insertable<ScoutData> {
	final String event;
	final String match;
	final String team;
	final String? startingPosition;
	final bool noShow;
	final int? autoFuelAlliance;
	final int? autoFuelNeutral;
	final int? autoFuelOpponent;
	final int? autoFuelDepot;
	final int? autoFuelOutpost;
	final int? autoClimbLevel;
	final int autoTrenchDepotAllianceToNeutral;
	final int autoBumpDepotAllianceToNeutral;
	final int autoBumpOutpostAllianceToNeutral;
	final int autoTrenchOutpostAllianceToNeutral;
	final int autoTrenchDepotNeutralToAlliance;
	final int autoBumpDepotNeutralToAlliance;
	final int autoBumpOutpostNeutralToAlliance;
	final int autoTrenchOutpostNeutralToAlliance;
	final int autoFuelScore;
	final int autoFuelNeutralAlliancePass;
	final bool autoCollectOutpost;
	final bool autoCollectDepot;
	final int autoAllianceTime;
	final int autoNeutralTime;
	final String? autoTimelineEvents;
	final int? teleopFuelAlliance;
	final int? teleopFuelNeutral;
	final int? teleopFuelOpponent;
	final int? teleopClimbLevel;
	final int? teleopAlliancePasses;
	final int? teleopOpponentPasses;
	final String? teleopZoneInteractions;
	final String? climbPosition;
	final String? climbMethod;
	final bool shootOnMove;
	final bool shootWhileCollecting;
	final bool climbing;
	final String? fuelStrategy;
	final String? shootingLocations;
	final int? damageState;
	final String? defenseRating;
	final String? defenseMethods;
	final String? defenseImpact;
	final int? shootingMissesRange;
	final String? scouterName;
	final String? comments;
	final bool reviewRequest;
	final bool synced;
	final DateTime createdAt;
	final DateTime updatedAt;
	final DateTime? syncedAt;
	const ScoutData({
		required this.event,
		required this.match,
		required this.team,
		this.startingPosition,
		required this.noShow,
		this.autoFuelAlliance,
		this.autoFuelNeutral,
		this.autoFuelOpponent,
		this.autoFuelDepot,
		this.autoFuelOutpost,
		this.autoClimbLevel,
		required this.autoTrenchDepotAllianceToNeutral,
		required this.autoBumpDepotAllianceToNeutral,
		required this.autoBumpOutpostAllianceToNeutral,
		required this.autoTrenchOutpostAllianceToNeutral,
		required this.autoTrenchDepotNeutralToAlliance,
		required this.autoBumpDepotNeutralToAlliance,
		required this.autoBumpOutpostNeutralToAlliance,
		required this.autoTrenchOutpostNeutralToAlliance,
		required this.autoFuelScore,
		required this.autoFuelNeutralAlliancePass,
		required this.autoCollectOutpost,
		required this.autoCollectDepot,
		required this.autoAllianceTime,
		required this.autoNeutralTime,
		this.autoTimelineEvents,
		this.teleopFuelAlliance,
		this.teleopFuelNeutral,
		this.teleopFuelOpponent,
		this.teleopClimbLevel,
		this.teleopAlliancePasses,
		this.teleopOpponentPasses,
		this.teleopZoneInteractions,
		this.climbPosition,
		this.climbMethod,
		required this.shootOnMove,
		required this.shootWhileCollecting,
		required this.climbing,
		this.fuelStrategy,
		this.shootingLocations,
		this.damageState,
		this.defenseRating,
		this.defenseMethods,
		this.defenseImpact,
		this.shootingMissesRange,
		this.scouterName,
		this.comments,
		required this.reviewRequest,
		required this.synced,
		required this.createdAt,
		required this.updatedAt,
		this.syncedAt,
	});
	@override
	Map<String, Expression> toColumns(bool nullToAbsent) {
		final map = <String, Expression>{};
		map['event'] = Variable<String>(event);
		map['match'] = Variable<String>(match);
		map['team'] = Variable<String>(team);
		if (!nullToAbsent || startingPosition != null) {
			map['starting_position'] = Variable<String>(startingPosition);
		}
		map['no_show'] = Variable<bool>(noShow);
		if (!nullToAbsent || autoFuelAlliance != null) {
			map['auto_fuel_alliance'] = Variable<int>(autoFuelAlliance);
		}
		if (!nullToAbsent || autoFuelNeutral != null) {
			map['auto_fuel_neutral'] = Variable<int>(autoFuelNeutral);
		}
		if (!nullToAbsent || autoFuelOpponent != null) {
			map['auto_fuel_opponent'] = Variable<int>(autoFuelOpponent);
		}
		if (!nullToAbsent || autoFuelDepot != null) {
			map['auto_fuel_depot'] = Variable<int>(autoFuelDepot);
		}
		if (!nullToAbsent || autoFuelOutpost != null) {
			map['auto_fuel_outpost'] = Variable<int>(autoFuelOutpost);
		}
		if (!nullToAbsent || autoClimbLevel != null) {
			map['auto_climb_level'] = Variable<int>(autoClimbLevel);
		}
		map['auto_trench_depot_alliance_to_neutral'] = Variable<int>(
			autoTrenchDepotAllianceToNeutral,
		);
		map['auto_bump_depot_alliance_to_neutral'] = Variable<int>(
			autoBumpDepotAllianceToNeutral,
		);
		map['auto_bump_outpost_alliance_to_neutral'] = Variable<int>(
			autoBumpOutpostAllianceToNeutral,
		);
		map['auto_trench_outpost_alliance_to_neutral'] = Variable<int>(
			autoTrenchOutpostAllianceToNeutral,
		);
		map['auto_trench_depot_neutral_to_alliance'] = Variable<int>(
			autoTrenchDepotNeutralToAlliance,
		);
		map['auto_bump_depot_neutral_to_alliance'] = Variable<int>(
			autoBumpDepotNeutralToAlliance,
		);
		map['auto_bump_outpost_neutral_to_alliance'] = Variable<int>(
			autoBumpOutpostNeutralToAlliance,
		);
		map['auto_trench_outpost_neutral_to_alliance'] = Variable<int>(
			autoTrenchOutpostNeutralToAlliance,
		);
		map['auto_fuel_score'] = Variable<int>(autoFuelScore);
		map['auto_fuel_neutral_alliance_pass'] = Variable<int>(
			autoFuelNeutralAlliancePass,
		);
		map['auto_collect_outpost'] = Variable<bool>(autoCollectOutpost);
		map['auto_collect_depot'] = Variable<bool>(autoCollectDepot);
		map['auto_alliance_time'] = Variable<int>(autoAllianceTime);
		map['auto_neutral_time'] = Variable<int>(autoNeutralTime);
		if (!nullToAbsent || autoTimelineEvents != null) {
			map['auto_timeline_events'] = Variable<String>(autoTimelineEvents);
		}
		if (!nullToAbsent || teleopFuelAlliance != null) {
			map['teleop_fuel_alliance'] = Variable<int>(teleopFuelAlliance);
		}
		if (!nullToAbsent || teleopFuelNeutral != null) {
			map['teleop_fuel_neutral'] = Variable<int>(teleopFuelNeutral);
		}
		if (!nullToAbsent || teleopFuelOpponent != null) {
			map['teleop_fuel_opponent'] = Variable<int>(teleopFuelOpponent);
		}
		if (!nullToAbsent || teleopClimbLevel != null) {
			map['teleop_climb_level'] = Variable<int>(teleopClimbLevel);
		}
		if (!nullToAbsent || teleopAlliancePasses != null) {
			map['teleop_alliance_passes'] = Variable<int>(teleopAlliancePasses);
		}
		if (!nullToAbsent || teleopOpponentPasses != null) {
			map['teleop_opponent_passes'] = Variable<int>(teleopOpponentPasses);
		}
		if (!nullToAbsent || teleopZoneInteractions != null) {
			map['teleop_zone_interactions'] = Variable<String>(
				teleopZoneInteractions,
			);
		}
		if (!nullToAbsent || climbPosition != null) {
			map['climb_position'] = Variable<String>(climbPosition);
		}
		if (!nullToAbsent || climbMethod != null) {
			map['climb_method'] = Variable<String>(climbMethod);
		}
		map['shoot_on_move'] = Variable<bool>(shootOnMove);
		map['shoot_while_collecting'] = Variable<bool>(shootWhileCollecting);
		map['climbing'] = Variable<bool>(climbing);
		if (!nullToAbsent || fuelStrategy != null) {
			map['fuel_strategy'] = Variable<String>(fuelStrategy);
		}
		if (!nullToAbsent || shootingLocations != null) {
			map['shooting_locations'] = Variable<String>(shootingLocations);
		}
		if (!nullToAbsent || damageState != null) {
			map['damage_state'] = Variable<int>(damageState);
		}
		if (!nullToAbsent || defenseRating != null) {
			map['defense_rating'] = Variable<String>(defenseRating);
		}
		if (!nullToAbsent || defenseMethods != null) {
			map['defense_methods'] = Variable<String>(defenseMethods);
		}
		if (!nullToAbsent || defenseImpact != null) {
			map['defense_impact'] = Variable<String>(defenseImpact);
		}
		if (!nullToAbsent || shootingMissesRange != null) {
			map['shooting_misses_range'] = Variable<int>(shootingMissesRange);
		}
		if (!nullToAbsent || scouterName != null) {
			map['scouter_name'] = Variable<String>(scouterName);
		}
		if (!nullToAbsent || comments != null) {
			map['comments'] = Variable<String>(comments);
		}
		map['review_request'] = Variable<bool>(reviewRequest);
		map['synced'] = Variable<bool>(synced);
		map['created_at'] = Variable<DateTime>(createdAt);
		map['updated_at'] = Variable<DateTime>(updatedAt);
		if (!nullToAbsent || syncedAt != null) {
			map['synced_at'] = Variable<DateTime>(syncedAt);
		}
		return map;
	}

	ScoutCompanion toCompanion(bool nullToAbsent) {
		return ScoutCompanion(
			event: Value(event),
			match: Value(match),
			team: Value(team),
			startingPosition: startingPosition == null && nullToAbsent
					? const Value.absent()
					: Value(startingPosition),
			noShow: Value(noShow),
			autoFuelAlliance: autoFuelAlliance == null && nullToAbsent
					? const Value.absent()
					: Value(autoFuelAlliance),
			autoFuelNeutral: autoFuelNeutral == null && nullToAbsent
					? const Value.absent()
					: Value(autoFuelNeutral),
			autoFuelOpponent: autoFuelOpponent == null && nullToAbsent
					? const Value.absent()
					: Value(autoFuelOpponent),
			autoFuelDepot: autoFuelDepot == null && nullToAbsent
					? const Value.absent()
					: Value(autoFuelDepot),
			autoFuelOutpost: autoFuelOutpost == null && nullToAbsent
					? const Value.absent()
					: Value(autoFuelOutpost),
			autoClimbLevel: autoClimbLevel == null && nullToAbsent
					? const Value.absent()
					: Value(autoClimbLevel),
			autoTrenchDepotAllianceToNeutral: Value(autoTrenchDepotAllianceToNeutral),
			autoBumpDepotAllianceToNeutral: Value(autoBumpDepotAllianceToNeutral),
			autoBumpOutpostAllianceToNeutral: Value(autoBumpOutpostAllianceToNeutral),
			autoTrenchOutpostAllianceToNeutral: Value(
				autoTrenchOutpostAllianceToNeutral,
			),
			autoTrenchDepotNeutralToAlliance: Value(autoTrenchDepotNeutralToAlliance),
			autoBumpDepotNeutralToAlliance: Value(autoBumpDepotNeutralToAlliance),
			autoBumpOutpostNeutralToAlliance: Value(autoBumpOutpostNeutralToAlliance),
			autoTrenchOutpostNeutralToAlliance: Value(
				autoTrenchOutpostNeutralToAlliance,
			),
			autoFuelScore: Value(autoFuelScore),
			autoFuelNeutralAlliancePass: Value(autoFuelNeutralAlliancePass),
			autoCollectOutpost: Value(autoCollectOutpost),
			autoCollectDepot: Value(autoCollectDepot),
			autoAllianceTime: Value(autoAllianceTime),
			autoNeutralTime: Value(autoNeutralTime),
			autoTimelineEvents: autoTimelineEvents == null && nullToAbsent
					? const Value.absent()
					: Value(autoTimelineEvents),
			teleopFuelAlliance: teleopFuelAlliance == null && nullToAbsent
					? const Value.absent()
					: Value(teleopFuelAlliance),
			teleopFuelNeutral: teleopFuelNeutral == null && nullToAbsent
					? const Value.absent()
					: Value(teleopFuelNeutral),
			teleopFuelOpponent: teleopFuelOpponent == null && nullToAbsent
					? const Value.absent()
					: Value(teleopFuelOpponent),
			teleopClimbLevel: teleopClimbLevel == null && nullToAbsent
					? const Value.absent()
					: Value(teleopClimbLevel),
			teleopAlliancePasses: teleopAlliancePasses == null && nullToAbsent
					? const Value.absent()
					: Value(teleopAlliancePasses),
			teleopOpponentPasses: teleopOpponentPasses == null && nullToAbsent
					? const Value.absent()
					: Value(teleopOpponentPasses),
			teleopZoneInteractions: teleopZoneInteractions == null && nullToAbsent
					? const Value.absent()
					: Value(teleopZoneInteractions),
			climbPosition: climbPosition == null && nullToAbsent
					? const Value.absent()
					: Value(climbPosition),
			climbMethod: climbMethod == null && nullToAbsent
					? const Value.absent()
					: Value(climbMethod),
			shootOnMove: Value(shootOnMove),
			shootWhileCollecting: Value(shootWhileCollecting),
			climbing: Value(climbing),
			fuelStrategy: fuelStrategy == null && nullToAbsent
					? const Value.absent()
					: Value(fuelStrategy),
			shootingLocations: shootingLocations == null && nullToAbsent
					? const Value.absent()
					: Value(shootingLocations),
			damageState: damageState == null && nullToAbsent
					? const Value.absent()
					: Value(damageState),
			defenseRating: defenseRating == null && nullToAbsent
					? const Value.absent()
					: Value(defenseRating),
			defenseMethods: defenseMethods == null && nullToAbsent
					? const Value.absent()
					: Value(defenseMethods),
			defenseImpact: defenseImpact == null && nullToAbsent
					? const Value.absent()
					: Value(defenseImpact),
			shootingMissesRange: shootingMissesRange == null && nullToAbsent
					? const Value.absent()
					: Value(shootingMissesRange),
			scouterName: scouterName == null && nullToAbsent
					? const Value.absent()
					: Value(scouterName),
			comments: comments == null && nullToAbsent
					? const Value.absent()
					: Value(comments),
			reviewRequest: Value(reviewRequest),
			synced: Value(synced),
			createdAt: Value(createdAt),
			updatedAt: Value(updatedAt),
			syncedAt: syncedAt == null && nullToAbsent
					? const Value.absent()
					: Value(syncedAt),
		);
	}

	factory ScoutData.fromJson(
		Map<String, dynamic> json, {
		ValueSerializer? serializer,
	}) {
		serializer ??= driftRuntimeOptions.defaultSerializer;
		return ScoutData(
			event: serializer.fromJson<String>(json['event']),
			match: serializer.fromJson<String>(json['match']),
			team: serializer.fromJson<String>(json['team']),
			startingPosition: serializer.fromJson<String?>(json['startingPosition']),
			noShow: serializer.fromJson<bool>(json['noShow']),
			autoFuelAlliance: serializer.fromJson<int?>(json['autoFuelAlliance']),
			autoFuelNeutral: serializer.fromJson<int?>(json['autoFuelNeutral']),
			autoFuelOpponent: serializer.fromJson<int?>(json['autoFuelOpponent']),
			autoFuelDepot: serializer.fromJson<int?>(json['autoFuelDepot']),
			autoFuelOutpost: serializer.fromJson<int?>(json['autoFuelOutpost']),
			autoClimbLevel: serializer.fromJson<int?>(json['autoClimbLevel']),
			autoTrenchDepotAllianceToNeutral: serializer.fromJson<int>(
				json['autoTrenchDepotAllianceToNeutral'],
			),
			autoBumpDepotAllianceToNeutral: serializer.fromJson<int>(
				json['autoBumpDepotAllianceToNeutral'],
			),
			autoBumpOutpostAllianceToNeutral: serializer.fromJson<int>(
				json['autoBumpOutpostAllianceToNeutral'],
			),
			autoTrenchOutpostAllianceToNeutral: serializer.fromJson<int>(
				json['autoTrenchOutpostAllianceToNeutral'],
			),
			autoTrenchDepotNeutralToAlliance: serializer.fromJson<int>(
				json['autoTrenchDepotNeutralToAlliance'],
			),
			autoBumpDepotNeutralToAlliance: serializer.fromJson<int>(
				json['autoBumpDepotNeutralToAlliance'],
			),
			autoBumpOutpostNeutralToAlliance: serializer.fromJson<int>(
				json['autoBumpOutpostNeutralToAlliance'],
			),
			autoTrenchOutpostNeutralToAlliance: serializer.fromJson<int>(
				json['autoTrenchOutpostNeutralToAlliance'],
			),
			autoFuelScore: serializer.fromJson<int>(json['autoFuelScore']),
			autoFuelNeutralAlliancePass: serializer.fromJson<int>(
				json['autoFuelNeutralAlliancePass'],
			),
			autoCollectOutpost: serializer.fromJson<bool>(json['autoCollectOutpost']),
			autoCollectDepot: serializer.fromJson<bool>(json['autoCollectDepot']),
			autoAllianceTime: serializer.fromJson<int>(json['autoAllianceTime']),
			autoNeutralTime: serializer.fromJson<int>(json['autoNeutralTime']),
			autoTimelineEvents: serializer.fromJson<String?>(
				json['autoTimelineEvents'],
			),
			teleopFuelAlliance: serializer.fromJson<int?>(json['teleopFuelAlliance']),
			teleopFuelNeutral: serializer.fromJson<int?>(json['teleopFuelNeutral']),
			teleopFuelOpponent: serializer.fromJson<int?>(json['teleopFuelOpponent']),
			teleopClimbLevel: serializer.fromJson<int?>(json['teleopClimbLevel']),
			teleopAlliancePasses: serializer.fromJson<int?>(
				json['teleopAlliancePasses'],
			),
			teleopOpponentPasses: serializer.fromJson<int?>(
				json['teleopOpponentPasses'],
			),
			teleopZoneInteractions: serializer.fromJson<String?>(
				json['teleopZoneInteractions'],
			),
			climbPosition: serializer.fromJson<String?>(json['climbPosition']),
			climbMethod: serializer.fromJson<String?>(json['climbMethod']),
			shootOnMove: serializer.fromJson<bool>(json['shootOnMove']),
			shootWhileCollecting: serializer.fromJson<bool>(
				json['shootWhileCollecting'],
			),
			climbing: serializer.fromJson<bool>(json['climbing']),
			fuelStrategy: serializer.fromJson<String?>(json['fuelStrategy']),
			shootingLocations: serializer.fromJson<String?>(
				json['shootingLocations'],
			),
			damageState: serializer.fromJson<int?>(json['damageState']),
			defenseRating: serializer.fromJson<String?>(json['defenseRating']),
			defenseMethods: serializer.fromJson<String?>(json['defenseMethods']),
			defenseImpact: serializer.fromJson<String?>(json['defenseImpact']),
			shootingMissesRange: serializer.fromJson<int?>(
				json['shootingMissesRange'],
			),
			scouterName: serializer.fromJson<String?>(json['scouterName']),
			comments: serializer.fromJson<String?>(json['comments']),
			reviewRequest: serializer.fromJson<bool>(json['reviewRequest']),
			synced: serializer.fromJson<bool>(json['synced']),
			createdAt: serializer.fromJson<DateTime>(json['createdAt']),
			updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
			syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
		);
	}
	@override
	Map<String, dynamic> toJson({ValueSerializer? serializer}) {
		serializer ??= driftRuntimeOptions.defaultSerializer;
		return <String, dynamic>{
			'event': serializer.toJson<String>(event),
			'match': serializer.toJson<String>(match),
			'team': serializer.toJson<String>(team),
			'startingPosition': serializer.toJson<String?>(startingPosition),
			'noShow': serializer.toJson<bool>(noShow),
			'autoFuelAlliance': serializer.toJson<int?>(autoFuelAlliance),
			'autoFuelNeutral': serializer.toJson<int?>(autoFuelNeutral),
			'autoFuelOpponent': serializer.toJson<int?>(autoFuelOpponent),
			'autoFuelDepot': serializer.toJson<int?>(autoFuelDepot),
			'autoFuelOutpost': serializer.toJson<int?>(autoFuelOutpost),
			'autoClimbLevel': serializer.toJson<int?>(autoClimbLevel),
			'autoTrenchDepotAllianceToNeutral': serializer.toJson<int>(
				autoTrenchDepotAllianceToNeutral,
			),
			'autoBumpDepotAllianceToNeutral': serializer.toJson<int>(
				autoBumpDepotAllianceToNeutral,
			),
			'autoBumpOutpostAllianceToNeutral': serializer.toJson<int>(
				autoBumpOutpostAllianceToNeutral,
			),
			'autoTrenchOutpostAllianceToNeutral': serializer.toJson<int>(
				autoTrenchOutpostAllianceToNeutral,
			),
			'autoTrenchDepotNeutralToAlliance': serializer.toJson<int>(
				autoTrenchDepotNeutralToAlliance,
			),
			'autoBumpDepotNeutralToAlliance': serializer.toJson<int>(
				autoBumpDepotNeutralToAlliance,
			),
			'autoBumpOutpostNeutralToAlliance': serializer.toJson<int>(
				autoBumpOutpostNeutralToAlliance,
			),
			'autoTrenchOutpostNeutralToAlliance': serializer.toJson<int>(
				autoTrenchOutpostNeutralToAlliance,
			),
			'autoFuelScore': serializer.toJson<int>(autoFuelScore),
			'autoFuelNeutralAlliancePass': serializer.toJson<int>(
				autoFuelNeutralAlliancePass,
			),
			'autoCollectOutpost': serializer.toJson<bool>(autoCollectOutpost),
			'autoCollectDepot': serializer.toJson<bool>(autoCollectDepot),
			'autoAllianceTime': serializer.toJson<int>(autoAllianceTime),
			'autoNeutralTime': serializer.toJson<int>(autoNeutralTime),
			'autoTimelineEvents': serializer.toJson<String?>(autoTimelineEvents),
			'teleopFuelAlliance': serializer.toJson<int?>(teleopFuelAlliance),
			'teleopFuelNeutral': serializer.toJson<int?>(teleopFuelNeutral),
			'teleopFuelOpponent': serializer.toJson<int?>(teleopFuelOpponent),
			'teleopClimbLevel': serializer.toJson<int?>(teleopClimbLevel),
			'teleopAlliancePasses': serializer.toJson<int?>(teleopAlliancePasses),
			'teleopOpponentPasses': serializer.toJson<int?>(teleopOpponentPasses),
			'teleopZoneInteractions': serializer.toJson<String?>(
				teleopZoneInteractions,
			),
			'climbPosition': serializer.toJson<String?>(climbPosition),
			'climbMethod': serializer.toJson<String?>(climbMethod),
			'shootOnMove': serializer.toJson<bool>(shootOnMove),
			'shootWhileCollecting': serializer.toJson<bool>(shootWhileCollecting),
			'climbing': serializer.toJson<bool>(climbing),
			'fuelStrategy': serializer.toJson<String?>(fuelStrategy),
			'shootingLocations': serializer.toJson<String?>(shootingLocations),
			'damageState': serializer.toJson<int?>(damageState),
			'defenseRating': serializer.toJson<String?>(defenseRating),
			'defenseMethods': serializer.toJson<String?>(defenseMethods),
			'defenseImpact': serializer.toJson<String?>(defenseImpact),
			'shootingMissesRange': serializer.toJson<int?>(shootingMissesRange),
			'scouterName': serializer.toJson<String?>(scouterName),
			'comments': serializer.toJson<String?>(comments),
			'reviewRequest': serializer.toJson<bool>(reviewRequest),
			'synced': serializer.toJson<bool>(synced),
			'createdAt': serializer.toJson<DateTime>(createdAt),
			'updatedAt': serializer.toJson<DateTime>(updatedAt),
			'syncedAt': serializer.toJson<DateTime?>(syncedAt),
		};
	}

	ScoutData copyWith({
		String? event,
		String? match,
		String? team,
		Value<String?> startingPosition = const Value.absent(),
		bool? noShow,
		Value<int?> autoFuelAlliance = const Value.absent(),
		Value<int?> autoFuelNeutral = const Value.absent(),
		Value<int?> autoFuelOpponent = const Value.absent(),
		Value<int?> autoFuelDepot = const Value.absent(),
		Value<int?> autoFuelOutpost = const Value.absent(),
		Value<int?> autoClimbLevel = const Value.absent(),
		int? autoTrenchDepotAllianceToNeutral,
		int? autoBumpDepotAllianceToNeutral,
		int? autoBumpOutpostAllianceToNeutral,
		int? autoTrenchOutpostAllianceToNeutral,
		int? autoTrenchDepotNeutralToAlliance,
		int? autoBumpDepotNeutralToAlliance,
		int? autoBumpOutpostNeutralToAlliance,
		int? autoTrenchOutpostNeutralToAlliance,
		int? autoFuelScore,
		int? autoFuelNeutralAlliancePass,
		bool? autoCollectOutpost,
		bool? autoCollectDepot,
		int? autoAllianceTime,
		int? autoNeutralTime,
		Value<String?> autoTimelineEvents = const Value.absent(),
		Value<int?> teleopFuelAlliance = const Value.absent(),
		Value<int?> teleopFuelNeutral = const Value.absent(),
		Value<int?> teleopFuelOpponent = const Value.absent(),
		Value<int?> teleopClimbLevel = const Value.absent(),
		Value<int?> teleopAlliancePasses = const Value.absent(),
		Value<int?> teleopOpponentPasses = const Value.absent(),
		Value<String?> teleopZoneInteractions = const Value.absent(),
		Value<String?> climbPosition = const Value.absent(),
		Value<String?> climbMethod = const Value.absent(),
		bool? shootOnMove,
		bool? shootWhileCollecting,
		bool? climbing,
		Value<String?> fuelStrategy = const Value.absent(),
		Value<String?> shootingLocations = const Value.absent(),
		Value<int?> damageState = const Value.absent(),
		Value<String?> defenseRating = const Value.absent(),
		Value<String?> defenseMethods = const Value.absent(),
		Value<String?> defenseImpact = const Value.absent(),
		Value<int?> shootingMissesRange = const Value.absent(),
		Value<String?> scouterName = const Value.absent(),
		Value<String?> comments = const Value.absent(),
		bool? reviewRequest,
		bool? synced,
		DateTime? createdAt,
		DateTime? updatedAt,
		Value<DateTime?> syncedAt = const Value.absent(),
	}) => ScoutData(
		event: event ?? this.event,
		match: match ?? this.match,
		team: team ?? this.team,
		startingPosition: startingPosition.present
				? startingPosition.value
				: this.startingPosition,
		noShow: noShow ?? this.noShow,
		autoFuelAlliance: autoFuelAlliance.present
				? autoFuelAlliance.value
				: this.autoFuelAlliance,
		autoFuelNeutral: autoFuelNeutral.present
				? autoFuelNeutral.value
				: this.autoFuelNeutral,
		autoFuelOpponent: autoFuelOpponent.present
				? autoFuelOpponent.value
				: this.autoFuelOpponent,
		autoFuelDepot: autoFuelDepot.present
				? autoFuelDepot.value
				: this.autoFuelDepot,
		autoFuelOutpost: autoFuelOutpost.present
				? autoFuelOutpost.value
				: this.autoFuelOutpost,
		autoClimbLevel: autoClimbLevel.present
				? autoClimbLevel.value
				: this.autoClimbLevel,
		autoTrenchDepotAllianceToNeutral:
				autoTrenchDepotAllianceToNeutral ??
				this.autoTrenchDepotAllianceToNeutral,
		autoBumpDepotAllianceToNeutral:
				autoBumpDepotAllianceToNeutral ?? this.autoBumpDepotAllianceToNeutral,
		autoBumpOutpostAllianceToNeutral:
				autoBumpOutpostAllianceToNeutral ??
				this.autoBumpOutpostAllianceToNeutral,
		autoTrenchOutpostAllianceToNeutral:
				autoTrenchOutpostAllianceToNeutral ??
				this.autoTrenchOutpostAllianceToNeutral,
		autoTrenchDepotNeutralToAlliance:
				autoTrenchDepotNeutralToAlliance ??
				this.autoTrenchDepotNeutralToAlliance,
		autoBumpDepotNeutralToAlliance:
				autoBumpDepotNeutralToAlliance ?? this.autoBumpDepotNeutralToAlliance,
		autoBumpOutpostNeutralToAlliance:
				autoBumpOutpostNeutralToAlliance ??
				this.autoBumpOutpostNeutralToAlliance,
		autoTrenchOutpostNeutralToAlliance:
				autoTrenchOutpostNeutralToAlliance ??
				this.autoTrenchOutpostNeutralToAlliance,
		autoFuelScore: autoFuelScore ?? this.autoFuelScore,
		autoFuelNeutralAlliancePass:
				autoFuelNeutralAlliancePass ?? this.autoFuelNeutralAlliancePass,
		autoCollectOutpost: autoCollectOutpost ?? this.autoCollectOutpost,
		autoCollectDepot: autoCollectDepot ?? this.autoCollectDepot,
		autoAllianceTime: autoAllianceTime ?? this.autoAllianceTime,
		autoNeutralTime: autoNeutralTime ?? this.autoNeutralTime,
		autoTimelineEvents: autoTimelineEvents.present
				? autoTimelineEvents.value
				: this.autoTimelineEvents,
		teleopFuelAlliance: teleopFuelAlliance.present
				? teleopFuelAlliance.value
				: this.teleopFuelAlliance,
		teleopFuelNeutral: teleopFuelNeutral.present
				? teleopFuelNeutral.value
				: this.teleopFuelNeutral,
		teleopFuelOpponent: teleopFuelOpponent.present
				? teleopFuelOpponent.value
				: this.teleopFuelOpponent,
		teleopClimbLevel: teleopClimbLevel.present
				? teleopClimbLevel.value
				: this.teleopClimbLevel,
		teleopAlliancePasses: teleopAlliancePasses.present
				? teleopAlliancePasses.value
				: this.teleopAlliancePasses,
		teleopOpponentPasses: teleopOpponentPasses.present
				? teleopOpponentPasses.value
				: this.teleopOpponentPasses,
		teleopZoneInteractions: teleopZoneInteractions.present
				? teleopZoneInteractions.value
				: this.teleopZoneInteractions,
		climbPosition: climbPosition.present
				? climbPosition.value
				: this.climbPosition,
		climbMethod: climbMethod.present ? climbMethod.value : this.climbMethod,
		shootOnMove: shootOnMove ?? this.shootOnMove,
		shootWhileCollecting: shootWhileCollecting ?? this.shootWhileCollecting,
		climbing: climbing ?? this.climbing,
		fuelStrategy: fuelStrategy.present ? fuelStrategy.value : this.fuelStrategy,
		shootingLocations: shootingLocations.present
				? shootingLocations.value
				: this.shootingLocations,
		damageState: damageState.present ? damageState.value : this.damageState,
		defenseRating: defenseRating.present
				? defenseRating.value
				: this.defenseRating,
		defenseMethods: defenseMethods.present
				? defenseMethods.value
				: this.defenseMethods,
		defenseImpact: defenseImpact.present
				? defenseImpact.value
				: this.defenseImpact,
		shootingMissesRange: shootingMissesRange.present
				? shootingMissesRange.value
				: this.shootingMissesRange,
		scouterName: scouterName.present ? scouterName.value : this.scouterName,
		comments: comments.present ? comments.value : this.comments,
		reviewRequest: reviewRequest ?? this.reviewRequest,
		synced: synced ?? this.synced,
		createdAt: createdAt ?? this.createdAt,
		updatedAt: updatedAt ?? this.updatedAt,
		syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
	);
	ScoutData copyWithCompanion(ScoutCompanion data) {
		return ScoutData(
			event: data.event.present ? data.event.value : this.event,
			match: data.match.present ? data.match.value : this.match,
			team: data.team.present ? data.team.value : this.team,
			startingPosition: data.startingPosition.present
					? data.startingPosition.value
					: this.startingPosition,
			noShow: data.noShow.present ? data.noShow.value : this.noShow,
			autoFuelAlliance: data.autoFuelAlliance.present
					? data.autoFuelAlliance.value
					: this.autoFuelAlliance,
			autoFuelNeutral: data.autoFuelNeutral.present
					? data.autoFuelNeutral.value
					: this.autoFuelNeutral,
			autoFuelOpponent: data.autoFuelOpponent.present
					? data.autoFuelOpponent.value
					: this.autoFuelOpponent,
			autoFuelDepot: data.autoFuelDepot.present
					? data.autoFuelDepot.value
					: this.autoFuelDepot,
			autoFuelOutpost: data.autoFuelOutpost.present
					? data.autoFuelOutpost.value
					: this.autoFuelOutpost,
			autoClimbLevel: data.autoClimbLevel.present
					? data.autoClimbLevel.value
					: this.autoClimbLevel,
			autoTrenchDepotAllianceToNeutral:
					data.autoTrenchDepotAllianceToNeutral.present
					? data.autoTrenchDepotAllianceToNeutral.value
					: this.autoTrenchDepotAllianceToNeutral,
			autoBumpDepotAllianceToNeutral:
					data.autoBumpDepotAllianceToNeutral.present
					? data.autoBumpDepotAllianceToNeutral.value
					: this.autoBumpDepotAllianceToNeutral,
			autoBumpOutpostAllianceToNeutral:
					data.autoBumpOutpostAllianceToNeutral.present
					? data.autoBumpOutpostAllianceToNeutral.value
					: this.autoBumpOutpostAllianceToNeutral,
			autoTrenchOutpostAllianceToNeutral:
					data.autoTrenchOutpostAllianceToNeutral.present
					? data.autoTrenchOutpostAllianceToNeutral.value
					: this.autoTrenchOutpostAllianceToNeutral,
			autoTrenchDepotNeutralToAlliance:
					data.autoTrenchDepotNeutralToAlliance.present
					? data.autoTrenchDepotNeutralToAlliance.value
					: this.autoTrenchDepotNeutralToAlliance,
			autoBumpDepotNeutralToAlliance:
					data.autoBumpDepotNeutralToAlliance.present
					? data.autoBumpDepotNeutralToAlliance.value
					: this.autoBumpDepotNeutralToAlliance,
			autoBumpOutpostNeutralToAlliance:
					data.autoBumpOutpostNeutralToAlliance.present
					? data.autoBumpOutpostNeutralToAlliance.value
					: this.autoBumpOutpostNeutralToAlliance,
			autoTrenchOutpostNeutralToAlliance:
					data.autoTrenchOutpostNeutralToAlliance.present
					? data.autoTrenchOutpostNeutralToAlliance.value
					: this.autoTrenchOutpostNeutralToAlliance,
			autoFuelScore: data.autoFuelScore.present
					? data.autoFuelScore.value
					: this.autoFuelScore,
			autoFuelNeutralAlliancePass: data.autoFuelNeutralAlliancePass.present
					? data.autoFuelNeutralAlliancePass.value
					: this.autoFuelNeutralAlliancePass,
			autoCollectOutpost: data.autoCollectOutpost.present
					? data.autoCollectOutpost.value
					: this.autoCollectOutpost,
			autoCollectDepot: data.autoCollectDepot.present
					? data.autoCollectDepot.value
					: this.autoCollectDepot,
			autoAllianceTime: data.autoAllianceTime.present
					? data.autoAllianceTime.value
					: this.autoAllianceTime,
			autoNeutralTime: data.autoNeutralTime.present
					? data.autoNeutralTime.value
					: this.autoNeutralTime,
			autoTimelineEvents: data.autoTimelineEvents.present
					? data.autoTimelineEvents.value
					: this.autoTimelineEvents,
			teleopFuelAlliance: data.teleopFuelAlliance.present
					? data.teleopFuelAlliance.value
					: this.teleopFuelAlliance,
			teleopFuelNeutral: data.teleopFuelNeutral.present
					? data.teleopFuelNeutral.value
					: this.teleopFuelNeutral,
			teleopFuelOpponent: data.teleopFuelOpponent.present
					? data.teleopFuelOpponent.value
					: this.teleopFuelOpponent,
			teleopClimbLevel: data.teleopClimbLevel.present
					? data.teleopClimbLevel.value
					: this.teleopClimbLevel,
			teleopAlliancePasses: data.teleopAlliancePasses.present
					? data.teleopAlliancePasses.value
					: this.teleopAlliancePasses,
			teleopOpponentPasses: data.teleopOpponentPasses.present
					? data.teleopOpponentPasses.value
					: this.teleopOpponentPasses,
			teleopZoneInteractions: data.teleopZoneInteractions.present
					? data.teleopZoneInteractions.value
					: this.teleopZoneInteractions,
			climbPosition: data.climbPosition.present
					? data.climbPosition.value
					: this.climbPosition,
			climbMethod: data.climbMethod.present
					? data.climbMethod.value
					: this.climbMethod,
			shootOnMove: data.shootOnMove.present
					? data.shootOnMove.value
					: this.shootOnMove,
			shootWhileCollecting: data.shootWhileCollecting.present
					? data.shootWhileCollecting.value
					: this.shootWhileCollecting,
			climbing: data.climbing.present ? data.climbing.value : this.climbing,
			fuelStrategy: data.fuelStrategy.present
					? data.fuelStrategy.value
					: this.fuelStrategy,
			shootingLocations: data.shootingLocations.present
					? data.shootingLocations.value
					: this.shootingLocations,
			damageState: data.damageState.present
					? data.damageState.value
					: this.damageState,
			defenseRating: data.defenseRating.present
					? data.defenseRating.value
					: this.defenseRating,
			defenseMethods: data.defenseMethods.present
					? data.defenseMethods.value
					: this.defenseMethods,
			defenseImpact: data.defenseImpact.present
					? data.defenseImpact.value
					: this.defenseImpact,
			shootingMissesRange: data.shootingMissesRange.present
					? data.shootingMissesRange.value
					: this.shootingMissesRange,
			scouterName: data.scouterName.present
					? data.scouterName.value
					: this.scouterName,
			comments: data.comments.present ? data.comments.value : this.comments,
			reviewRequest: data.reviewRequest.present
					? data.reviewRequest.value
					: this.reviewRequest,
			synced: data.synced.present ? data.synced.value : this.synced,
			createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
			updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
			syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
		);
	}

	@override
	String toString() {
		return (StringBuffer('ScoutData(')
					..write('event: $event, ')
					..write('match: $match, ')
					..write('team: $team, ')
					..write('startingPosition: $startingPosition, ')
					..write('noShow: $noShow, ')
					..write('autoFuelAlliance: $autoFuelAlliance, ')
					..write('autoFuelNeutral: $autoFuelNeutral, ')
					..write('autoFuelOpponent: $autoFuelOpponent, ')
					..write('autoFuelDepot: $autoFuelDepot, ')
					..write('autoFuelOutpost: $autoFuelOutpost, ')
					..write('autoClimbLevel: $autoClimbLevel, ')
					..write(
						'autoTrenchDepotAllianceToNeutral: $autoTrenchDepotAllianceToNeutral, ',
					)
					..write(
						'autoBumpDepotAllianceToNeutral: $autoBumpDepotAllianceToNeutral, ',
					)
					..write(
						'autoBumpOutpostAllianceToNeutral: $autoBumpOutpostAllianceToNeutral, ',
					)
					..write(
						'autoTrenchOutpostAllianceToNeutral: $autoTrenchOutpostAllianceToNeutral, ',
					)
					..write(
						'autoTrenchDepotNeutralToAlliance: $autoTrenchDepotNeutralToAlliance, ',
					)
					..write(
						'autoBumpDepotNeutralToAlliance: $autoBumpDepotNeutralToAlliance, ',
					)
					..write(
						'autoBumpOutpostNeutralToAlliance: $autoBumpOutpostNeutralToAlliance, ',
					)
					..write(
						'autoTrenchOutpostNeutralToAlliance: $autoTrenchOutpostNeutralToAlliance, ',
					)
					..write('autoFuelScore: $autoFuelScore, ')
					..write('autoFuelNeutralAlliancePass: $autoFuelNeutralAlliancePass, ')
					..write('autoCollectOutpost: $autoCollectOutpost, ')
					..write('autoCollectDepot: $autoCollectDepot, ')
					..write('autoAllianceTime: $autoAllianceTime, ')
					..write('autoNeutralTime: $autoNeutralTime, ')
					..write('autoTimelineEvents: $autoTimelineEvents, ')
					..write('teleopFuelAlliance: $teleopFuelAlliance, ')
					..write('teleopFuelNeutral: $teleopFuelNeutral, ')
					..write('teleopFuelOpponent: $teleopFuelOpponent, ')
					..write('teleopClimbLevel: $teleopClimbLevel, ')
					..write('teleopAlliancePasses: $teleopAlliancePasses, ')
					..write('teleopOpponentPasses: $teleopOpponentPasses, ')
					..write('teleopZoneInteractions: $teleopZoneInteractions, ')
					..write('climbPosition: $climbPosition, ')
					..write('climbMethod: $climbMethod, ')
					..write('shootOnMove: $shootOnMove, ')
					..write('shootWhileCollecting: $shootWhileCollecting, ')
					..write('climbing: $climbing, ')
					..write('fuelStrategy: $fuelStrategy, ')
					..write('shootingLocations: $shootingLocations, ')
					..write('damageState: $damageState, ')
					..write('defenseRating: $defenseRating, ')
					..write('defenseMethods: $defenseMethods, ')
					..write('defenseImpact: $defenseImpact, ')
					..write('shootingMissesRange: $shootingMissesRange, ')
					..write('scouterName: $scouterName, ')
					..write('comments: $comments, ')
					..write('reviewRequest: $reviewRequest, ')
					..write('synced: $synced, ')
					..write('createdAt: $createdAt, ')
					..write('updatedAt: $updatedAt, ')
					..write('syncedAt: $syncedAt')
					..write(')'))
				.toString();
	}

	@override
	int get hashCode => Object.hashAll([
		event,
		match,
		team,
		startingPosition,
		noShow,
		autoFuelAlliance,
		autoFuelNeutral,
		autoFuelOpponent,
		autoFuelDepot,
		autoFuelOutpost,
		autoClimbLevel,
		autoTrenchDepotAllianceToNeutral,
		autoBumpDepotAllianceToNeutral,
		autoBumpOutpostAllianceToNeutral,
		autoTrenchOutpostAllianceToNeutral,
		autoTrenchDepotNeutralToAlliance,
		autoBumpDepotNeutralToAlliance,
		autoBumpOutpostNeutralToAlliance,
		autoTrenchOutpostNeutralToAlliance,
		autoFuelScore,
		autoFuelNeutralAlliancePass,
		autoCollectOutpost,
		autoCollectDepot,
		autoAllianceTime,
		autoNeutralTime,
		autoTimelineEvents,
		teleopFuelAlliance,
		teleopFuelNeutral,
		teleopFuelOpponent,
		teleopClimbLevel,
		teleopAlliancePasses,
		teleopOpponentPasses,
		teleopZoneInteractions,
		climbPosition,
		climbMethod,
		shootOnMove,
		shootWhileCollecting,
		climbing,
		fuelStrategy,
		shootingLocations,
		damageState,
		defenseRating,
		defenseMethods,
		defenseImpact,
		shootingMissesRange,
		scouterName,
		comments,
		reviewRequest,
		synced,
		createdAt,
		updatedAt,
		syncedAt,
	]);
	@override
	bool operator ==(Object other) =>
			identical(this, other) ||
			(other is ScoutData &&
					other.event == this.event &&
					other.match == this.match &&
					other.team == this.team &&
					other.startingPosition == this.startingPosition &&
					other.noShow == this.noShow &&
					other.autoFuelAlliance == this.autoFuelAlliance &&
					other.autoFuelNeutral == this.autoFuelNeutral &&
					other.autoFuelOpponent == this.autoFuelOpponent &&
					other.autoFuelDepot == this.autoFuelDepot &&
					other.autoFuelOutpost == this.autoFuelOutpost &&
					other.autoClimbLevel == this.autoClimbLevel &&
					other.autoTrenchDepotAllianceToNeutral ==
							this.autoTrenchDepotAllianceToNeutral &&
					other.autoBumpDepotAllianceToNeutral ==
							this.autoBumpDepotAllianceToNeutral &&
					other.autoBumpOutpostAllianceToNeutral ==
							this.autoBumpOutpostAllianceToNeutral &&
					other.autoTrenchOutpostAllianceToNeutral ==
							this.autoTrenchOutpostAllianceToNeutral &&
					other.autoTrenchDepotNeutralToAlliance ==
							this.autoTrenchDepotNeutralToAlliance &&
					other.autoBumpDepotNeutralToAlliance ==
							this.autoBumpDepotNeutralToAlliance &&
					other.autoBumpOutpostNeutralToAlliance ==
							this.autoBumpOutpostNeutralToAlliance &&
					other.autoTrenchOutpostNeutralToAlliance ==
							this.autoTrenchOutpostNeutralToAlliance &&
					other.autoFuelScore == this.autoFuelScore &&
					other.autoFuelNeutralAlliancePass ==
							this.autoFuelNeutralAlliancePass &&
					other.autoCollectOutpost == this.autoCollectOutpost &&
					other.autoCollectDepot == this.autoCollectDepot &&
					other.autoAllianceTime == this.autoAllianceTime &&
					other.autoNeutralTime == this.autoNeutralTime &&
					other.autoTimelineEvents == this.autoTimelineEvents &&
					other.teleopFuelAlliance == this.teleopFuelAlliance &&
					other.teleopFuelNeutral == this.teleopFuelNeutral &&
					other.teleopFuelOpponent == this.teleopFuelOpponent &&
					other.teleopClimbLevel == this.teleopClimbLevel &&
					other.teleopAlliancePasses == this.teleopAlliancePasses &&
					other.teleopOpponentPasses == this.teleopOpponentPasses &&
					other.teleopZoneInteractions == this.teleopZoneInteractions &&
					other.climbPosition == this.climbPosition &&
					other.climbMethod == this.climbMethod &&
					other.shootOnMove == this.shootOnMove &&
					other.shootWhileCollecting == this.shootWhileCollecting &&
					other.climbing == this.climbing &&
					other.fuelStrategy == this.fuelStrategy &&
					other.shootingLocations == this.shootingLocations &&
					other.damageState == this.damageState &&
					other.defenseRating == this.defenseRating &&
					other.defenseMethods == this.defenseMethods &&
					other.defenseImpact == this.defenseImpact &&
					other.shootingMissesRange == this.shootingMissesRange &&
					other.scouterName == this.scouterName &&
					other.comments == this.comments &&
					other.reviewRequest == this.reviewRequest &&
					other.synced == this.synced &&
					other.createdAt == this.createdAt &&
					other.updatedAt == this.updatedAt &&
					other.syncedAt == this.syncedAt);
}

class ScoutCompanion extends UpdateCompanion<ScoutData> {
	final Value<String> event;
	final Value<String> match;
	final Value<String> team;
	final Value<String?> startingPosition;
	final Value<bool> noShow;
	final Value<int?> autoFuelAlliance;
	final Value<int?> autoFuelNeutral;
	final Value<int?> autoFuelOpponent;
	final Value<int?> autoFuelDepot;
	final Value<int?> autoFuelOutpost;
	final Value<int?> autoClimbLevel;
	final Value<int> autoTrenchDepotAllianceToNeutral;
	final Value<int> autoBumpDepotAllianceToNeutral;
	final Value<int> autoBumpOutpostAllianceToNeutral;
	final Value<int> autoTrenchOutpostAllianceToNeutral;
	final Value<int> autoTrenchDepotNeutralToAlliance;
	final Value<int> autoBumpDepotNeutralToAlliance;
	final Value<int> autoBumpOutpostNeutralToAlliance;
	final Value<int> autoTrenchOutpostNeutralToAlliance;
	final Value<int> autoFuelScore;
	final Value<int> autoFuelNeutralAlliancePass;
	final Value<bool> autoCollectOutpost;
	final Value<bool> autoCollectDepot;
	final Value<int> autoAllianceTime;
	final Value<int> autoNeutralTime;
	final Value<String?> autoTimelineEvents;
	final Value<int?> teleopFuelAlliance;
	final Value<int?> teleopFuelNeutral;
	final Value<int?> teleopFuelOpponent;
	final Value<int?> teleopClimbLevel;
	final Value<int?> teleopAlliancePasses;
	final Value<int?> teleopOpponentPasses;
	final Value<String?> teleopZoneInteractions;
	final Value<String?> climbPosition;
	final Value<String?> climbMethod;
	final Value<bool> shootOnMove;
	final Value<bool> shootWhileCollecting;
	final Value<bool> climbing;
	final Value<String?> fuelStrategy;
	final Value<String?> shootingLocations;
	final Value<int?> damageState;
	final Value<String?> defenseRating;
	final Value<String?> defenseMethods;
	final Value<String?> defenseImpact;
	final Value<int?> shootingMissesRange;
	final Value<String?> scouterName;
	final Value<String?> comments;
	final Value<bool> reviewRequest;
	final Value<bool> synced;
	final Value<DateTime> createdAt;
	final Value<DateTime> updatedAt;
	final Value<DateTime?> syncedAt;
	final Value<int> rowid;
	const ScoutCompanion({
		this.event = const Value.absent(),
		this.match = const Value.absent(),
		this.team = const Value.absent(),
		this.startingPosition = const Value.absent(),
		this.noShow = const Value.absent(),
		this.autoFuelAlliance = const Value.absent(),
		this.autoFuelNeutral = const Value.absent(),
		this.autoFuelOpponent = const Value.absent(),
		this.autoFuelDepot = const Value.absent(),
		this.autoFuelOutpost = const Value.absent(),
		this.autoClimbLevel = const Value.absent(),
		this.autoTrenchDepotAllianceToNeutral = const Value.absent(),
		this.autoBumpDepotAllianceToNeutral = const Value.absent(),
		this.autoBumpOutpostAllianceToNeutral = const Value.absent(),
		this.autoTrenchOutpostAllianceToNeutral = const Value.absent(),
		this.autoTrenchDepotNeutralToAlliance = const Value.absent(),
		this.autoBumpDepotNeutralToAlliance = const Value.absent(),
		this.autoBumpOutpostNeutralToAlliance = const Value.absent(),
		this.autoTrenchOutpostNeutralToAlliance = const Value.absent(),
		this.autoFuelScore = const Value.absent(),
		this.autoFuelNeutralAlliancePass = const Value.absent(),
		this.autoCollectOutpost = const Value.absent(),
		this.autoCollectDepot = const Value.absent(),
		this.autoAllianceTime = const Value.absent(),
		this.autoNeutralTime = const Value.absent(),
		this.autoTimelineEvents = const Value.absent(),
		this.teleopFuelAlliance = const Value.absent(),
		this.teleopFuelNeutral = const Value.absent(),
		this.teleopFuelOpponent = const Value.absent(),
		this.teleopClimbLevel = const Value.absent(),
		this.teleopAlliancePasses = const Value.absent(),
		this.teleopOpponentPasses = const Value.absent(),
		this.teleopZoneInteractions = const Value.absent(),
		this.climbPosition = const Value.absent(),
		this.climbMethod = const Value.absent(),
		this.shootOnMove = const Value.absent(),
		this.shootWhileCollecting = const Value.absent(),
		this.climbing = const Value.absent(),
		this.fuelStrategy = const Value.absent(),
		this.shootingLocations = const Value.absent(),
		this.damageState = const Value.absent(),
		this.defenseRating = const Value.absent(),
		this.defenseMethods = const Value.absent(),
		this.defenseImpact = const Value.absent(),
		this.shootingMissesRange = const Value.absent(),
		this.scouterName = const Value.absent(),
		this.comments = const Value.absent(),
		this.reviewRequest = const Value.absent(),
		this.synced = const Value.absent(),
		this.createdAt = const Value.absent(),
		this.updatedAt = const Value.absent(),
		this.syncedAt = const Value.absent(),
		this.rowid = const Value.absent(),
	});
	ScoutCompanion.insert({
		required String event,
		required String match,
		required String team,
		this.startingPosition = const Value.absent(),
		this.noShow = const Value.absent(),
		this.autoFuelAlliance = const Value.absent(),
		this.autoFuelNeutral = const Value.absent(),
		this.autoFuelOpponent = const Value.absent(),
		this.autoFuelDepot = const Value.absent(),
		this.autoFuelOutpost = const Value.absent(),
		this.autoClimbLevel = const Value.absent(),
		this.autoTrenchDepotAllianceToNeutral = const Value.absent(),
		this.autoBumpDepotAllianceToNeutral = const Value.absent(),
		this.autoBumpOutpostAllianceToNeutral = const Value.absent(),
		this.autoTrenchOutpostAllianceToNeutral = const Value.absent(),
		this.autoTrenchDepotNeutralToAlliance = const Value.absent(),
		this.autoBumpDepotNeutralToAlliance = const Value.absent(),
		this.autoBumpOutpostNeutralToAlliance = const Value.absent(),
		this.autoTrenchOutpostNeutralToAlliance = const Value.absent(),
		this.autoFuelScore = const Value.absent(),
		this.autoFuelNeutralAlliancePass = const Value.absent(),
		this.autoCollectOutpost = const Value.absent(),
		this.autoCollectDepot = const Value.absent(),
		this.autoAllianceTime = const Value.absent(),
		this.autoNeutralTime = const Value.absent(),
		this.autoTimelineEvents = const Value.absent(),
		this.teleopFuelAlliance = const Value.absent(),
		this.teleopFuelNeutral = const Value.absent(),
		this.teleopFuelOpponent = const Value.absent(),
		this.teleopClimbLevel = const Value.absent(),
		this.teleopAlliancePasses = const Value.absent(),
		this.teleopOpponentPasses = const Value.absent(),
		this.teleopZoneInteractions = const Value.absent(),
		this.climbPosition = const Value.absent(),
		this.climbMethod = const Value.absent(),
		this.shootOnMove = const Value.absent(),
		this.shootWhileCollecting = const Value.absent(),
		this.climbing = const Value.absent(),
		this.fuelStrategy = const Value.absent(),
		this.shootingLocations = const Value.absent(),
		this.damageState = const Value.absent(),
		this.defenseRating = const Value.absent(),
		this.defenseMethods = const Value.absent(),
		this.defenseImpact = const Value.absent(),
		this.shootingMissesRange = const Value.absent(),
		this.scouterName = const Value.absent(),
		this.comments = const Value.absent(),
		this.reviewRequest = const Value.absent(),
		this.synced = const Value.absent(),
		this.createdAt = const Value.absent(),
		this.updatedAt = const Value.absent(),
		this.syncedAt = const Value.absent(),
		this.rowid = const Value.absent(),
	}) : event = Value(event),
		match = Value(match),
		team = Value(team);
	static Insertable<ScoutData> custom({
		Expression<String>? event,
		Expression<String>? match,
		Expression<String>? team,
		Expression<String>? startingPosition,
		Expression<bool>? noShow,
		Expression<int>? autoFuelAlliance,
		Expression<int>? autoFuelNeutral,
		Expression<int>? autoFuelOpponent,
		Expression<int>? autoFuelDepot,
		Expression<int>? autoFuelOutpost,
		Expression<int>? autoClimbLevel,
		Expression<int>? autoTrenchDepotAllianceToNeutral,
		Expression<int>? autoBumpDepotAllianceToNeutral,
		Expression<int>? autoBumpOutpostAllianceToNeutral,
		Expression<int>? autoTrenchOutpostAllianceToNeutral,
		Expression<int>? autoTrenchDepotNeutralToAlliance,
		Expression<int>? autoBumpDepotNeutralToAlliance,
		Expression<int>? autoBumpOutpostNeutralToAlliance,
		Expression<int>? autoTrenchOutpostNeutralToAlliance,
		Expression<int>? autoFuelScore,
		Expression<int>? autoFuelNeutralAlliancePass,
		Expression<bool>? autoCollectOutpost,
		Expression<bool>? autoCollectDepot,
		Expression<int>? autoAllianceTime,
		Expression<int>? autoNeutralTime,
		Expression<String>? autoTimelineEvents,
		Expression<int>? teleopFuelAlliance,
		Expression<int>? teleopFuelNeutral,
		Expression<int>? teleopFuelOpponent,
		Expression<int>? teleopClimbLevel,
		Expression<int>? teleopAlliancePasses,
		Expression<int>? teleopOpponentPasses,
		Expression<String>? teleopZoneInteractions,
		Expression<String>? climbPosition,
		Expression<String>? climbMethod,
		Expression<bool>? shootOnMove,
		Expression<bool>? shootWhileCollecting,
		Expression<bool>? climbing,
		Expression<String>? fuelStrategy,
		Expression<String>? shootingLocations,
		Expression<int>? damageState,
		Expression<String>? defenseRating,
		Expression<String>? defenseMethods,
		Expression<String>? defenseImpact,
		Expression<int>? shootingMissesRange,
		Expression<String>? scouterName,
		Expression<String>? comments,
		Expression<bool>? reviewRequest,
		Expression<bool>? synced,
		Expression<DateTime>? createdAt,
		Expression<DateTime>? updatedAt,
		Expression<DateTime>? syncedAt,
		Expression<int>? rowid,
	}) {
		return RawValuesInsertable({
			if (event != null) 'event': event,
			if (match != null) 'match': match,
			if (team != null) 'team': team,
			if (startingPosition != null) 'starting_position': startingPosition,
			if (noShow != null) 'no_show': noShow,
			if (autoFuelAlliance != null) 'auto_fuel_alliance': autoFuelAlliance,
			if (autoFuelNeutral != null) 'auto_fuel_neutral': autoFuelNeutral,
			if (autoFuelOpponent != null) 'auto_fuel_opponent': autoFuelOpponent,
			if (autoFuelDepot != null) 'auto_fuel_depot': autoFuelDepot,
			if (autoFuelOutpost != null) 'auto_fuel_outpost': autoFuelOutpost,
			if (autoClimbLevel != null) 'auto_climb_level': autoClimbLevel,
			if (autoTrenchDepotAllianceToNeutral != null)
				'auto_trench_depot_alliance_to_neutral':
						autoTrenchDepotAllianceToNeutral,
			if (autoBumpDepotAllianceToNeutral != null)
				'auto_bump_depot_alliance_to_neutral': autoBumpDepotAllianceToNeutral,
			if (autoBumpOutpostAllianceToNeutral != null)
				'auto_bump_outpost_alliance_to_neutral':
						autoBumpOutpostAllianceToNeutral,
			if (autoTrenchOutpostAllianceToNeutral != null)
				'auto_trench_outpost_alliance_to_neutral':
						autoTrenchOutpostAllianceToNeutral,
			if (autoTrenchDepotNeutralToAlliance != null)
				'auto_trench_depot_neutral_to_alliance':
						autoTrenchDepotNeutralToAlliance,
			if (autoBumpDepotNeutralToAlliance != null)
				'auto_bump_depot_neutral_to_alliance': autoBumpDepotNeutralToAlliance,
			if (autoBumpOutpostNeutralToAlliance != null)
				'auto_bump_outpost_neutral_to_alliance':
						autoBumpOutpostNeutralToAlliance,
			if (autoTrenchOutpostNeutralToAlliance != null)
				'auto_trench_outpost_neutral_to_alliance':
						autoTrenchOutpostNeutralToAlliance,
			if (autoFuelScore != null) 'auto_fuel_score': autoFuelScore,
			if (autoFuelNeutralAlliancePass != null)
				'auto_fuel_neutral_alliance_pass': autoFuelNeutralAlliancePass,
			if (autoCollectOutpost != null)
				'auto_collect_outpost': autoCollectOutpost,
			if (autoCollectDepot != null) 'auto_collect_depot': autoCollectDepot,
			if (autoAllianceTime != null) 'auto_alliance_time': autoAllianceTime,
			if (autoNeutralTime != null) 'auto_neutral_time': autoNeutralTime,
			if (autoTimelineEvents != null)
				'auto_timeline_events': autoTimelineEvents,
			if (teleopFuelAlliance != null)
				'teleop_fuel_alliance': teleopFuelAlliance,
			if (teleopFuelNeutral != null) 'teleop_fuel_neutral': teleopFuelNeutral,
			if (teleopFuelOpponent != null)
				'teleop_fuel_opponent': teleopFuelOpponent,
			if (teleopClimbLevel != null) 'teleop_climb_level': teleopClimbLevel,
			if (teleopAlliancePasses != null)
				'teleop_alliance_passes': teleopAlliancePasses,
			if (teleopOpponentPasses != null)
				'teleop_opponent_passes': teleopOpponentPasses,
			if (teleopZoneInteractions != null)
				'teleop_zone_interactions': teleopZoneInteractions,
			if (climbPosition != null) 'climb_position': climbPosition,
			if (climbMethod != null) 'climb_method': climbMethod,
			if (shootOnMove != null) 'shoot_on_move': shootOnMove,
			if (shootWhileCollecting != null)
				'shoot_while_collecting': shootWhileCollecting,
			if (climbing != null) 'climbing': climbing,
			if (fuelStrategy != null) 'fuel_strategy': fuelStrategy,
			if (shootingLocations != null) 'shooting_locations': shootingLocations,
			if (damageState != null) 'damage_state': damageState,
			if (defenseRating != null) 'defense_rating': defenseRating,
			if (defenseMethods != null) 'defense_methods': defenseMethods,
			if (defenseImpact != null) 'defense_impact': defenseImpact,
			if (shootingMissesRange != null)
				'shooting_misses_range': shootingMissesRange,
			if (scouterName != null) 'scouter_name': scouterName,
			if (comments != null) 'comments': comments,
			if (reviewRequest != null) 'review_request': reviewRequest,
			if (synced != null) 'synced': synced,
			if (createdAt != null) 'created_at': createdAt,
			if (updatedAt != null) 'updated_at': updatedAt,
			if (syncedAt != null) 'synced_at': syncedAt,
			if (rowid != null) 'rowid': rowid,
		});
	}

	ScoutCompanion copyWith({
		Value<String>? event,
		Value<String>? match,
		Value<String>? team,
		Value<String?>? startingPosition,
		Value<bool>? noShow,
		Value<int?>? autoFuelAlliance,
		Value<int?>? autoFuelNeutral,
		Value<int?>? autoFuelOpponent,
		Value<int?>? autoFuelDepot,
		Value<int?>? autoFuelOutpost,
		Value<int?>? autoClimbLevel,
		Value<int>? autoTrenchDepotAllianceToNeutral,
		Value<int>? autoBumpDepotAllianceToNeutral,
		Value<int>? autoBumpOutpostAllianceToNeutral,
		Value<int>? autoTrenchOutpostAllianceToNeutral,
		Value<int>? autoTrenchDepotNeutralToAlliance,
		Value<int>? autoBumpDepotNeutralToAlliance,
		Value<int>? autoBumpOutpostNeutralToAlliance,
		Value<int>? autoTrenchOutpostNeutralToAlliance,
		Value<int>? autoFuelScore,
		Value<int>? autoFuelNeutralAlliancePass,
		Value<bool>? autoCollectOutpost,
		Value<bool>? autoCollectDepot,
		Value<int>? autoAllianceTime,
		Value<int>? autoNeutralTime,
		Value<String?>? autoTimelineEvents,
		Value<int?>? teleopFuelAlliance,
		Value<int?>? teleopFuelNeutral,
		Value<int?>? teleopFuelOpponent,
		Value<int?>? teleopClimbLevel,
		Value<int?>? teleopAlliancePasses,
		Value<int?>? teleopOpponentPasses,
		Value<String?>? teleopZoneInteractions,
		Value<String?>? climbPosition,
		Value<String?>? climbMethod,
		Value<bool>? shootOnMove,
		Value<bool>? shootWhileCollecting,
		Value<bool>? climbing,
		Value<String?>? fuelStrategy,
		Value<String?>? shootingLocations,
		Value<int?>? damageState,
		Value<String?>? defenseRating,
		Value<String?>? defenseMethods,
		Value<String?>? defenseImpact,
		Value<int?>? shootingMissesRange,
		Value<String?>? scouterName,
		Value<String?>? comments,
		Value<bool>? reviewRequest,
		Value<bool>? synced,
		Value<DateTime>? createdAt,
		Value<DateTime>? updatedAt,
		Value<DateTime?>? syncedAt,
		Value<int>? rowid,
	}) {
		return ScoutCompanion(
			event: event ?? this.event,
			match: match ?? this.match,
			team: team ?? this.team,
			startingPosition: startingPosition ?? this.startingPosition,
			noShow: noShow ?? this.noShow,
			autoFuelAlliance: autoFuelAlliance ?? this.autoFuelAlliance,
			autoFuelNeutral: autoFuelNeutral ?? this.autoFuelNeutral,
			autoFuelOpponent: autoFuelOpponent ?? this.autoFuelOpponent,
			autoFuelDepot: autoFuelDepot ?? this.autoFuelDepot,
			autoFuelOutpost: autoFuelOutpost ?? this.autoFuelOutpost,
			autoClimbLevel: autoClimbLevel ?? this.autoClimbLevel,
			autoTrenchDepotAllianceToNeutral:
					autoTrenchDepotAllianceToNeutral ??
					this.autoTrenchDepotAllianceToNeutral,
			autoBumpDepotAllianceToNeutral:
					autoBumpDepotAllianceToNeutral ?? this.autoBumpDepotAllianceToNeutral,
			autoBumpOutpostAllianceToNeutral:
					autoBumpOutpostAllianceToNeutral ??
					this.autoBumpOutpostAllianceToNeutral,
			autoTrenchOutpostAllianceToNeutral:
					autoTrenchOutpostAllianceToNeutral ??
					this.autoTrenchOutpostAllianceToNeutral,
			autoTrenchDepotNeutralToAlliance:
					autoTrenchDepotNeutralToAlliance ??
					this.autoTrenchDepotNeutralToAlliance,
			autoBumpDepotNeutralToAlliance:
					autoBumpDepotNeutralToAlliance ?? this.autoBumpDepotNeutralToAlliance,
			autoBumpOutpostNeutralToAlliance:
					autoBumpOutpostNeutralToAlliance ??
					this.autoBumpOutpostNeutralToAlliance,
			autoTrenchOutpostNeutralToAlliance:
					autoTrenchOutpostNeutralToAlliance ??
					this.autoTrenchOutpostNeutralToAlliance,
			autoFuelScore: autoFuelScore ?? this.autoFuelScore,
			autoFuelNeutralAlliancePass:
					autoFuelNeutralAlliancePass ?? this.autoFuelNeutralAlliancePass,
			autoCollectOutpost: autoCollectOutpost ?? this.autoCollectOutpost,
			autoCollectDepot: autoCollectDepot ?? this.autoCollectDepot,
			autoAllianceTime: autoAllianceTime ?? this.autoAllianceTime,
			autoNeutralTime: autoNeutralTime ?? this.autoNeutralTime,
			autoTimelineEvents: autoTimelineEvents ?? this.autoTimelineEvents,
			teleopFuelAlliance: teleopFuelAlliance ?? this.teleopFuelAlliance,
			teleopFuelNeutral: teleopFuelNeutral ?? this.teleopFuelNeutral,
			teleopFuelOpponent: teleopFuelOpponent ?? this.teleopFuelOpponent,
			teleopClimbLevel: teleopClimbLevel ?? this.teleopClimbLevel,
			teleopAlliancePasses: teleopAlliancePasses ?? this.teleopAlliancePasses,
			teleopOpponentPasses: teleopOpponentPasses ?? this.teleopOpponentPasses,
			teleopZoneInteractions:
					teleopZoneInteractions ?? this.teleopZoneInteractions,
			climbPosition: climbPosition ?? this.climbPosition,
			climbMethod: climbMethod ?? this.climbMethod,
			shootOnMove: shootOnMove ?? this.shootOnMove,
			shootWhileCollecting: shootWhileCollecting ?? this.shootWhileCollecting,
			climbing: climbing ?? this.climbing,
			fuelStrategy: fuelStrategy ?? this.fuelStrategy,
			shootingLocations: shootingLocations ?? this.shootingLocations,
			damageState: damageState ?? this.damageState,
			defenseRating: defenseRating ?? this.defenseRating,
			defenseMethods: defenseMethods ?? this.defenseMethods,
			defenseImpact: defenseImpact ?? this.defenseImpact,
			shootingMissesRange: shootingMissesRange ?? this.shootingMissesRange,
			scouterName: scouterName ?? this.scouterName,
			comments: comments ?? this.comments,
			reviewRequest: reviewRequest ?? this.reviewRequest,
			synced: synced ?? this.synced,
			createdAt: createdAt ?? this.createdAt,
			updatedAt: updatedAt ?? this.updatedAt,
			syncedAt: syncedAt ?? this.syncedAt,
			rowid: rowid ?? this.rowid,
		);
	}

	@override
	Map<String, Expression> toColumns(bool nullToAbsent) {
		final map = <String, Expression>{};
		if (event.present) {
			map['event'] = Variable<String>(event.value);
		}
		if (match.present) {
			map['match'] = Variable<String>(match.value);
		}
		if (team.present) {
			map['team'] = Variable<String>(team.value);
		}
		if (startingPosition.present) {
			map['starting_position'] = Variable<String>(startingPosition.value);
		}
		if (noShow.present) {
			map['no_show'] = Variable<bool>(noShow.value);
		}
		if (autoFuelAlliance.present) {
			map['auto_fuel_alliance'] = Variable<int>(autoFuelAlliance.value);
		}
		if (autoFuelNeutral.present) {
			map['auto_fuel_neutral'] = Variable<int>(autoFuelNeutral.value);
		}
		if (autoFuelOpponent.present) {
			map['auto_fuel_opponent'] = Variable<int>(autoFuelOpponent.value);
		}
		if (autoFuelDepot.present) {
			map['auto_fuel_depot'] = Variable<int>(autoFuelDepot.value);
		}
		if (autoFuelOutpost.present) {
			map['auto_fuel_outpost'] = Variable<int>(autoFuelOutpost.value);
		}
		if (autoClimbLevel.present) {
			map['auto_climb_level'] = Variable<int>(autoClimbLevel.value);
		}
		if (autoTrenchDepotAllianceToNeutral.present) {
			map['auto_trench_depot_alliance_to_neutral'] = Variable<int>(
				autoTrenchDepotAllianceToNeutral.value,
			);
		}
		if (autoBumpDepotAllianceToNeutral.present) {
			map['auto_bump_depot_alliance_to_neutral'] = Variable<int>(
				autoBumpDepotAllianceToNeutral.value,
			);
		}
		if (autoBumpOutpostAllianceToNeutral.present) {
			map['auto_bump_outpost_alliance_to_neutral'] = Variable<int>(
				autoBumpOutpostAllianceToNeutral.value,
			);
		}
		if (autoTrenchOutpostAllianceToNeutral.present) {
			map['auto_trench_outpost_alliance_to_neutral'] = Variable<int>(
				autoTrenchOutpostAllianceToNeutral.value,
			);
		}
		if (autoTrenchDepotNeutralToAlliance.present) {
			map['auto_trench_depot_neutral_to_alliance'] = Variable<int>(
				autoTrenchDepotNeutralToAlliance.value,
			);
		}
		if (autoBumpDepotNeutralToAlliance.present) {
			map['auto_bump_depot_neutral_to_alliance'] = Variable<int>(
				autoBumpDepotNeutralToAlliance.value,
			);
		}
		if (autoBumpOutpostNeutralToAlliance.present) {
			map['auto_bump_outpost_neutral_to_alliance'] = Variable<int>(
				autoBumpOutpostNeutralToAlliance.value,
			);
		}
		if (autoTrenchOutpostNeutralToAlliance.present) {
			map['auto_trench_outpost_neutral_to_alliance'] = Variable<int>(
				autoTrenchOutpostNeutralToAlliance.value,
			);
		}
		if (autoFuelScore.present) {
			map['auto_fuel_score'] = Variable<int>(autoFuelScore.value);
		}
		if (autoFuelNeutralAlliancePass.present) {
			map['auto_fuel_neutral_alliance_pass'] = Variable<int>(
				autoFuelNeutralAlliancePass.value,
			);
		}
		if (autoCollectOutpost.present) {
			map['auto_collect_outpost'] = Variable<bool>(autoCollectOutpost.value);
		}
		if (autoCollectDepot.present) {
			map['auto_collect_depot'] = Variable<bool>(autoCollectDepot.value);
		}
		if (autoAllianceTime.present) {
			map['auto_alliance_time'] = Variable<int>(autoAllianceTime.value);
		}
		if (autoNeutralTime.present) {
			map['auto_neutral_time'] = Variable<int>(autoNeutralTime.value);
		}
		if (autoTimelineEvents.present) {
			map['auto_timeline_events'] = Variable<String>(autoTimelineEvents.value);
		}
		if (teleopFuelAlliance.present) {
			map['teleop_fuel_alliance'] = Variable<int>(teleopFuelAlliance.value);
		}
		if (teleopFuelNeutral.present) {
			map['teleop_fuel_neutral'] = Variable<int>(teleopFuelNeutral.value);
		}
		if (teleopFuelOpponent.present) {
			map['teleop_fuel_opponent'] = Variable<int>(teleopFuelOpponent.value);
		}
		if (teleopClimbLevel.present) {
			map['teleop_climb_level'] = Variable<int>(teleopClimbLevel.value);
		}
		if (teleopAlliancePasses.present) {
			map['teleop_alliance_passes'] = Variable<int>(teleopAlliancePasses.value);
		}
		if (teleopOpponentPasses.present) {
			map['teleop_opponent_passes'] = Variable<int>(teleopOpponentPasses.value);
		}
		if (teleopZoneInteractions.present) {
			map['teleop_zone_interactions'] = Variable<String>(
				teleopZoneInteractions.value,
			);
		}
		if (climbPosition.present) {
			map['climb_position'] = Variable<String>(climbPosition.value);
		}
		if (climbMethod.present) {
			map['climb_method'] = Variable<String>(climbMethod.value);
		}
		if (shootOnMove.present) {
			map['shoot_on_move'] = Variable<bool>(shootOnMove.value);
		}
		if (shootWhileCollecting.present) {
			map['shoot_while_collecting'] = Variable<bool>(
				shootWhileCollecting.value,
			);
		}
		if (climbing.present) {
			map['climbing'] = Variable<bool>(climbing.value);
		}
		if (fuelStrategy.present) {
			map['fuel_strategy'] = Variable<String>(fuelStrategy.value);
		}
		if (shootingLocations.present) {
			map['shooting_locations'] = Variable<String>(shootingLocations.value);
		}
		if (damageState.present) {
			map['damage_state'] = Variable<int>(damageState.value);
		}
		if (defenseRating.present) {
			map['defense_rating'] = Variable<String>(defenseRating.value);
		}
		if (defenseMethods.present) {
			map['defense_methods'] = Variable<String>(defenseMethods.value);
		}
		if (defenseImpact.present) {
			map['defense_impact'] = Variable<String>(defenseImpact.value);
		}
		if (shootingMissesRange.present) {
			map['shooting_misses_range'] = Variable<int>(shootingMissesRange.value);
		}
		if (scouterName.present) {
			map['scouter_name'] = Variable<String>(scouterName.value);
		}
		if (comments.present) {
			map['comments'] = Variable<String>(comments.value);
		}
		if (reviewRequest.present) {
			map['review_request'] = Variable<bool>(reviewRequest.value);
		}
		if (synced.present) {
			map['synced'] = Variable<bool>(synced.value);
		}
		if (createdAt.present) {
			map['created_at'] = Variable<DateTime>(createdAt.value);
		}
		if (updatedAt.present) {
			map['updated_at'] = Variable<DateTime>(updatedAt.value);
		}
		if (syncedAt.present) {
			map['synced_at'] = Variable<DateTime>(syncedAt.value);
		}
		if (rowid.present) {
			map['rowid'] = Variable<int>(rowid.value);
		}
		return map;
	}

	@override
	String toString() {
		return (StringBuffer('ScoutCompanion(')
					..write('event: $event, ')
					..write('match: $match, ')
					..write('team: $team, ')
					..write('startingPosition: $startingPosition, ')
					..write('noShow: $noShow, ')
					..write('autoFuelAlliance: $autoFuelAlliance, ')
					..write('autoFuelNeutral: $autoFuelNeutral, ')
					..write('autoFuelOpponent: $autoFuelOpponent, ')
					..write('autoFuelDepot: $autoFuelDepot, ')
					..write('autoFuelOutpost: $autoFuelOutpost, ')
					..write('autoClimbLevel: $autoClimbLevel, ')
					..write(
						'autoTrenchDepotAllianceToNeutral: $autoTrenchDepotAllianceToNeutral, ',
					)
					..write(
						'autoBumpDepotAllianceToNeutral: $autoBumpDepotAllianceToNeutral, ',
					)
					..write(
						'autoBumpOutpostAllianceToNeutral: $autoBumpOutpostAllianceToNeutral, ',
					)
					..write(
						'autoTrenchOutpostAllianceToNeutral: $autoTrenchOutpostAllianceToNeutral, ',
					)
					..write(
						'autoTrenchDepotNeutralToAlliance: $autoTrenchDepotNeutralToAlliance, ',
					)
					..write(
						'autoBumpDepotNeutralToAlliance: $autoBumpDepotNeutralToAlliance, ',
					)
					..write(
						'autoBumpOutpostNeutralToAlliance: $autoBumpOutpostNeutralToAlliance, ',
					)
					..write(
						'autoTrenchOutpostNeutralToAlliance: $autoTrenchOutpostNeutralToAlliance, ',
					)
					..write('autoFuelScore: $autoFuelScore, ')
					..write('autoFuelNeutralAlliancePass: $autoFuelNeutralAlliancePass, ')
					..write('autoCollectOutpost: $autoCollectOutpost, ')
					..write('autoCollectDepot: $autoCollectDepot, ')
					..write('autoAllianceTime: $autoAllianceTime, ')
					..write('autoNeutralTime: $autoNeutralTime, ')
					..write('autoTimelineEvents: $autoTimelineEvents, ')
					..write('teleopFuelAlliance: $teleopFuelAlliance, ')
					..write('teleopFuelNeutral: $teleopFuelNeutral, ')
					..write('teleopFuelOpponent: $teleopFuelOpponent, ')
					..write('teleopClimbLevel: $teleopClimbLevel, ')
					..write('teleopAlliancePasses: $teleopAlliancePasses, ')
					..write('teleopOpponentPasses: $teleopOpponentPasses, ')
					..write('teleopZoneInteractions: $teleopZoneInteractions, ')
					..write('climbPosition: $climbPosition, ')
					..write('climbMethod: $climbMethod, ')
					..write('shootOnMove: $shootOnMove, ')
					..write('shootWhileCollecting: $shootWhileCollecting, ')
					..write('climbing: $climbing, ')
					..write('fuelStrategy: $fuelStrategy, ')
					..write('shootingLocations: $shootingLocations, ')
					..write('damageState: $damageState, ')
					..write('defenseRating: $defenseRating, ')
					..write('defenseMethods: $defenseMethods, ')
					..write('defenseImpact: $defenseImpact, ')
					..write('shootingMissesRange: $shootingMissesRange, ')
					..write('scouterName: $scouterName, ')
					..write('comments: $comments, ')
					..write('reviewRequest: $reviewRequest, ')
					..write('synced: $synced, ')
					..write('createdAt: $createdAt, ')
					..write('updatedAt: $updatedAt, ')
					..write('syncedAt: $syncedAt, ')
					..write('rowid: $rowid')
					..write(')'))
				.toString();
	}
}

abstract class _$ScoutDatabase extends GeneratedDatabase {
	_$ScoutDatabase(QueryExecutor e) : super(e);
	$ScoutDatabaseManager get managers => $ScoutDatabaseManager(this);
	late final $ServerConfigTable serverConfig = $ServerConfigTable(this);
	late final $EventTable event = $EventTable(this);
	late final $ScoutTable scout = $ScoutTable(this);
	@override
	Iterable<TableInfo<Table, Object?>> get allTables =>
			allSchemaEntities.whereType<TableInfo<Table, Object?>>();
	@override
	List<DatabaseSchemaEntity> get allSchemaEntities => [
		serverConfig,
		event,
		scout,
	];
}

typedef $$ServerConfigTableCreateCompanionBuilder =
		ServerConfigCompanion Function({
			Value<int> id,
			required String backendUrl,
			Value<String?> username,
			Value<String?> password,
			Value<String?> selectedEventId,
			Value<String?> selectedTeam,
			Value<String?> scouterName,
			Value<DateTime?> lastEventChangeDate,
		});
typedef $$ServerConfigTableUpdateCompanionBuilder =
		ServerConfigCompanion Function({
			Value<int> id,
			Value<String> backendUrl,
			Value<String?> username,
			Value<String?> password,
			Value<String?> selectedEventId,
			Value<String?> selectedTeam,
			Value<String?> scouterName,
			Value<DateTime?> lastEventChangeDate,
		});

class $$ServerConfigTableFilterComposer
		extends Composer<_$ScoutDatabase, $ServerConfigTable> {
	$$ServerConfigTableFilterComposer({
		required super.$db,
		required super.$table,
		super.joinBuilder,
		super.$addJoinBuilderToRootComposer,
		super.$removeJoinBuilderFromRootComposer,
	});
	ColumnFilters<int> get id => $composableBuilder(
		column: $table.id,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get backendUrl => $composableBuilder(
		column: $table.backendUrl,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get username => $composableBuilder(
		column: $table.username,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get password => $composableBuilder(
		column: $table.password,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get selectedEventId => $composableBuilder(
		column: $table.selectedEventId,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get selectedTeam => $composableBuilder(
		column: $table.selectedTeam,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get scouterName => $composableBuilder(
		column: $table.scouterName,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<DateTime> get lastEventChangeDate => $composableBuilder(
		column: $table.lastEventChangeDate,
		builder: (column) => ColumnFilters(column),
	);
}

class $$ServerConfigTableOrderingComposer
		extends Composer<_$ScoutDatabase, $ServerConfigTable> {
	$$ServerConfigTableOrderingComposer({
		required super.$db,
		required super.$table,
		super.joinBuilder,
		super.$addJoinBuilderToRootComposer,
		super.$removeJoinBuilderFromRootComposer,
	});
	ColumnOrderings<int> get id => $composableBuilder(
		column: $table.id,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get backendUrl => $composableBuilder(
		column: $table.backendUrl,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get username => $composableBuilder(
		column: $table.username,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get password => $composableBuilder(
		column: $table.password,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get selectedEventId => $composableBuilder(
		column: $table.selectedEventId,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get selectedTeam => $composableBuilder(
		column: $table.selectedTeam,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get scouterName => $composableBuilder(
		column: $table.scouterName,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<DateTime> get lastEventChangeDate => $composableBuilder(
		column: $table.lastEventChangeDate,
		builder: (column) => ColumnOrderings(column),
	);
}

class $$ServerConfigTableAnnotationComposer
		extends Composer<_$ScoutDatabase, $ServerConfigTable> {
	$$ServerConfigTableAnnotationComposer({
		required super.$db,
		required super.$table,
		super.joinBuilder,
		super.$addJoinBuilderToRootComposer,
		super.$removeJoinBuilderFromRootComposer,
	});
	GeneratedColumn<int> get id =>
			$composableBuilder(column: $table.id, builder: (column) => column);

	GeneratedColumn<String> get backendUrl => $composableBuilder(
		column: $table.backendUrl,
		builder: (column) => column,
	);

	GeneratedColumn<String> get username =>
			$composableBuilder(column: $table.username, builder: (column) => column);

	GeneratedColumn<String> get password =>
			$composableBuilder(column: $table.password, builder: (column) => column);

	GeneratedColumn<String> get selectedEventId => $composableBuilder(
		column: $table.selectedEventId,
		builder: (column) => column,
	);

	GeneratedColumn<String> get selectedTeam => $composableBuilder(
		column: $table.selectedTeam,
		builder: (column) => column,
	);

	GeneratedColumn<String> get scouterName => $composableBuilder(
		column: $table.scouterName,
		builder: (column) => column,
	);

	GeneratedColumn<DateTime> get lastEventChangeDate => $composableBuilder(
		column: $table.lastEventChangeDate,
		builder: (column) => column,
	);
}

class $$ServerConfigTableTableManager
		extends
				RootTableManager<
					_$ScoutDatabase,
					$ServerConfigTable,
					ServerConfigData,
					$$ServerConfigTableFilterComposer,
					$$ServerConfigTableOrderingComposer,
					$$ServerConfigTableAnnotationComposer,
					$$ServerConfigTableCreateCompanionBuilder,
					$$ServerConfigTableUpdateCompanionBuilder,
					(
						ServerConfigData,
						BaseReferences<
							_$ScoutDatabase,
							$ServerConfigTable,
							ServerConfigData
						>,
					),
					ServerConfigData,
					PrefetchHooks Function()
				> {
	$$ServerConfigTableTableManager(_$ScoutDatabase db, $ServerConfigTable table)
		: super(
				TableManagerState(
					db: db,
					table: table,
					createFilteringComposer: () =>
							$$ServerConfigTableFilterComposer($db: db, $table: table),
					createOrderingComposer: () =>
							$$ServerConfigTableOrderingComposer($db: db, $table: table),
					createComputedFieldComposer: () =>
							$$ServerConfigTableAnnotationComposer($db: db, $table: table),
					updateCompanionCallback:
							({
								Value<int> id = const Value.absent(),
								Value<String> backendUrl = const Value.absent(),
								Value<String?> username = const Value.absent(),
								Value<String?> password = const Value.absent(),
								Value<String?> selectedEventId = const Value.absent(),
								Value<String?> selectedTeam = const Value.absent(),
								Value<String?> scouterName = const Value.absent(),
								Value<DateTime?> lastEventChangeDate = const Value.absent(),
							}) => ServerConfigCompanion(
								id: id,
								backendUrl: backendUrl,
								username: username,
								password: password,
								selectedEventId: selectedEventId,
								selectedTeam: selectedTeam,
								scouterName: scouterName,
								lastEventChangeDate: lastEventChangeDate,
							),
					createCompanionCallback:
							({
								Value<int> id = const Value.absent(),
								required String backendUrl,
								Value<String?> username = const Value.absent(),
								Value<String?> password = const Value.absent(),
								Value<String?> selectedEventId = const Value.absent(),
								Value<String?> selectedTeam = const Value.absent(),
								Value<String?> scouterName = const Value.absent(),
								Value<DateTime?> lastEventChangeDate = const Value.absent(),
							}) => ServerConfigCompanion.insert(
								id: id,
								backendUrl: backendUrl,
								username: username,
								password: password,
								selectedEventId: selectedEventId,
								selectedTeam: selectedTeam,
								scouterName: scouterName,
								lastEventChangeDate: lastEventChangeDate,
							),
					withReferenceMapper: (p0) => p0
							.map((e) => (e.readTable(table), BaseReferences(db, table, e)))
							.toList(),
					prefetchHooksCallback: null,
				),
			);
}

typedef $$ServerConfigTableProcessedTableManager =
		ProcessedTableManager<
			_$ScoutDatabase,
			$ServerConfigTable,
			ServerConfigData,
			$$ServerConfigTableFilterComposer,
			$$ServerConfigTableOrderingComposer,
			$$ServerConfigTableAnnotationComposer,
			$$ServerConfigTableCreateCompanionBuilder,
			$$ServerConfigTableUpdateCompanionBuilder,
			(
				ServerConfigData,
				BaseReferences<_$ScoutDatabase, $ServerConfigTable, ServerConfigData>,
			),
			ServerConfigData,
			PrefetchHooks Function()
		>;
typedef $$EventTableCreateCompanionBuilder =
		EventCompanion Function({
			required String eventId,
			required String name,
			Value<String?> location,
			Value<DateTime?> startDate,
			Value<DateTime?> endDate,
			Value<int> rowid,
		});
typedef $$EventTableUpdateCompanionBuilder =
		EventCompanion Function({
			Value<String> eventId,
			Value<String> name,
			Value<String?> location,
			Value<DateTime?> startDate,
			Value<DateTime?> endDate,
			Value<int> rowid,
		});

class $$EventTableFilterComposer
		extends Composer<_$ScoutDatabase, $EventTable> {
	$$EventTableFilterComposer({
		required super.$db,
		required super.$table,
		super.joinBuilder,
		super.$addJoinBuilderToRootComposer,
		super.$removeJoinBuilderFromRootComposer,
	});
	ColumnFilters<String> get eventId => $composableBuilder(
		column: $table.eventId,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get name => $composableBuilder(
		column: $table.name,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get location => $composableBuilder(
		column: $table.location,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<DateTime> get startDate => $composableBuilder(
		column: $table.startDate,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<DateTime> get endDate => $composableBuilder(
		column: $table.endDate,
		builder: (column) => ColumnFilters(column),
	);
}

class $$EventTableOrderingComposer
		extends Composer<_$ScoutDatabase, $EventTable> {
	$$EventTableOrderingComposer({
		required super.$db,
		required super.$table,
		super.joinBuilder,
		super.$addJoinBuilderToRootComposer,
		super.$removeJoinBuilderFromRootComposer,
	});
	ColumnOrderings<String> get eventId => $composableBuilder(
		column: $table.eventId,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get name => $composableBuilder(
		column: $table.name,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get location => $composableBuilder(
		column: $table.location,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<DateTime> get startDate => $composableBuilder(
		column: $table.startDate,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<DateTime> get endDate => $composableBuilder(
		column: $table.endDate,
		builder: (column) => ColumnOrderings(column),
	);
}

class $$EventTableAnnotationComposer
		extends Composer<_$ScoutDatabase, $EventTable> {
	$$EventTableAnnotationComposer({
		required super.$db,
		required super.$table,
		super.joinBuilder,
		super.$addJoinBuilderToRootComposer,
		super.$removeJoinBuilderFromRootComposer,
	});
	GeneratedColumn<String> get eventId =>
			$composableBuilder(column: $table.eventId, builder: (column) => column);

	GeneratedColumn<String> get name =>
			$composableBuilder(column: $table.name, builder: (column) => column);

	GeneratedColumn<String> get location =>
			$composableBuilder(column: $table.location, builder: (column) => column);

	GeneratedColumn<DateTime> get startDate =>
			$composableBuilder(column: $table.startDate, builder: (column) => column);

	GeneratedColumn<DateTime> get endDate =>
			$composableBuilder(column: $table.endDate, builder: (column) => column);
}

class $$EventTableTableManager
		extends
				RootTableManager<
					_$ScoutDatabase,
					$EventTable,
					EventData,
					$$EventTableFilterComposer,
					$$EventTableOrderingComposer,
					$$EventTableAnnotationComposer,
					$$EventTableCreateCompanionBuilder,
					$$EventTableUpdateCompanionBuilder,
					(EventData, BaseReferences<_$ScoutDatabase, $EventTable, EventData>),
					EventData,
					PrefetchHooks Function()
				> {
	$$EventTableTableManager(_$ScoutDatabase db, $EventTable table)
		: super(
				TableManagerState(
					db: db,
					table: table,
					createFilteringComposer: () =>
							$$EventTableFilterComposer($db: db, $table: table),
					createOrderingComposer: () =>
							$$EventTableOrderingComposer($db: db, $table: table),
					createComputedFieldComposer: () =>
							$$EventTableAnnotationComposer($db: db, $table: table),
					updateCompanionCallback:
							({
								Value<String> eventId = const Value.absent(),
								Value<String> name = const Value.absent(),
								Value<String?> location = const Value.absent(),
								Value<DateTime?> startDate = const Value.absent(),
								Value<DateTime?> endDate = const Value.absent(),
								Value<int> rowid = const Value.absent(),
							}) => EventCompanion(
								eventId: eventId,
								name: name,
								location: location,
								startDate: startDate,
								endDate: endDate,
								rowid: rowid,
							),
					createCompanionCallback:
							({
								required String eventId,
								required String name,
								Value<String?> location = const Value.absent(),
								Value<DateTime?> startDate = const Value.absent(),
								Value<DateTime?> endDate = const Value.absent(),
								Value<int> rowid = const Value.absent(),
							}) => EventCompanion.insert(
								eventId: eventId,
								name: name,
								location: location,
								startDate: startDate,
								endDate: endDate,
								rowid: rowid,
							),
					withReferenceMapper: (p0) => p0
							.map((e) => (e.readTable(table), BaseReferences(db, table, e)))
							.toList(),
					prefetchHooksCallback: null,
				),
			);
}

typedef $$EventTableProcessedTableManager =
		ProcessedTableManager<
			_$ScoutDatabase,
			$EventTable,
			EventData,
			$$EventTableFilterComposer,
			$$EventTableOrderingComposer,
			$$EventTableAnnotationComposer,
			$$EventTableCreateCompanionBuilder,
			$$EventTableUpdateCompanionBuilder,
			(EventData, BaseReferences<_$ScoutDatabase, $EventTable, EventData>),
			EventData,
			PrefetchHooks Function()
		>;
typedef $$ScoutTableCreateCompanionBuilder =
		ScoutCompanion Function({
			required String event,
			required String match,
			required String team,
			Value<String?> startingPosition,
			Value<bool> noShow,
			Value<int?> autoFuelAlliance,
			Value<int?> autoFuelNeutral,
			Value<int?> autoFuelOpponent,
			Value<int?> autoFuelDepot,
			Value<int?> autoFuelOutpost,
			Value<int?> autoClimbLevel,
			Value<int> autoTrenchDepotAllianceToNeutral,
			Value<int> autoBumpDepotAllianceToNeutral,
			Value<int> autoBumpOutpostAllianceToNeutral,
			Value<int> autoTrenchOutpostAllianceToNeutral,
			Value<int> autoTrenchDepotNeutralToAlliance,
			Value<int> autoBumpDepotNeutralToAlliance,
			Value<int> autoBumpOutpostNeutralToAlliance,
			Value<int> autoTrenchOutpostNeutralToAlliance,
			Value<int> autoFuelScore,
			Value<int> autoFuelNeutralAlliancePass,
			Value<bool> autoCollectOutpost,
			Value<bool> autoCollectDepot,
			Value<int> autoAllianceTime,
			Value<int> autoNeutralTime,
			Value<String?> autoTimelineEvents,
			Value<int?> teleopFuelAlliance,
			Value<int?> teleopFuelNeutral,
			Value<int?> teleopFuelOpponent,
			Value<int?> teleopClimbLevel,
			Value<int?> teleopAlliancePasses,
			Value<int?> teleopOpponentPasses,
			Value<String?> teleopZoneInteractions,
			Value<String?> climbPosition,
			Value<String?> climbMethod,
			Value<bool> shootOnMove,
			Value<bool> shootWhileCollecting,
			Value<bool> climbing,
			Value<String?> fuelStrategy,
			Value<String?> shootingLocations,
			Value<int?> damageState,
			Value<String?> defenseRating,
			Value<String?> defenseMethods,
			Value<String?> defenseImpact,
			Value<int?> shootingMissesRange,
			Value<String?> scouterName,
			Value<String?> comments,
			Value<bool> reviewRequest,
			Value<bool> synced,
			Value<DateTime> createdAt,
			Value<DateTime> updatedAt,
			Value<DateTime?> syncedAt,
			Value<int> rowid,
		});
typedef $$ScoutTableUpdateCompanionBuilder =
		ScoutCompanion Function({
			Value<String> event,
			Value<String> match,
			Value<String> team,
			Value<String?> startingPosition,
			Value<bool> noShow,
			Value<int?> autoFuelAlliance,
			Value<int?> autoFuelNeutral,
			Value<int?> autoFuelOpponent,
			Value<int?> autoFuelDepot,
			Value<int?> autoFuelOutpost,
			Value<int?> autoClimbLevel,
			Value<int> autoTrenchDepotAllianceToNeutral,
			Value<int> autoBumpDepotAllianceToNeutral,
			Value<int> autoBumpOutpostAllianceToNeutral,
			Value<int> autoTrenchOutpostAllianceToNeutral,
			Value<int> autoTrenchDepotNeutralToAlliance,
			Value<int> autoBumpDepotNeutralToAlliance,
			Value<int> autoBumpOutpostNeutralToAlliance,
			Value<int> autoTrenchOutpostNeutralToAlliance,
			Value<int> autoFuelScore,
			Value<int> autoFuelNeutralAlliancePass,
			Value<bool> autoCollectOutpost,
			Value<bool> autoCollectDepot,
			Value<int> autoAllianceTime,
			Value<int> autoNeutralTime,
			Value<String?> autoTimelineEvents,
			Value<int?> teleopFuelAlliance,
			Value<int?> teleopFuelNeutral,
			Value<int?> teleopFuelOpponent,
			Value<int?> teleopClimbLevel,
			Value<int?> teleopAlliancePasses,
			Value<int?> teleopOpponentPasses,
			Value<String?> teleopZoneInteractions,
			Value<String?> climbPosition,
			Value<String?> climbMethod,
			Value<bool> shootOnMove,
			Value<bool> shootWhileCollecting,
			Value<bool> climbing,
			Value<String?> fuelStrategy,
			Value<String?> shootingLocations,
			Value<int?> damageState,
			Value<String?> defenseRating,
			Value<String?> defenseMethods,
			Value<String?> defenseImpact,
			Value<int?> shootingMissesRange,
			Value<String?> scouterName,
			Value<String?> comments,
			Value<bool> reviewRequest,
			Value<bool> synced,
			Value<DateTime> createdAt,
			Value<DateTime> updatedAt,
			Value<DateTime?> syncedAt,
			Value<int> rowid,
		});

class $$ScoutTableFilterComposer
		extends Composer<_$ScoutDatabase, $ScoutTable> {
	$$ScoutTableFilterComposer({
		required super.$db,
		required super.$table,
		super.joinBuilder,
		super.$addJoinBuilderToRootComposer,
		super.$removeJoinBuilderFromRootComposer,
	});
	ColumnFilters<String> get event => $composableBuilder(
		column: $table.event,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get match => $composableBuilder(
		column: $table.match,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get team => $composableBuilder(
		column: $table.team,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get startingPosition => $composableBuilder(
		column: $table.startingPosition,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<bool> get noShow => $composableBuilder(
		column: $table.noShow,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoFuelAlliance => $composableBuilder(
		column: $table.autoFuelAlliance,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoFuelNeutral => $composableBuilder(
		column: $table.autoFuelNeutral,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoFuelOpponent => $composableBuilder(
		column: $table.autoFuelOpponent,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoFuelDepot => $composableBuilder(
		column: $table.autoFuelDepot,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoFuelOutpost => $composableBuilder(
		column: $table.autoFuelOutpost,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoClimbLevel => $composableBuilder(
		column: $table.autoClimbLevel,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoTrenchDepotAllianceToNeutral => $composableBuilder(
		column: $table.autoTrenchDepotAllianceToNeutral,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoBumpDepotAllianceToNeutral => $composableBuilder(
		column: $table.autoBumpDepotAllianceToNeutral,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoBumpOutpostAllianceToNeutral => $composableBuilder(
		column: $table.autoBumpOutpostAllianceToNeutral,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoTrenchOutpostAllianceToNeutral =>
			$composableBuilder(
				column: $table.autoTrenchOutpostAllianceToNeutral,
				builder: (column) => ColumnFilters(column),
			);

	ColumnFilters<int> get autoTrenchDepotNeutralToAlliance => $composableBuilder(
		column: $table.autoTrenchDepotNeutralToAlliance,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoBumpDepotNeutralToAlliance => $composableBuilder(
		column: $table.autoBumpDepotNeutralToAlliance,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoBumpOutpostNeutralToAlliance => $composableBuilder(
		column: $table.autoBumpOutpostNeutralToAlliance,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoTrenchOutpostNeutralToAlliance =>
			$composableBuilder(
				column: $table.autoTrenchOutpostNeutralToAlliance,
				builder: (column) => ColumnFilters(column),
			);

	ColumnFilters<int> get autoFuelScore => $composableBuilder(
		column: $table.autoFuelScore,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoFuelNeutralAlliancePass => $composableBuilder(
		column: $table.autoFuelNeutralAlliancePass,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<bool> get autoCollectOutpost => $composableBuilder(
		column: $table.autoCollectOutpost,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<bool> get autoCollectDepot => $composableBuilder(
		column: $table.autoCollectDepot,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoAllianceTime => $composableBuilder(
		column: $table.autoAllianceTime,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get autoNeutralTime => $composableBuilder(
		column: $table.autoNeutralTime,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get autoTimelineEvents => $composableBuilder(
		column: $table.autoTimelineEvents,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get teleopFuelAlliance => $composableBuilder(
		column: $table.teleopFuelAlliance,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get teleopFuelNeutral => $composableBuilder(
		column: $table.teleopFuelNeutral,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get teleopFuelOpponent => $composableBuilder(
		column: $table.teleopFuelOpponent,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get teleopClimbLevel => $composableBuilder(
		column: $table.teleopClimbLevel,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get teleopAlliancePasses => $composableBuilder(
		column: $table.teleopAlliancePasses,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get teleopOpponentPasses => $composableBuilder(
		column: $table.teleopOpponentPasses,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get teleopZoneInteractions => $composableBuilder(
		column: $table.teleopZoneInteractions,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get climbPosition => $composableBuilder(
		column: $table.climbPosition,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get climbMethod => $composableBuilder(
		column: $table.climbMethod,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<bool> get shootOnMove => $composableBuilder(
		column: $table.shootOnMove,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<bool> get shootWhileCollecting => $composableBuilder(
		column: $table.shootWhileCollecting,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<bool> get climbing => $composableBuilder(
		column: $table.climbing,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get fuelStrategy => $composableBuilder(
		column: $table.fuelStrategy,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get shootingLocations => $composableBuilder(
		column: $table.shootingLocations,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get damageState => $composableBuilder(
		column: $table.damageState,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get defenseRating => $composableBuilder(
		column: $table.defenseRating,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get defenseMethods => $composableBuilder(
		column: $table.defenseMethods,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get defenseImpact => $composableBuilder(
		column: $table.defenseImpact,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<int> get shootingMissesRange => $composableBuilder(
		column: $table.shootingMissesRange,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get scouterName => $composableBuilder(
		column: $table.scouterName,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<String> get comments => $composableBuilder(
		column: $table.comments,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<bool> get reviewRequest => $composableBuilder(
		column: $table.reviewRequest,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<bool> get synced => $composableBuilder(
		column: $table.synced,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<DateTime> get createdAt => $composableBuilder(
		column: $table.createdAt,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<DateTime> get updatedAt => $composableBuilder(
		column: $table.updatedAt,
		builder: (column) => ColumnFilters(column),
	);

	ColumnFilters<DateTime> get syncedAt => $composableBuilder(
		column: $table.syncedAt,
		builder: (column) => ColumnFilters(column),
	);
}

class $$ScoutTableOrderingComposer
		extends Composer<_$ScoutDatabase, $ScoutTable> {
	$$ScoutTableOrderingComposer({
		required super.$db,
		required super.$table,
		super.joinBuilder,
		super.$addJoinBuilderToRootComposer,
		super.$removeJoinBuilderFromRootComposer,
	});
	ColumnOrderings<String> get event => $composableBuilder(
		column: $table.event,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get match => $composableBuilder(
		column: $table.match,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get team => $composableBuilder(
		column: $table.team,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get startingPosition => $composableBuilder(
		column: $table.startingPosition,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<bool> get noShow => $composableBuilder(
		column: $table.noShow,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get autoFuelAlliance => $composableBuilder(
		column: $table.autoFuelAlliance,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get autoFuelNeutral => $composableBuilder(
		column: $table.autoFuelNeutral,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get autoFuelOpponent => $composableBuilder(
		column: $table.autoFuelOpponent,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get autoFuelDepot => $composableBuilder(
		column: $table.autoFuelDepot,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get autoFuelOutpost => $composableBuilder(
		column: $table.autoFuelOutpost,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get autoClimbLevel => $composableBuilder(
		column: $table.autoClimbLevel,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get autoTrenchDepotAllianceToNeutral =>
			$composableBuilder(
				column: $table.autoTrenchDepotAllianceToNeutral,
				builder: (column) => ColumnOrderings(column),
			);

	ColumnOrderings<int> get autoBumpDepotAllianceToNeutral => $composableBuilder(
		column: $table.autoBumpDepotAllianceToNeutral,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get autoBumpOutpostAllianceToNeutral =>
			$composableBuilder(
				column: $table.autoBumpOutpostAllianceToNeutral,
				builder: (column) => ColumnOrderings(column),
			);

	ColumnOrderings<int> get autoTrenchOutpostAllianceToNeutral =>
			$composableBuilder(
				column: $table.autoTrenchOutpostAllianceToNeutral,
				builder: (column) => ColumnOrderings(column),
			);

	ColumnOrderings<int> get autoTrenchDepotNeutralToAlliance =>
			$composableBuilder(
				column: $table.autoTrenchDepotNeutralToAlliance,
				builder: (column) => ColumnOrderings(column),
			);

	ColumnOrderings<int> get autoBumpDepotNeutralToAlliance => $composableBuilder(
		column: $table.autoBumpDepotNeutralToAlliance,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get autoBumpOutpostNeutralToAlliance =>
			$composableBuilder(
				column: $table.autoBumpOutpostNeutralToAlliance,
				builder: (column) => ColumnOrderings(column),
			);

	ColumnOrderings<int> get autoTrenchOutpostNeutralToAlliance =>
			$composableBuilder(
				column: $table.autoTrenchOutpostNeutralToAlliance,
				builder: (column) => ColumnOrderings(column),
			);

	ColumnOrderings<int> get autoFuelScore => $composableBuilder(
		column: $table.autoFuelScore,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get autoFuelNeutralAlliancePass => $composableBuilder(
		column: $table.autoFuelNeutralAlliancePass,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<bool> get autoCollectOutpost => $composableBuilder(
		column: $table.autoCollectOutpost,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<bool> get autoCollectDepot => $composableBuilder(
		column: $table.autoCollectDepot,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get autoAllianceTime => $composableBuilder(
		column: $table.autoAllianceTime,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get autoNeutralTime => $composableBuilder(
		column: $table.autoNeutralTime,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get autoTimelineEvents => $composableBuilder(
		column: $table.autoTimelineEvents,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get teleopFuelAlliance => $composableBuilder(
		column: $table.teleopFuelAlliance,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get teleopFuelNeutral => $composableBuilder(
		column: $table.teleopFuelNeutral,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get teleopFuelOpponent => $composableBuilder(
		column: $table.teleopFuelOpponent,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get teleopClimbLevel => $composableBuilder(
		column: $table.teleopClimbLevel,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get teleopAlliancePasses => $composableBuilder(
		column: $table.teleopAlliancePasses,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get teleopOpponentPasses => $composableBuilder(
		column: $table.teleopOpponentPasses,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get teleopZoneInteractions => $composableBuilder(
		column: $table.teleopZoneInteractions,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get climbPosition => $composableBuilder(
		column: $table.climbPosition,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get climbMethod => $composableBuilder(
		column: $table.climbMethod,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<bool> get shootOnMove => $composableBuilder(
		column: $table.shootOnMove,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<bool> get shootWhileCollecting => $composableBuilder(
		column: $table.shootWhileCollecting,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<bool> get climbing => $composableBuilder(
		column: $table.climbing,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get fuelStrategy => $composableBuilder(
		column: $table.fuelStrategy,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get shootingLocations => $composableBuilder(
		column: $table.shootingLocations,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get damageState => $composableBuilder(
		column: $table.damageState,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get defenseRating => $composableBuilder(
		column: $table.defenseRating,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get defenseMethods => $composableBuilder(
		column: $table.defenseMethods,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get defenseImpact => $composableBuilder(
		column: $table.defenseImpact,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<int> get shootingMissesRange => $composableBuilder(
		column: $table.shootingMissesRange,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get scouterName => $composableBuilder(
		column: $table.scouterName,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<String> get comments => $composableBuilder(
		column: $table.comments,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<bool> get reviewRequest => $composableBuilder(
		column: $table.reviewRequest,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<bool> get synced => $composableBuilder(
		column: $table.synced,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<DateTime> get createdAt => $composableBuilder(
		column: $table.createdAt,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
		column: $table.updatedAt,
		builder: (column) => ColumnOrderings(column),
	);

	ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
		column: $table.syncedAt,
		builder: (column) => ColumnOrderings(column),
	);
}

class $$ScoutTableAnnotationComposer
		extends Composer<_$ScoutDatabase, $ScoutTable> {
	$$ScoutTableAnnotationComposer({
		required super.$db,
		required super.$table,
		super.joinBuilder,
		super.$addJoinBuilderToRootComposer,
		super.$removeJoinBuilderFromRootComposer,
	});
	GeneratedColumn<String> get event =>
			$composableBuilder(column: $table.event, builder: (column) => column);

	GeneratedColumn<String> get match =>
			$composableBuilder(column: $table.match, builder: (column) => column);

	GeneratedColumn<String> get team =>
			$composableBuilder(column: $table.team, builder: (column) => column);

	GeneratedColumn<String> get startingPosition => $composableBuilder(
		column: $table.startingPosition,
		builder: (column) => column,
	);

	GeneratedColumn<bool> get noShow =>
			$composableBuilder(column: $table.noShow, builder: (column) => column);

	GeneratedColumn<int> get autoFuelAlliance => $composableBuilder(
		column: $table.autoFuelAlliance,
		builder: (column) => column,
	);

	GeneratedColumn<int> get autoFuelNeutral => $composableBuilder(
		column: $table.autoFuelNeutral,
		builder: (column) => column,
	);

	GeneratedColumn<int> get autoFuelOpponent => $composableBuilder(
		column: $table.autoFuelOpponent,
		builder: (column) => column,
	);

	GeneratedColumn<int> get autoFuelDepot => $composableBuilder(
		column: $table.autoFuelDepot,
		builder: (column) => column,
	);

	GeneratedColumn<int> get autoFuelOutpost => $composableBuilder(
		column: $table.autoFuelOutpost,
		builder: (column) => column,
	);

	GeneratedColumn<int> get autoClimbLevel => $composableBuilder(
		column: $table.autoClimbLevel,
		builder: (column) => column,
	);

	GeneratedColumn<int> get autoTrenchDepotAllianceToNeutral =>
			$composableBuilder(
				column: $table.autoTrenchDepotAllianceToNeutral,
				builder: (column) => column,
			);

	GeneratedColumn<int> get autoBumpDepotAllianceToNeutral => $composableBuilder(
		column: $table.autoBumpDepotAllianceToNeutral,
		builder: (column) => column,
	);

	GeneratedColumn<int> get autoBumpOutpostAllianceToNeutral =>
			$composableBuilder(
				column: $table.autoBumpOutpostAllianceToNeutral,
				builder: (column) => column,
			);

	GeneratedColumn<int> get autoTrenchOutpostAllianceToNeutral =>
			$composableBuilder(
				column: $table.autoTrenchOutpostAllianceToNeutral,
				builder: (column) => column,
			);

	GeneratedColumn<int> get autoTrenchDepotNeutralToAlliance =>
			$composableBuilder(
				column: $table.autoTrenchDepotNeutralToAlliance,
				builder: (column) => column,
			);

	GeneratedColumn<int> get autoBumpDepotNeutralToAlliance => $composableBuilder(
		column: $table.autoBumpDepotNeutralToAlliance,
		builder: (column) => column,
	);

	GeneratedColumn<int> get autoBumpOutpostNeutralToAlliance =>
			$composableBuilder(
				column: $table.autoBumpOutpostNeutralToAlliance,
				builder: (column) => column,
			);

	GeneratedColumn<int> get autoTrenchOutpostNeutralToAlliance =>
			$composableBuilder(
				column: $table.autoTrenchOutpostNeutralToAlliance,
				builder: (column) => column,
			);

	GeneratedColumn<int> get autoFuelScore => $composableBuilder(
		column: $table.autoFuelScore,
		builder: (column) => column,
	);

	GeneratedColumn<int> get autoFuelNeutralAlliancePass => $composableBuilder(
		column: $table.autoFuelNeutralAlliancePass,
		builder: (column) => column,
	);

	GeneratedColumn<bool> get autoCollectOutpost => $composableBuilder(
		column: $table.autoCollectOutpost,
		builder: (column) => column,
	);

	GeneratedColumn<bool> get autoCollectDepot => $composableBuilder(
		column: $table.autoCollectDepot,
		builder: (column) => column,
	);

	GeneratedColumn<int> get autoAllianceTime => $composableBuilder(
		column: $table.autoAllianceTime,
		builder: (column) => column,
	);

	GeneratedColumn<int> get autoNeutralTime => $composableBuilder(
		column: $table.autoNeutralTime,
		builder: (column) => column,
	);

	GeneratedColumn<String> get autoTimelineEvents => $composableBuilder(
		column: $table.autoTimelineEvents,
		builder: (column) => column,
	);

	GeneratedColumn<int> get teleopFuelAlliance => $composableBuilder(
		column: $table.teleopFuelAlliance,
		builder: (column) => column,
	);

	GeneratedColumn<int> get teleopFuelNeutral => $composableBuilder(
		column: $table.teleopFuelNeutral,
		builder: (column) => column,
	);

	GeneratedColumn<int> get teleopFuelOpponent => $composableBuilder(
		column: $table.teleopFuelOpponent,
		builder: (column) => column,
	);

	GeneratedColumn<int> get teleopClimbLevel => $composableBuilder(
		column: $table.teleopClimbLevel,
		builder: (column) => column,
	);

	GeneratedColumn<int> get teleopAlliancePasses => $composableBuilder(
		column: $table.teleopAlliancePasses,
		builder: (column) => column,
	);

	GeneratedColumn<int> get teleopOpponentPasses => $composableBuilder(
		column: $table.teleopOpponentPasses,
		builder: (column) => column,
	);

	GeneratedColumn<String> get teleopZoneInteractions => $composableBuilder(
		column: $table.teleopZoneInteractions,
		builder: (column) => column,
	);

	GeneratedColumn<String> get climbPosition => $composableBuilder(
		column: $table.climbPosition,
		builder: (column) => column,
	);

	GeneratedColumn<String> get climbMethod => $composableBuilder(
		column: $table.climbMethod,
		builder: (column) => column,
	);

	GeneratedColumn<bool> get shootOnMove => $composableBuilder(
		column: $table.shootOnMove,
		builder: (column) => column,
	);

	GeneratedColumn<bool> get shootWhileCollecting => $composableBuilder(
		column: $table.shootWhileCollecting,
		builder: (column) => column,
	);

	GeneratedColumn<bool> get climbing =>
			$composableBuilder(column: $table.climbing, builder: (column) => column);

	GeneratedColumn<String> get fuelStrategy => $composableBuilder(
		column: $table.fuelStrategy,
		builder: (column) => column,
	);

	GeneratedColumn<String> get shootingLocations => $composableBuilder(
		column: $table.shootingLocations,
		builder: (column) => column,
	);

	GeneratedColumn<int> get damageState => $composableBuilder(
		column: $table.damageState,
		builder: (column) => column,
	);

	GeneratedColumn<String> get defenseRating => $composableBuilder(
		column: $table.defenseRating,
		builder: (column) => column,
	);

	GeneratedColumn<String> get defenseMethods => $composableBuilder(
		column: $table.defenseMethods,
		builder: (column) => column,
	);

	GeneratedColumn<String> get defenseImpact => $composableBuilder(
		column: $table.defenseImpact,
		builder: (column) => column,
	);

	GeneratedColumn<int> get shootingMissesRange => $composableBuilder(
		column: $table.shootingMissesRange,
		builder: (column) => column,
	);

	GeneratedColumn<String> get scouterName => $composableBuilder(
		column: $table.scouterName,
		builder: (column) => column,
	);

	GeneratedColumn<String> get comments =>
			$composableBuilder(column: $table.comments, builder: (column) => column);

	GeneratedColumn<bool> get reviewRequest => $composableBuilder(
		column: $table.reviewRequest,
		builder: (column) => column,
	);

	GeneratedColumn<bool> get synced =>
			$composableBuilder(column: $table.synced, builder: (column) => column);

	GeneratedColumn<DateTime> get createdAt =>
			$composableBuilder(column: $table.createdAt, builder: (column) => column);

	GeneratedColumn<DateTime> get updatedAt =>
			$composableBuilder(column: $table.updatedAt, builder: (column) => column);

	GeneratedColumn<DateTime> get syncedAt =>
			$composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ScoutTableTableManager
		extends
				RootTableManager<
					_$ScoutDatabase,
					$ScoutTable,
					ScoutData,
					$$ScoutTableFilterComposer,
					$$ScoutTableOrderingComposer,
					$$ScoutTableAnnotationComposer,
					$$ScoutTableCreateCompanionBuilder,
					$$ScoutTableUpdateCompanionBuilder,
					(ScoutData, BaseReferences<_$ScoutDatabase, $ScoutTable, ScoutData>),
					ScoutData,
					PrefetchHooks Function()
				> {
	$$ScoutTableTableManager(_$ScoutDatabase db, $ScoutTable table)
		: super(
				TableManagerState(
					db: db,
					table: table,
					createFilteringComposer: () =>
							$$ScoutTableFilterComposer($db: db, $table: table),
					createOrderingComposer: () =>
							$$ScoutTableOrderingComposer($db: db, $table: table),
					createComputedFieldComposer: () =>
							$$ScoutTableAnnotationComposer($db: db, $table: table),
					updateCompanionCallback:
							({
								Value<String> event = const Value.absent(),
								Value<String> match = const Value.absent(),
								Value<String> team = const Value.absent(),
								Value<String?> startingPosition = const Value.absent(),
								Value<bool> noShow = const Value.absent(),
								Value<int?> autoFuelAlliance = const Value.absent(),
								Value<int?> autoFuelNeutral = const Value.absent(),
								Value<int?> autoFuelOpponent = const Value.absent(),
								Value<int?> autoFuelDepot = const Value.absent(),
								Value<int?> autoFuelOutpost = const Value.absent(),
								Value<int?> autoClimbLevel = const Value.absent(),
								Value<int> autoTrenchDepotAllianceToNeutral =
										const Value.absent(),
								Value<int> autoBumpDepotAllianceToNeutral =
										const Value.absent(),
								Value<int> autoBumpOutpostAllianceToNeutral =
										const Value.absent(),
								Value<int> autoTrenchOutpostAllianceToNeutral =
										const Value.absent(),
								Value<int> autoTrenchDepotNeutralToAlliance =
										const Value.absent(),
								Value<int> autoBumpDepotNeutralToAlliance =
										const Value.absent(),
								Value<int> autoBumpOutpostNeutralToAlliance =
										const Value.absent(),
								Value<int> autoTrenchOutpostNeutralToAlliance =
										const Value.absent(),
								Value<int> autoFuelScore = const Value.absent(),
								Value<int> autoFuelNeutralAlliancePass = const Value.absent(),
								Value<bool> autoCollectOutpost = const Value.absent(),
								Value<bool> autoCollectDepot = const Value.absent(),
								Value<int> autoAllianceTime = const Value.absent(),
								Value<int> autoNeutralTime = const Value.absent(),
								Value<String?> autoTimelineEvents = const Value.absent(),
								Value<int?> teleopFuelAlliance = const Value.absent(),
								Value<int?> teleopFuelNeutral = const Value.absent(),
								Value<int?> teleopFuelOpponent = const Value.absent(),
								Value<int?> teleopClimbLevel = const Value.absent(),
								Value<int?> teleopAlliancePasses = const Value.absent(),
								Value<int?> teleopOpponentPasses = const Value.absent(),
								Value<String?> teleopZoneInteractions = const Value.absent(),
								Value<String?> climbPosition = const Value.absent(),
								Value<String?> climbMethod = const Value.absent(),
								Value<bool> shootOnMove = const Value.absent(),
								Value<bool> shootWhileCollecting = const Value.absent(),
								Value<bool> climbing = const Value.absent(),
								Value<String?> fuelStrategy = const Value.absent(),
								Value<String?> shootingLocations = const Value.absent(),
								Value<int?> damageState = const Value.absent(),
								Value<String?> defenseRating = const Value.absent(),
								Value<String?> defenseMethods = const Value.absent(),
								Value<String?> defenseImpact = const Value.absent(),
								Value<int?> shootingMissesRange = const Value.absent(),
								Value<String?> scouterName = const Value.absent(),
								Value<String?> comments = const Value.absent(),
								Value<bool> reviewRequest = const Value.absent(),
								Value<bool> synced = const Value.absent(),
								Value<DateTime> createdAt = const Value.absent(),
								Value<DateTime> updatedAt = const Value.absent(),
								Value<DateTime?> syncedAt = const Value.absent(),
								Value<int> rowid = const Value.absent(),
							}) => ScoutCompanion(
								event: event,
								match: match,
								team: team,
								startingPosition: startingPosition,
								noShow: noShow,
								autoFuelAlliance: autoFuelAlliance,
								autoFuelNeutral: autoFuelNeutral,
								autoFuelOpponent: autoFuelOpponent,
								autoFuelDepot: autoFuelDepot,
								autoFuelOutpost: autoFuelOutpost,
								autoClimbLevel: autoClimbLevel,
								autoTrenchDepotAllianceToNeutral:
										autoTrenchDepotAllianceToNeutral,
								autoBumpDepotAllianceToNeutral: autoBumpDepotAllianceToNeutral,
								autoBumpOutpostAllianceToNeutral:
										autoBumpOutpostAllianceToNeutral,
								autoTrenchOutpostAllianceToNeutral:
										autoTrenchOutpostAllianceToNeutral,
								autoTrenchDepotNeutralToAlliance:
										autoTrenchDepotNeutralToAlliance,
								autoBumpDepotNeutralToAlliance: autoBumpDepotNeutralToAlliance,
								autoBumpOutpostNeutralToAlliance:
										autoBumpOutpostNeutralToAlliance,
								autoTrenchOutpostNeutralToAlliance:
										autoTrenchOutpostNeutralToAlliance,
								autoFuelScore: autoFuelScore,
								autoFuelNeutralAlliancePass: autoFuelNeutralAlliancePass,
								autoCollectOutpost: autoCollectOutpost,
								autoCollectDepot: autoCollectDepot,
								autoAllianceTime: autoAllianceTime,
								autoNeutralTime: autoNeutralTime,
								autoTimelineEvents: autoTimelineEvents,
								teleopFuelAlliance: teleopFuelAlliance,
								teleopFuelNeutral: teleopFuelNeutral,
								teleopFuelOpponent: teleopFuelOpponent,
								teleopClimbLevel: teleopClimbLevel,
								teleopAlliancePasses: teleopAlliancePasses,
								teleopOpponentPasses: teleopOpponentPasses,
								teleopZoneInteractions: teleopZoneInteractions,
								climbPosition: climbPosition,
								climbMethod: climbMethod,
								shootOnMove: shootOnMove,
								shootWhileCollecting: shootWhileCollecting,
								climbing: climbing,
								fuelStrategy: fuelStrategy,
								shootingLocations: shootingLocations,
								damageState: damageState,
								defenseRating: defenseRating,
								defenseMethods: defenseMethods,
								defenseImpact: defenseImpact,
								shootingMissesRange: shootingMissesRange,
								scouterName: scouterName,
								comments: comments,
								reviewRequest: reviewRequest,
								synced: synced,
								createdAt: createdAt,
								updatedAt: updatedAt,
								syncedAt: syncedAt,
								rowid: rowid,
							),
					createCompanionCallback:
							({
								required String event,
								required String match,
								required String team,
								Value<String?> startingPosition = const Value.absent(),
								Value<bool> noShow = const Value.absent(),
								Value<int?> autoFuelAlliance = const Value.absent(),
								Value<int?> autoFuelNeutral = const Value.absent(),
								Value<int?> autoFuelOpponent = const Value.absent(),
								Value<int?> autoFuelDepot = const Value.absent(),
								Value<int?> autoFuelOutpost = const Value.absent(),
								Value<int?> autoClimbLevel = const Value.absent(),
								Value<int> autoTrenchDepotAllianceToNeutral =
										const Value.absent(),
								Value<int> autoBumpDepotAllianceToNeutral =
										const Value.absent(),
								Value<int> autoBumpOutpostAllianceToNeutral =
										const Value.absent(),
								Value<int> autoTrenchOutpostAllianceToNeutral =
										const Value.absent(),
								Value<int> autoTrenchDepotNeutralToAlliance =
										const Value.absent(),
								Value<int> autoBumpDepotNeutralToAlliance =
										const Value.absent(),
								Value<int> autoBumpOutpostNeutralToAlliance =
										const Value.absent(),
								Value<int> autoTrenchOutpostNeutralToAlliance =
										const Value.absent(),
								Value<int> autoFuelScore = const Value.absent(),
								Value<int> autoFuelNeutralAlliancePass = const Value.absent(),
								Value<bool> autoCollectOutpost = const Value.absent(),
								Value<bool> autoCollectDepot = const Value.absent(),
								Value<int> autoAllianceTime = const Value.absent(),
								Value<int> autoNeutralTime = const Value.absent(),
								Value<String?> autoTimelineEvents = const Value.absent(),
								Value<int?> teleopFuelAlliance = const Value.absent(),
								Value<int?> teleopFuelNeutral = const Value.absent(),
								Value<int?> teleopFuelOpponent = const Value.absent(),
								Value<int?> teleopClimbLevel = const Value.absent(),
								Value<int?> teleopAlliancePasses = const Value.absent(),
								Value<int?> teleopOpponentPasses = const Value.absent(),
								Value<String?> teleopZoneInteractions = const Value.absent(),
								Value<String?> climbPosition = const Value.absent(),
								Value<String?> climbMethod = const Value.absent(),
								Value<bool> shootOnMove = const Value.absent(),
								Value<bool> shootWhileCollecting = const Value.absent(),
								Value<bool> climbing = const Value.absent(),
								Value<String?> fuelStrategy = const Value.absent(),
								Value<String?> shootingLocations = const Value.absent(),
								Value<int?> damageState = const Value.absent(),
								Value<String?> defenseRating = const Value.absent(),
								Value<String?> defenseMethods = const Value.absent(),
								Value<String?> defenseImpact = const Value.absent(),
								Value<int?> shootingMissesRange = const Value.absent(),
								Value<String?> scouterName = const Value.absent(),
								Value<String?> comments = const Value.absent(),
								Value<bool> reviewRequest = const Value.absent(),
								Value<bool> synced = const Value.absent(),
								Value<DateTime> createdAt = const Value.absent(),
								Value<DateTime> updatedAt = const Value.absent(),
								Value<DateTime?> syncedAt = const Value.absent(),
								Value<int> rowid = const Value.absent(),
							}) => ScoutCompanion.insert(
								event: event,
								match: match,
								team: team,
								startingPosition: startingPosition,
								noShow: noShow,
								autoFuelAlliance: autoFuelAlliance,
								autoFuelNeutral: autoFuelNeutral,
								autoFuelOpponent: autoFuelOpponent,
								autoFuelDepot: autoFuelDepot,
								autoFuelOutpost: autoFuelOutpost,
								autoClimbLevel: autoClimbLevel,
								autoTrenchDepotAllianceToNeutral:
										autoTrenchDepotAllianceToNeutral,
								autoBumpDepotAllianceToNeutral: autoBumpDepotAllianceToNeutral,
								autoBumpOutpostAllianceToNeutral:
										autoBumpOutpostAllianceToNeutral,
								autoTrenchOutpostAllianceToNeutral:
										autoTrenchOutpostAllianceToNeutral,
								autoTrenchDepotNeutralToAlliance:
										autoTrenchDepotNeutralToAlliance,
								autoBumpDepotNeutralToAlliance: autoBumpDepotNeutralToAlliance,
								autoBumpOutpostNeutralToAlliance:
										autoBumpOutpostNeutralToAlliance,
								autoTrenchOutpostNeutralToAlliance:
										autoTrenchOutpostNeutralToAlliance,
								autoFuelScore: autoFuelScore,
								autoFuelNeutralAlliancePass: autoFuelNeutralAlliancePass,
								autoCollectOutpost: autoCollectOutpost,
								autoCollectDepot: autoCollectDepot,
								autoAllianceTime: autoAllianceTime,
								autoNeutralTime: autoNeutralTime,
								autoTimelineEvents: autoTimelineEvents,
								teleopFuelAlliance: teleopFuelAlliance,
								teleopFuelNeutral: teleopFuelNeutral,
								teleopFuelOpponent: teleopFuelOpponent,
								teleopClimbLevel: teleopClimbLevel,
								teleopAlliancePasses: teleopAlliancePasses,
								teleopOpponentPasses: teleopOpponentPasses,
								teleopZoneInteractions: teleopZoneInteractions,
								climbPosition: climbPosition,
								climbMethod: climbMethod,
								shootOnMove: shootOnMove,
								shootWhileCollecting: shootWhileCollecting,
								climbing: climbing,
								fuelStrategy: fuelStrategy,
								shootingLocations: shootingLocations,
								damageState: damageState,
								defenseRating: defenseRating,
								defenseMethods: defenseMethods,
								defenseImpact: defenseImpact,
								shootingMissesRange: shootingMissesRange,
								scouterName: scouterName,
								comments: comments,
								reviewRequest: reviewRequest,
								synced: synced,
								createdAt: createdAt,
								updatedAt: updatedAt,
								syncedAt: syncedAt,
								rowid: rowid,
							),
					withReferenceMapper: (p0) => p0
							.map((e) => (e.readTable(table), BaseReferences(db, table, e)))
							.toList(),
					prefetchHooksCallback: null,
				),
			);
}

typedef $$ScoutTableProcessedTableManager =
		ProcessedTableManager<
			_$ScoutDatabase,
			$ScoutTable,
			ScoutData,
			$$ScoutTableFilterComposer,
			$$ScoutTableOrderingComposer,
			$$ScoutTableAnnotationComposer,
			$$ScoutTableCreateCompanionBuilder,
			$$ScoutTableUpdateCompanionBuilder,
			(ScoutData, BaseReferences<_$ScoutDatabase, $ScoutTable, ScoutData>),
			ScoutData,
			PrefetchHooks Function()
		>;

class $ScoutDatabaseManager {
	final _$ScoutDatabase _db;
	$ScoutDatabaseManager(this._db);
	$$ServerConfigTableTableManager get serverConfig =>
			$$ServerConfigTableTableManager(_db, _db.serverConfig);
	$$EventTableTableManager get event =>
			$$EventTableTableManager(_db, _db.event);
	$$ScoutTableTableManager get scout =>
			$$ScoutTableTableManager(_db, _db.scout);
}
