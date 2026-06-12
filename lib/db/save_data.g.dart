// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_data.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSaveDataCollection on Isar {
  IsarCollection<SaveData> get saveDatas => this.collection();
}

const SaveDataSchema = CollectionSchema(
  name: r'SaveData',
  // WEB-FIX: original generated id 13963225654598257 exceeds JS safe-integer
  // range (2^53) and breaks dart2js. Truncated to the nearest representable
  // value. If you re-run build_runner, re-apply this fix (or keep the
  // tool/fix_web_ids.sh patch step).
  id: 13963225654598256,
  properties: {
    r'activeActivityIds': PropertySchema(
      id: 0,
      name: r'activeActivityIds',
      type: IsarType.stringList,
    ),
    r'characterName': PropertySchema(
      id: 1,
      name: r'characterName',
      type: IsarType.string,
    ),
    r'combatEnabled': PropertySchema(
      id: 2,
      name: r'combatEnabled',
      type: IsarType.bool,
    ),
    r'combatSettingsJson': PropertySchema(
      id: 3,
      name: r'combatSettingsJson',
      type: IsarType.string,
    ),
    r'currentLocationId': PropertySchema(
      id: 4,
      name: r'currentLocationId',
      type: IsarType.string,
    ),
    r'currentNodeJson': PropertySchema(
      id: 5,
      name: r'currentNodeJson',
      type: IsarType.string,
    ),
    r'enabledGatherIds': PropertySchema(
      id: 6,
      name: r'enabledGatherIds',
      type: IsarType.stringList,
    ),
    r'gearSlotsJson': PropertySchema(
      id: 7,
      name: r'gearSlotsJson',
      type: IsarType.string,
    ),
    r'gold': PropertySchema(
      id: 8,
      name: r'gold',
      type: IsarType.long,
    ),
    r'honourPoints': PropertySchema(
      id: 9,
      name: r'honourPoints',
      type: IsarType.long,
    ),
    r'inventoryJson': PropertySchema(
      id: 10,
      name: r'inventoryJson',
      type: IsarType.string,
    ),
    r'stepBank': PropertySchema(
      id: 11,
      name: r'stepBank',
      type: IsarType.long,
    ),
    r'tokenBank': PropertySchema(
      id: 12,
      name: r'tokenBank',
      type: IsarType.long,
    ),
    r'travelDestinationId': PropertySchema(
      id: 13,
      name: r'travelDestinationId',
      type: IsarType.string,
    ),
    r'travelStepsRemaining': PropertySchema(
      id: 14,
      name: r'travelStepsRemaining',
      type: IsarType.long,
    ),
    r'walkProgress': PropertySchema(
      id: 15,
      name: r'walkProgress',
      type: IsarType.long,
    ),
    r'walkToCraftActivityId': PropertySchema(
      id: 16,
      name: r'walkToCraftActivityId',
      type: IsarType.string,
    )
  },
  estimateSize: _saveDataEstimateSize,
  serialize: _saveDataSerialize,
  deserialize: _saveDataDeserialize,
  deserializeProp: _saveDataDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _saveDataGetId,
  getLinks: _saveDataGetLinks,
  attach: _saveDataAttach,
  version: '3.1.0+1',
);

