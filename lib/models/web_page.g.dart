// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_page.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWebPageCollection on Isar {
  IsarCollection<WebPage> get webPages => this.collection();
}

const WebPageSchema = CollectionSchema(
  name: r'WebPage',
  id: -232234268056293840,
  properties: {
    r'faviconUrl': PropertySchema(
      id: 0,
      name: r'faviconUrl',
      type: IsarType.string,
    ),
    r'isFavorite': PropertySchema(
      id: 1,
      name: r'isFavorite',
      type: IsarType.bool,
    ),
    r'lastVisited': PropertySchema(
      id: 2,
      name: r'lastVisited',
      type: IsarType.dateTime,
    ),
    r'title': PropertySchema(
      id: 3,
      name: r'title',
      type: IsarType.string,
    ),
    r'url': PropertySchema(
      id: 4,
      name: r'url',
      type: IsarType.string,
    ),
    r'visitCount': PropertySchema(
      id: 5,
      name: r'visitCount',
      type: IsarType.long,
    )
  },
  estimateSize: _webPageEstimateSize,
  serialize: _webPageSerialize,
  deserialize: _webPageDeserialize,
  deserializeProp: _webPageDeserializeProp,
  idName: r'id',
  indexes: {
    r'url': IndexSchema(
      id: -5756857009679432345,
      name: r'url',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'url',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    ),
    r'lastVisited': IndexSchema(
      id: -3279997518727335636,
      name: r'lastVisited',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastVisited',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _webPageGetId,
  getLinks: _webPageGetLinks,
  attach: _webPageAttach,
  version: '3.1.0+1',
);

int _webPageEstimateSize(
  WebPage object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.faviconUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _webPageSerialize(
  WebPage object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.faviconUrl);
  writer.writeBool(offsets[1], object.isFavorite);
  writer.writeDateTime(offsets[2], object.lastVisited);
  writer.writeString(offsets[3], object.title);
  writer.writeString(offsets[4], object.url);
  writer.writeLong(offsets[5], object.visitCount);
}

WebPage _webPageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WebPage(
    isFavorite: reader.readBoolOrNull(offsets[1]) ?? false,
    lastVisited: reader.readDateTime(offsets[2]),
    title: reader.readStringOrNull(offsets[3]),
    url: reader.readString(offsets[4]),
    visitCount: reader.readLongOrNull(offsets[5]) ?? 1,
  );
  object.faviconUrl = reader.readStringOrNull(offsets[0]);
  object.id = id;
  return object;
}

P _webPageDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 1) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _webPageGetId(WebPage object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _webPageGetLinks(WebPage object) {
  return [];
}

void _webPageAttach(IsarCollection<dynamic> col, Id id, WebPage object) {
  object.id = id;
}

extension WebPageQueryWhereSort on QueryBuilder<WebPage, WebPage, QWhere> {
  QueryBuilder<WebPage, WebPage, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhere> anyUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'url'),
      );
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhere> anyLastVisited() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastVisited'),
      );
    });
  }
}

