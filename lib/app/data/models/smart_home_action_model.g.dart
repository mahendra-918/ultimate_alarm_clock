// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_home_action_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmartHomeActionModelCollection on Isar {
  IsarCollection<SmartHomeActionModel> get smartHomeActionModels =>
      this.collection();
}

const SmartHomeActionModelSchema = CollectionSchema(
  name: r'SmartHomeActionModel',
  id: 9191589240693650440,
  properties: {
    r'action': PropertySchema(
      id: 0,
      name: r'action',
      type: IsarType.byte,
      enumMap: _SmartHomeActionModelactionEnumValueMap,
    ),
    r'actionParameters': PropertySchema(
      id: 1,
      name: r'actionParameters',
      type: IsarType.string,
    ),
    r'alarmId': PropertySchema(
      id: 2,
      name: r'alarmId',
      type: IsarType.string,
    ),
    r'deviceId': PropertySchema(
      id: 3,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'isEnabled': PropertySchema(
      id: 4,
      name: r'isEnabled',
      type: IsarType.bool,
    ),
    r'offsetMinutes': PropertySchema(
      id: 5,
      name: r'offsetMinutes',
      type: IsarType.long,
    ),
    r'trigger': PropertySchema(
      id: 6,
      name: r'trigger',
      type: IsarType.byte,
      enumMap: _SmartHomeActionModeltriggerEnumValueMap,
    )
  },
  estimateSize: _smartHomeActionModelEstimateSize,
  serialize: _smartHomeActionModelSerialize,
  deserialize: _smartHomeActionModelDeserialize,
  deserializeProp: _smartHomeActionModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _smartHomeActionModelGetId,
  getLinks: _smartHomeActionModelGetLinks,
  attach: _smartHomeActionModelAttach,
  version: '3.1.0+1',
);

int _smartHomeActionModelEstimateSize(
  SmartHomeActionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.actionParameters;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.alarmId.length * 3;
  bytesCount += 3 + object.deviceId.length * 3;
  return bytesCount;
}

void _smartHomeActionModelSerialize(
  SmartHomeActionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.action.index);
  writer.writeString(offsets[1], object.actionParameters);
  writer.writeString(offsets[2], object.alarmId);
  writer.writeString(offsets[3], object.deviceId);
  writer.writeBool(offsets[4], object.isEnabled);
  writer.writeLong(offsets[5], object.offsetMinutes);
  writer.writeByte(offsets[6], object.trigger.index);
}

SmartHomeActionModel _smartHomeActionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmartHomeActionModel(
    action: _SmartHomeActionModelactionValueEnumMap[
            reader.readByteOrNull(offsets[0])] ??
        SmartDeviceAction.turnOn,
    actionParameters: reader.readStringOrNull(offsets[1]),
    alarmId: reader.readString(offsets[2]),
    deviceId: reader.readString(offsets[3]),
    id: id,
    isEnabled: reader.readBool(offsets[4]),
    offsetMinutes: reader.readLongOrNull(offsets[5]),
    trigger: _SmartHomeActionModeltriggerValueEnumMap[
            reader.readByteOrNull(offsets[6])] ??
        ActionTrigger.beforeAlarm,
  );
  return object;
}

P _smartHomeActionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_SmartHomeActionModelactionValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SmartDeviceAction.turnOn) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (_SmartHomeActionModeltriggerValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ActionTrigger.beforeAlarm) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SmartHomeActionModelactionEnumValueMap = {
  'turnOn': 0,
  'turnOff': 1,
  'setBrightness': 2,
  'setColor': 3,
  'setTemperature': 4,
  'playSound': 5,
  'stopSound': 6,
  'setVolume': 7,
  'open': 8,
  'close': 9,
};
const _SmartHomeActionModelactionValueEnumMap = {
  0: SmartDeviceAction.turnOn,
  1: SmartDeviceAction.turnOff,
  2: SmartDeviceAction.setBrightness,
  3: SmartDeviceAction.setColor,
  4: SmartDeviceAction.setTemperature,
  5: SmartDeviceAction.playSound,
  6: SmartDeviceAction.stopSound,
  7: SmartDeviceAction.setVolume,
  8: SmartDeviceAction.open,
  9: SmartDeviceAction.close,
};
const _SmartHomeActionModeltriggerEnumValueMap = {
  'beforeAlarm': 0,
  'duringAlarm': 1,
  'afterAlarmDismiss': 2,
  'afterAlarmSnooze': 3,
};
const _SmartHomeActionModeltriggerValueEnumMap = {
  0: ActionTrigger.beforeAlarm,
  1: ActionTrigger.duringAlarm,
  2: ActionTrigger.afterAlarmDismiss,
  3: ActionTrigger.afterAlarmSnooze,
};