int _saveDataEstimateSize(
  SaveData object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activeActivityIds.length * 3;
  {
    for (var i = 0; i < object.activeActivityIds.length; i++) {
      final value = object.activeActivityIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.characterName.length * 3;
  bytesCount += 3 + object.combatSettingsJson.length * 3;
  bytesCount += 3 + object.currentLocationId.length * 3;
  {
    final value = object.currentNodeJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.enabledGatherIds.length * 3;
  {
    for (var i = 0; i < object.enabledGatherIds.length; i++) {
      final value = object.enabledGatherIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.gearSlotsJson.length * 3;
  bytesCount += 3 + object.inventoryJson.length * 3;
  {
    final value = object.travelDestinationId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.walkToCraftActivityId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _saveDataSerialize(
  SaveData object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.activeActivityIds);
  writer.writeString(offsets[1], object.characterName);
  writer.writeBool(offsets[2], object.combatEnabled);
  writer.writeString(offsets[3], object.combatSettingsJson);
  writer.writeString(offsets[4], object.currentLocationId);
  writer.writeString(offsets[5], object.currentNodeJson);
  writer.writeStringList(offsets[6], object.enabledGatherIds);
  writer.writeString(offsets[7], object.gearSlotsJson);
  writer.writeLong(offsets[8], object.gold);
  writer.writeLong(offsets[9], object.honourPoints);
  writer.writeString(offsets[10], object.inventoryJson);
  writer.writeLong(offsets[11], object.stepBank);
  writer.writeLong(offsets[12], object.tokenBank);
  writer.writeString(offsets[13], object.travelDestinationId);
  writer.writeLong(offsets[14], object.travelStepsRemaining);
  writer.writeLong(offsets[15], object.walkProgress);
  writer.writeString(offsets[16], object.walkToCraftActivityId);
}

SaveData _saveDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SaveData();
  object.activeActivityIds = reader.readStringList(offsets[0]) ?? [];
  object.characterName = reader.readString(offsets[1]);
  object.combatEnabled = reader.readBool(offsets[2]);
  object.combatSettingsJson = reader.readString(offsets[3]);
  object.currentLocationId = reader.readString(offsets[4]);
  object.currentNodeJson = reader.readStringOrNull(offsets[5]);
  object.enabledGatherIds = reader.readStringList(offsets[6]) ?? [];
  object.gearSlotsJson = reader.readString(offsets[7]);
  object.gold = reader.readLong(offsets[8]);
  object.honourPoints = reader.readLong(offsets[9]);
  object.id = id;
  object.inventoryJson = reader.readString(offsets[10]);
  object.stepBank = reader.readLong(offsets[11]);
  object.tokenBank = reader.readLong(offsets[12]);
  object.travelDestinationId = reader.readStringOrNull(offsets[13]);
  object.travelStepsRemaining = reader.readLong(offsets[14]);
  object.walkProgress = reader.readLong(offsets[15]);
  object.walkToCraftActivityId = reader.readStringOrNull(offsets[16]);
  return object;
}

P _saveDataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _saveDataGetId(SaveData object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _saveDataGetLinks(SaveData object) {
  return [];
}

void _saveDataAttach(IsarCollection<dynamic> col, Id id, SaveData object) {
  object.id = id;
}

extension SaveDataQueryWhereSort on QueryBuilder<SaveData, SaveData, QWhere> {
  QueryBuilder<SaveData, SaveData, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SaveDataQueryWhere on QueryBuilder<SaveData, SaveData, QWhereClause> {
  QueryBuilder<SaveData, SaveData, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SaveDataQueryFilter
    on QueryBuilder<SaveData, SaveData, QFilterCondition> {
  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeActivityIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeActivityIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeActivityIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeActivityIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activeActivityIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activeActivityIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activeActivityIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activeActivityIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeActivityIds',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activeActivityIds',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activeActivityIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activeActivityIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activeActivityIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activeActivityIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activeActivityIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      activeActivityIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activeActivityIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> characterNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'characterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      characterNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'characterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> characterNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'characterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> characterNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'characterName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      characterNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'characterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> characterNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'characterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> characterNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'characterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> characterNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'characterName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      characterNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'characterName',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      characterNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'characterName',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> combatEnabledEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'combatEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      combatSettingsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'combatSettingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      combatSettingsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'combatSettingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      combatSettingsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'combatSettingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      combatSettingsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'combatSettingsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      combatSettingsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'combatSettingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      combatSettingsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'combatSettingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      combatSettingsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'combatSettingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      combatSettingsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'combatSettingsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      combatSettingsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'combatSettingsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      combatSettingsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'combatSettingsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentLocationIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentLocationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentLocationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentLocationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentLocationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentLocationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currentLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentLocationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currentLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentLocationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currentLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentLocationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currentLocationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentLocationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentLocationId',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentLocationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currentLocationId',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentNodeJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'currentNodeJson',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentNodeJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'currentNodeJson',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentNodeJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentNodeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentNodeJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentNodeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentNodeJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentNodeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentNodeJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentNodeJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentNodeJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currentNodeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentNodeJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currentNodeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentNodeJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currentNodeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentNodeJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currentNodeJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentNodeJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentNodeJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      currentNodeJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currentNodeJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabledGatherIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'enabledGatherIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'enabledGatherIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'enabledGatherIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'enabledGatherIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'enabledGatherIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'enabledGatherIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'enabledGatherIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabledGatherIds',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'enabledGatherIds',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledGatherIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledGatherIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledGatherIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledGatherIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledGatherIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      enabledGatherIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledGatherIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> gearSlotsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gearSlotsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      gearSlotsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gearSlotsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> gearSlotsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gearSlotsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> gearSlotsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gearSlotsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      gearSlotsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gearSlotsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> gearSlotsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gearSlotsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> gearSlotsJsonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gearSlotsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> gearSlotsJsonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gearSlotsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      gearSlotsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gearSlotsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      gearSlotsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gearSlotsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> goldEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gold',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> goldGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gold',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> goldLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gold',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> goldBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gold',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> honourPointsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'honourPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      honourPointsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'honourPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> honourPointsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'honourPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> honourPointsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'honourPoints',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> inventoryJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inventoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      inventoryJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'inventoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> inventoryJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'inventoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> inventoryJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'inventoryJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      inventoryJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'inventoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> inventoryJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'inventoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> inventoryJsonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'inventoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> inventoryJsonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'inventoryJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      inventoryJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inventoryJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      inventoryJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'inventoryJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> stepBankEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stepBank',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> stepBankGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stepBank',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> stepBankLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stepBank',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> stepBankBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stepBank',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> tokenBankEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tokenBank',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> tokenBankGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tokenBank',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> tokenBankLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tokenBank',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> tokenBankBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tokenBank',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelDestinationIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'travelDestinationId',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelDestinationIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'travelDestinationId',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelDestinationIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'travelDestinationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelDestinationIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'travelDestinationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelDestinationIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'travelDestinationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelDestinationIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'travelDestinationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelDestinationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'travelDestinationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelDestinationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'travelDestinationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelDestinationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'travelDestinationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelDestinationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'travelDestinationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelDestinationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'travelDestinationId',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelDestinationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'travelDestinationId',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelStepsRemainingEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'travelStepsRemaining',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelStepsRemainingGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'travelStepsRemaining',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelStepsRemainingLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'travelStepsRemaining',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      travelStepsRemainingBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'travelStepsRemaining',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> walkProgressEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'walkProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      walkProgressGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'walkProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> walkProgressLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'walkProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition> walkProgressBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'walkProgress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      walkToCraftActivityIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'walkToCraftActivityId',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      walkToCraftActivityIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'walkToCraftActivityId',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      walkToCraftActivityIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'walkToCraftActivityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      walkToCraftActivityIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'walkToCraftActivityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      walkToCraftActivityIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'walkToCraftActivityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      walkToCraftActivityIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'walkToCraftActivityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      walkToCraftActivityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'walkToCraftActivityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      walkToCraftActivityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'walkToCraftActivityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      walkToCraftActivityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'walkToCraftActivityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      walkToCraftActivityIdMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'walkToCraftActivityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      walkToCraftActivityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'walkToCraftActivityId',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterFilterCondition>
      walkToCraftActivityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'walkToCraftActivityId',
        value: '',
      ));
    });
  }
}

extension SaveDataQueryObject
    on QueryBuilder<SaveData, SaveData, QFilterCondition> {}

extension SaveDataQueryLinks
    on QueryBuilder<SaveData, SaveData, QFilterCondition> {}

extension SaveDataQuerySortBy on QueryBuilder<SaveData, SaveData, QSortBy> {
  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByCharacterName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterName', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByCharacterNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterName', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByCombatEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combatEnabled', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByCombatEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combatEnabled', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByCombatSettingsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combatSettingsJson', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy>
      sortByCombatSettingsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combatSettingsJson', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByCurrentLocationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentLocationId', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByCurrentLocationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentLocationId', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByCurrentNodeJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentNodeJson', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByCurrentNodeJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentNodeJson', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByGearSlotsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gearSlotsJson', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByGearSlotsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gearSlotsJson', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByGold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gold', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByGoldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gold', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByHonourPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'honourPoints', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByHonourPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'honourPoints', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByInventoryJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryJson', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByInventoryJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryJson', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByStepBank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepBank', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByStepBankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepBank', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByTokenBank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenBank', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByTokenBankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenBank', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByTravelDestinationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'travelDestinationId', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy>
      sortByTravelDestinationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'travelDestinationId', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByTravelStepsRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'travelStepsRemaining', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy>
      sortByTravelStepsRemainingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'travelStepsRemaining', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByWalkProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walkProgress', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByWalkProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walkProgress', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> sortByWalkToCraftActivityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walkToCraftActivityId', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy>
      sortByWalkToCraftActivityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walkToCraftActivityId', Sort.desc);
    });
  }
}