extension WebPageQueryWhere on QueryBuilder<WebPage, WebPage, QWhereClause> {
  QueryBuilder<WebPage, WebPage, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> idBetween(
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

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> urlEqualTo(String url) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'url',
        value: [url],
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> urlNotEqualTo(String url) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'url',
              lower: [],
              upper: [url],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'url',
              lower: [url],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'url',
              lower: [url],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'url',
              lower: [],
              upper: [url],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> urlGreaterThan(
    String url, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'url',
        lower: [url],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> urlLessThan(
    String url, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'url',
        lower: [],
        upper: [url],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> urlBetween(
    String lowerUrl,
    String upperUrl, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'url',
        lower: [lowerUrl],
        includeLower: includeLower,
        upper: [upperUrl],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> urlStartsWith(
      String UrlPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'url',
        lower: [UrlPrefix],
        upper: ['$UrlPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'url',
        value: [''],
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'url',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'url',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'url',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'url',
              upper: [''],
            ));
      }
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> lastVisitedEqualTo(
      DateTime lastVisited) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastVisited',
        value: [lastVisited],
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> lastVisitedNotEqualTo(
      DateTime lastVisited) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastVisited',
              lower: [],
              upper: [lastVisited],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastVisited',
              lower: [lastVisited],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastVisited',
              lower: [lastVisited],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastVisited',
              lower: [],
              upper: [lastVisited],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> lastVisitedGreaterThan(
    DateTime lastVisited, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastVisited',
        lower: [lastVisited],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> lastVisitedLessThan(
    DateTime lastVisited, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastVisited',
        lower: [],
        upper: [lastVisited],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterWhereClause> lastVisitedBetween(
    DateTime lowerLastVisited,
    DateTime upperLastVisited, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastVisited',
        lower: [lowerLastVisited],
        includeLower: includeLower,
        upper: [upperLastVisited],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WebPageQueryFilter
    on QueryBuilder<WebPage, WebPage, QFilterCondition> {
  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> faviconUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'faviconUrl',
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> faviconUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'faviconUrl',
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> faviconUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> faviconUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> faviconUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> faviconUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'faviconUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> faviconUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> faviconUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> faviconUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> faviconUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'faviconUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> faviconUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'faviconUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> faviconUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'faviconUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> idBetween(
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

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> isFavoriteEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFavorite',
        value: value,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> lastVisitedEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastVisited',
        value: value,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> lastVisitedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastVisited',
        value: value,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> lastVisitedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastVisited',
        value: value,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> lastVisitedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastVisited',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> urlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> urlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> urlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> visitCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visitCount',
        value: value,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> visitCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'visitCount',
        value: value,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> visitCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'visitCount',
        value: value,
      ));
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterFilterCondition> visitCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'visitCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WebPageQueryObject
    on QueryBuilder<WebPage, WebPage, QFilterCondition> {}

extension WebPageQueryLinks
    on QueryBuilder<WebPage, WebPage, QFilterCondition> {}

extension WebPageQuerySortBy on QueryBuilder<WebPage, WebPage, QSortBy> {
  QueryBuilder<WebPage, WebPage, QAfterSortBy> sortByFaviconUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.asc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> sortByFaviconUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.desc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> sortByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> sortByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> sortByLastVisited() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastVisited', Sort.asc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> sortByLastVisitedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastVisited', Sort.desc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> sortByVisitCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitCount', Sort.asc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> sortByVisitCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitCount', Sort.desc);
    });
  }
}

extension WebPageQuerySortThenBy
    on QueryBuilder<WebPage, WebPage, QSortThenBy> {
  QueryBuilder<WebPage, WebPage, QAfterSortBy> thenByFaviconUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.asc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> thenByFaviconUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.desc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> thenByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> thenByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> thenByLastVisited() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastVisited', Sort.asc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> thenByLastVisitedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastVisited', Sort.desc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> thenByVisitCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitCount', Sort.asc);
    });
  }

  QueryBuilder<WebPage, WebPage, QAfterSortBy> thenByVisitCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitCount', Sort.desc);
    });
  }
}

extension WebPageQueryWhereDistinct
    on QueryBuilder<WebPage, WebPage, QDistinct> {
  QueryBuilder<WebPage, WebPage, QDistinct> distinctByFaviconUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'faviconUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WebPage, WebPage, QDistinct> distinctByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavorite');
    });
  }

  QueryBuilder<WebPage, WebPage, QDistinct> distinctByLastVisited() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastVisited');
    });
  }

  QueryBuilder<WebPage, WebPage, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WebPage, WebPage, QDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WebPage, WebPage, QDistinct> distinctByVisitCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visitCount');
    });
  }
}

extension WebPageQueryProperty
    on QueryBuilder<WebPage, WebPage, QQueryProperty> {
  QueryBuilder<WebPage, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WebPage, String?, QQueryOperations> faviconUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'faviconUrl');
    });
  }

  QueryBuilder<WebPage, bool, QQueryOperations> isFavoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavorite');
    });
  }

  QueryBuilder<WebPage, DateTime, QQueryOperations> lastVisitedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastVisited');
    });
  }

  QueryBuilder<WebPage, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<WebPage, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }

  QueryBuilder<WebPage, int, QQueryOperations> visitCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visitCount');
    });
  }
}