Id _smartHomeActionModelGetId(SmartHomeActionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smartHomeActionModelGetLinks(
    SmartHomeActionModel object) {
  return [];
}

void _smartHomeActionModelAttach(
    IsarCollection<dynamic> col, Id id, SmartHomeActionModel object) {
  object.id = id;
}

extension SmartHomeActionModelQueryWhereSort
    on QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QWhere> {
  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SmartHomeActionModelQueryWhere
    on QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QWhereClause> {
  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterWhereClause>
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

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterWhereClause>
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

extension SmartHomeActionModelQueryFilter on QueryBuilder<SmartHomeActionModel,
    SmartHomeActionModel, QFilterCondition> {
  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> actionEqualTo(SmartDeviceAction value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'action',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> actionGreaterThan(
    SmartDeviceAction value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'action',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> actionLessThan(
    SmartDeviceAction value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'action',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> actionBetween(
    SmartDeviceAction lower,
    SmartDeviceAction upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'action',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> actionParametersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actionParameters',
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> actionParametersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actionParameters',
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> actionParametersEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionParameters',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> actionParametersGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actionParameters',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> actionParametersLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actionParameters',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> actionParametersBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actionParameters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> actionParametersStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actionParameters',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> actionParametersEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actionParameters',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
          QAfterFilterCondition>
      actionParametersContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actionParameters',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
          QAfterFilterCondition>
      actionParametersMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actionParameters',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> actionParametersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionParameters',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> actionParametersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actionParameters',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> alarmIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'alarmId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> alarmIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'alarmId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> alarmIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'alarmId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> alarmIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'alarmId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> alarmIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'alarmId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> alarmIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'alarmId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
          QAfterFilterCondition>
      alarmIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'alarmId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
          QAfterFilterCondition>
      alarmIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'alarmId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> alarmIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'alarmId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> alarmIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'alarmId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
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

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
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

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
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

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
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

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
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

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
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

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
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

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
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

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
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

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
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

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
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

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> isEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> offsetMinutesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'offsetMinutes',
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> offsetMinutesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'offsetMinutes',
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> offsetMinutesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offsetMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> offsetMinutesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'offsetMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> offsetMinutesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'offsetMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> offsetMinutesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'offsetMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> triggerEqualTo(ActionTrigger value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trigger',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> triggerGreaterThan(
    ActionTrigger value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trigger',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> triggerLessThan(
    ActionTrigger value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trigger',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel,
      QAfterFilterCondition> triggerBetween(
    ActionTrigger lower,
    ActionTrigger upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trigger',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SmartHomeActionModelQueryObject on QueryBuilder<SmartHomeActionModel,
    SmartHomeActionModel, QFilterCondition> {}

extension SmartHomeActionModelQueryLinks on QueryBuilder<SmartHomeActionModel,
    SmartHomeActionModel, QFilterCondition> {}

extension SmartHomeActionModelQuerySortBy
    on QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QSortBy> {
  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      sortByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      sortByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      sortByActionParameters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionParameters', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      sortByActionParametersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionParameters', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      sortByAlarmId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      sortByAlarmIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      sortByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      sortByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      sortByOffsetMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offsetMinutes', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      sortByOffsetMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offsetMinutes', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      sortByTrigger() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trigger', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      sortByTriggerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trigger', Sort.desc);
    });
  }
}

extension SmartHomeActionModelQuerySortThenBy
    on QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QSortThenBy> {
  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenByActionParameters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionParameters', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenByActionParametersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionParameters', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenByAlarmId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenByAlarmIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenByOffsetMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offsetMinutes', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenByOffsetMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offsetMinutes', Sort.desc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenByTrigger() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trigger', Sort.asc);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QAfterSortBy>
      thenByTriggerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trigger', Sort.desc);
    });
  }
}

extension SmartHomeActionModelQueryWhereDistinct
    on QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QDistinct> {
  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QDistinct>
      distinctByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'action');
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QDistinct>
      distinctByActionParameters({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionParameters',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QDistinct>
      distinctByAlarmId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alarmId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QDistinct>
      distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QDistinct>
      distinctByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEnabled');
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QDistinct>
      distinctByOffsetMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'offsetMinutes');
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartHomeActionModel, QDistinct>
      distinctByTrigger() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trigger');
    });
  }
}

extension SmartHomeActionModelQueryProperty on QueryBuilder<
    SmartHomeActionModel, SmartHomeActionModel, QQueryProperty> {
  QueryBuilder<SmartHomeActionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmartHomeActionModel, SmartDeviceAction, QQueryOperations>
      actionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'action');
    });
  }

  QueryBuilder<SmartHomeActionModel, String?, QQueryOperations>
      actionParametersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionParameters');
    });
  }

  QueryBuilder<SmartHomeActionModel, String, QQueryOperations>
      alarmIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alarmId');
    });
  }

  QueryBuilder<SmartHomeActionModel, String, QQueryOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<SmartHomeActionModel, bool, QQueryOperations>
      isEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEnabled');
    });
  }

  QueryBuilder<SmartHomeActionModel, int?, QQueryOperations>
      offsetMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'offsetMinutes');
    });
  }

  QueryBuilder<SmartHomeActionModel, ActionTrigger, QQueryOperations>
      triggerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trigger');
    });
  }
}
