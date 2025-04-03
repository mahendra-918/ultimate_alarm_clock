// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_home_device_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmartHomeDeviceModelCollection on Isar {
  IsarCollection<SmartHomeDeviceModel> get smartHomeDeviceModels =>
      this.collection();
}

const SmartHomeDeviceModelSchema = CollectionSchema(
  name: r'SmartHomeDeviceModel',
  id: 7979884282624980026,
  properties: {
    r'authToken': PropertySchema(
      id: 0,
      name: r'authToken',
      type: IsarType.string,
    ),
    r'configData': PropertySchema(
      id: 1,
      name: r'configData',
      type: IsarType.string,
    ),
    r'deviceId': PropertySchema(
      id: 2,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'deviceName': PropertySchema(
      id: 3,
      name: r'deviceName',
      type: IsarType.string,
    ),
    r'deviceType': PropertySchema(
      id: 4,
      name: r'deviceType',
      type: IsarType.byte,
      enumMap: _SmartHomeDeviceModeldeviceTypeEnumValueMap,
    ),
    r'ipAddress': PropertySchema(
      id: 5,
      name: r'ipAddress',
      type: IsarType.string,
    ),
    r'isConnected': PropertySchema(
      id: 6,
      name: r'isConnected',
      type: IsarType.bool,
    ),
    r'lastConnected': PropertySchema(
      id: 7,
      name: r'lastConnected',
      type: IsarType.dateTime,
    ),
    r'location': PropertySchema(
      id: 8,
      name: r'location',
      type: IsarType.string,
    ),
    r'platform': PropertySchema(
      id: 9,
      name: r'platform',
      type: IsarType.byte,
      enumMap: _SmartHomeDeviceModelplatformEnumValueMap,
    ),
    r'supportedActions': PropertySchema(
      id: 10,
      name: r'supportedActions',
      type: IsarType.longList,
    )
  },
  estimateSize: _smartHomeDeviceModelEstimateSize,
  serialize: _smartHomeDeviceModelSerialize,
  deserialize: _smartHomeDeviceModelDeserialize,
  deserializeProp: _smartHomeDeviceModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _smartHomeDeviceModelGetId,
  getLinks: _smartHomeDeviceModelGetLinks,
  attach: _smartHomeDeviceModelAttach,
  version: '3.1.0+1',
);

int _smartHomeDeviceModelEstimateSize(
  SmartHomeDeviceModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.authToken;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.configData;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.deviceName.length * 3;
  {
    final value = object.ipAddress;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.location;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.supportedActions;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  return bytesCount;
}

void _smartHomeDeviceModelSerialize(
  SmartHomeDeviceModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.authToken);
  writer.writeString(offsets[1], object.configData);
  writer.writeString(offsets[2], object.deviceId);
  writer.writeString(offsets[3], object.deviceName);
  writer.writeByte(offsets[4], object.deviceType.index);
  writer.writeString(offsets[5], object.ipAddress);
  writer.writeBool(offsets[6], object.isConnected);
  writer.writeDateTime(offsets[7], object.lastConnected);
  writer.writeString(offsets[8], object.location);
  writer.writeByte(offsets[9], object.platform.index);
  writer.writeLongList(offsets[10], object.supportedActions);
}

SmartHomeDeviceModel _smartHomeDeviceModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmartHomeDeviceModel(
    authToken: reader.readStringOrNull(offsets[0]),
    configData: reader.readStringOrNull(offsets[1]),
    deviceId: reader.readString(offsets[2]),
    deviceName: reader.readString(offsets[3]),
    deviceType: _SmartHomeDeviceModeldeviceTypeValueEnumMap[
            reader.readByteOrNull(offsets[4])] ??
        SmartDeviceType.light,
    id: id,
    ipAddress: reader.readStringOrNull(offsets[5]),
    isConnected: reader.readBool(offsets[6]),
    lastConnected: reader.readDateTime(offsets[7]),
    location: reader.readStringOrNull(offsets[8]),
    platform: _SmartHomeDeviceModelplatformValueEnumMap[
            reader.readByteOrNull(offsets[9])] ??
        SmartHomePlatform.googleHome,
    supportedActions: reader.readLongList(offsets[10]),
  );
  return object;
}