extension SaveDataQuerySortThenBy
    on QueryBuilder<SaveData, SaveData, QSortThenBy> {
  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByCharacterName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterName', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByCharacterNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterName', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByCombatEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combatEnabled', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByCombatEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combatEnabled', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByCombatSettingsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combatSettingsJson', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy>
      thenByCombatSettingsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combatSettingsJson', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByCurrentLocationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentLocationId', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByCurrentLocationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentLocationId', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByCurrentNodeJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentNodeJson', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByCurrentNodeJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentNodeJson', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByGearSlotsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gearSlotsJson', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByGearSlotsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gearSlotsJson', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByGold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gold', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByGoldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gold', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByHonourPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'honourPoints', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByHonourPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'honourPoints', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByInventoryJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryJson', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByInventoryJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryJson', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByStepBank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepBank', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByStepBankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepBank', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByTokenBank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenBank', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByTokenBankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenBank', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByTravelDestinationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'travelDestinationId', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy>
      thenByTravelDestinationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'travelDestinationId', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByTravelStepsRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'travelStepsRemaining', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy>
      thenByTravelStepsRemainingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'travelStepsRemaining', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByWalkProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walkProgress', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByWalkProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walkProgress', Sort.desc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy> thenByWalkToCraftActivityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walkToCraftActivityId', Sort.asc);
    });
  }

  QueryBuilder<SaveData, SaveData, QAfterSortBy>
      thenByWalkToCraftActivityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walkToCraftActivityId', Sort.desc);
    });
  }
}