P _smartHomeDeviceModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (_SmartHomeDeviceModeldeviceTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SmartDeviceType.light) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (_SmartHomeDeviceModelplatformValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SmartHomePlatform.googleHome) as P;
    case 10:
      return (reader.readLongList(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SmartHomeDeviceModeldeviceTypeEnumValueMap = {
  'light': 0,
  'thermostat': 1,
  'speaker': 2,
  'switch_': 3,
  'outlet': 4,
  'fan': 5,
  'blind': 6,
  'other': 7,
};
const _SmartHomeDeviceModeldeviceTypeValueEnumMap = {
  0: SmartDeviceType.light,
  1: SmartDeviceType.thermostat,
  2: SmartDeviceType.speaker,
  3: SmartDeviceType.switch_,
  4: SmartDeviceType.outlet,
  5: SmartDeviceType.fan,
  6: SmartDeviceType.blind,
  7: SmartDeviceType.other,
};
const _SmartHomeDeviceModelplatformEnumValueMap = {
  'googleHome': 0,
  'appleHomeKit': 1,
  'amazonAlexa': 2,
  'smartThings': 3,
  'custom': 4,
};
const _SmartHomeDeviceModelplatformValueEnumMap = {
  0: SmartHomePlatform.googleHome,
  1: SmartHomePlatform.appleHomeKit,
  2: SmartHomePlatform.amazonAlexa,
  3: SmartHomePlatform.smartThings,
  4: SmartHomePlatform.custom,
};

Id _smartHomeDeviceModelGetId(SmartHomeDeviceModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smartHomeDeviceModelGetLinks(
    SmartHomeDeviceModel object) {
  return [];
}

void _smartHomeDeviceModelAttach(
    IsarCollection<dynamic> col, Id id, SmartHomeDeviceModel object) {
  object.id = id;
}

extension SmartHomeDeviceModelQueryWhereSort
    on QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QWhere> {
  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SmartHomeDeviceModelQueryWhere
    on QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QWhereClause> {
  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterWhereClause>
      idBetween(
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

extension SmartHomeDeviceModelQueryFilter on QueryBuilder<SmartHomeDeviceModel,
    SmartHomeDeviceModel, QFilterCondition> {
  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> authTokenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'authToken',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> authTokenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'authToken',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> authTokenEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> authTokenGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'authToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> authTokenLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'authToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> authTokenBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'authToken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> authTokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'authToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> authTokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'authToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
          QAfterFilterCondition>
      authTokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'authToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
          QAfterFilterCondition>
      authTokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'authToken',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> authTokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authToken',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> authTokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'authToken',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> configDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'configData',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> configDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'configData',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> configDataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'configData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> configDataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'configData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> configDataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'configData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> configDataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'configData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> configDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'configData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> configDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'configData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
          QAfterFilterCondition>
      configDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'configData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
          QAfterFilterCondition>
      configDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'configData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> configDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'configData',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> configDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'configData',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
          QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
          QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
          QAfterFilterCondition>
      deviceNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
          QAfterFilterCondition>
      deviceNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceName',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceName',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceTypeEqualTo(SmartDeviceType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceType',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceTypeGreaterThan(
    SmartDeviceType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceType',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceTypeLessThan(
    SmartDeviceType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceType',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> deviceTypeBetween(
    SmartDeviceType lower,
    SmartDeviceType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> ipAddressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ipAddress',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> ipAddressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ipAddress',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> ipAddressEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> ipAddressGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> ipAddressLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> ipAddressBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ipAddress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> ipAddressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> ipAddressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
          QAfterFilterCondition>
      ipAddressContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
          QAfterFilterCondition>
      ipAddressMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ipAddress',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> ipAddressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ipAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> ipAddressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ipAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> isConnectedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isConnected',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> lastConnectedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastConnected',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> lastConnectedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastConnected',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> lastConnectedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastConnected',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> lastConnectedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastConnected',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> locationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'location',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> locationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'location',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> locationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> locationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> locationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> locationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'location',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> locationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> locationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
          QAfterFilterCondition>
      locationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
          QAfterFilterCondition>
      locationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'location',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> locationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> locationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> platformEqualTo(SmartHomePlatform value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'platform',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> platformGreaterThan(
    SmartHomePlatform value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'platform',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> platformLessThan(
    SmartHomePlatform value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'platform',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> platformBetween(
    SmartHomePlatform lower,
    SmartHomePlatform upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'platform',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> supportedActionsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supportedActions',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> supportedActionsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supportedActions',
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> supportedActionsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supportedActions',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> supportedActionsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supportedActions',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> supportedActionsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supportedActions',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> supportedActionsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supportedActions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> supportedActionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supportedActions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> supportedActionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supportedActions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> supportedActionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supportedActions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> supportedActionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supportedActions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> supportedActionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supportedActions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel,
      QAfterFilterCondition> supportedActionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supportedActions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension SmartHomeDeviceModelQueryObject on QueryBuilder<SmartHomeDeviceModel,
    SmartHomeDeviceModel, QFilterCondition> {}

extension SmartHomeDeviceModelQueryLinks on QueryBuilder<SmartHomeDeviceModel,
    SmartHomeDeviceModel, QFilterCondition> {}

extension SmartHomeDeviceModelQuerySortBy
    on QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QSortBy> {
  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByAuthToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authToken', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByAuthTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authToken', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByConfigData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configData', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByConfigDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configData', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByDeviceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceType', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByDeviceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceType', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByIpAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ipAddress', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByIpAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ipAddress', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByIsConnected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isConnected', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByIsConnectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isConnected', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByLastConnected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConnected', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByLastConnectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConnected', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByPlatform() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      sortByPlatformDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.desc);
    });
  }
}

extension SmartHomeDeviceModelQuerySortThenBy
    on QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QSortThenBy> {
  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByAuthToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authToken', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByAuthTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authToken', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByConfigData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configData', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByConfigDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configData', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByDeviceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceType', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByDeviceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceType', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByIpAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ipAddress', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByIpAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ipAddress', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByIsConnected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isConnected', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByIsConnectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isConnected', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByLastConnected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConnected', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByLastConnectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConnected', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByPlatform() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QAfterSortBy>
      thenByPlatformDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.desc);
    });
  }
}

extension SmartHomeDeviceModelQueryWhereDistinct
    on QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QDistinct> {
  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QDistinct>
      distinctByAuthToken({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authToken', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QDistinct>
      distinctByConfigData({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'configData', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QDistinct>
      distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QDistinct>
      distinctByDeviceName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QDistinct>
      distinctByDeviceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceType');
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QDistinct>
      distinctByIpAddress({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ipAddress', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QDistinct>
      distinctByIsConnected() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isConnected');
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QDistinct>
      distinctByLastConnected() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastConnected');
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QDistinct>
      distinctByLocation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'location', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QDistinct>
      distinctByPlatform() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'platform');
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomeDeviceModel, QDistinct>
      distinctBySupportedActions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supportedActions');
    });
  }
}

extension SmartHomeDeviceModelQueryProperty on QueryBuilder<
    SmartHomeDeviceModel, SmartHomeDeviceModel, QQueryProperty> {
  QueryBuilder<SmartHomeDeviceModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmartHomeDeviceModel, String?, QQueryOperations>
      authTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authToken');
    });
  }

  QueryBuilder<SmartHomeDeviceModel, String?, QQueryOperations>
      configDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'configData');
    });
  }

  QueryBuilder<SmartHomeDeviceModel, String, QQueryOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<SmartHomeDeviceModel, String, QQueryOperations>
      deviceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceName');
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartDeviceType, QQueryOperations>
      deviceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceType');
    });
  }

  QueryBuilder<SmartHomeDeviceModel, String?, QQueryOperations>
      ipAddressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ipAddress');
    });
  }

  QueryBuilder<SmartHomeDeviceModel, bool, QQueryOperations>
      isConnectedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isConnected');
    });
  }

  QueryBuilder<SmartHomeDeviceModel, DateTime, QQueryOperations>
      lastConnectedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastConnected');
    });
  }

  QueryBuilder<SmartHomeDeviceModel, String?, QQueryOperations>
      locationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'location');
    });
  }

  QueryBuilder<SmartHomeDeviceModel, SmartHomePlatform, QQueryOperations>
      platformProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'platform');
    });
  }

  QueryBuilder<SmartHomeDeviceModel, List<int>?, QQueryOperations>
      supportedActionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supportedActions');
    });
  }
}