extension SaveDataQueryWhereDistinct
    on QueryBuilder<SaveData, SaveData, QDistinct> {
  QueryBuilder<SaveData, SaveData, QDistinct> distinctByActiveActivityIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeActivityIds');
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByCharacterName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'characterName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByCombatEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'combatEnabled');
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByCombatSettingsJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'combatSettingsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByCurrentLocationId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentLocationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByCurrentNodeJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentNodeJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByEnabledGatherIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabledGatherIds');
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByGearSlotsJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gearSlotsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByGold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gold');
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByHonourPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'honourPoints');
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByInventoryJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inventoryJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByStepBank() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stepBank');
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByTokenBank() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tokenBank');
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByTravelDestinationId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'travelDestinationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByTravelStepsRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'travelStepsRemaining');
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByWalkProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'walkProgress');
    });
  }

  QueryBuilder<SaveData, SaveData, QDistinct> distinctByWalkToCraftActivityId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'walkToCraftActivityId',
          caseSensitive: caseSensitive);
    });
  }
}

extension SaveDataQueryProperty
    on QueryBuilder<SaveData, SaveData, QQueryProperty> {
  QueryBuilder<SaveData, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SaveData, List<String>, QQueryOperations>
      activeActivityIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeActivityIds');
    });
  }

  QueryBuilder<SaveData, String, QQueryOperations> characterNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'characterName');
    });
  }

  QueryBuilder<SaveData, bool, QQueryOperations> combatEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'combatEnabled');
    });
  }

  QueryBuilder<SaveData, String, QQueryOperations>
      combatSettingsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'combatSettingsJson');
    });
  }

  QueryBuilder<SaveData, String, QQueryOperations> currentLocationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentLocationId');
    });
  }

  QueryBuilder<SaveData, String?, QQueryOperations> currentNodeJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentNodeJson');
    });
  }

  QueryBuilder<SaveData, List<String>, QQueryOperations>
      enabledGatherIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabledGatherIds');
    });
  }

  QueryBuilder<SaveData, String, QQueryOperations> gearSlotsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gearSlotsJson');
    });
  }

  QueryBuilder<SaveData, int, QQueryOperations> goldProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gold');
    });
  }

  QueryBuilder<SaveData, int, QQueryOperations> honourPointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'honourPoints');
    });
  }

  QueryBuilder<SaveData, String, QQueryOperations> inventoryJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inventoryJson');
    });
  }

  QueryBuilder<SaveData, int, QQueryOperations> stepBankProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stepBank');
    });
  }

  QueryBuilder<SaveData, int, QQueryOperations> tokenBankProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tokenBank');
    });
  }

  QueryBuilder<SaveData, String?, QQueryOperations>
      travelDestinationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'travelDestinationId');
    });
  }

  QueryBuilder<SaveData, int, QQueryOperations> travelStepsRemainingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'travelStepsRemaining');
    });
  }

  QueryBuilder<SaveData, int, QQueryOperations> walkProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'walkProgress');
    });
  }

  QueryBuilder<SaveData, String?, QQueryOperations>
      walkToCraftActivityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'walkToCraftActivityId');
    });
  }
}
