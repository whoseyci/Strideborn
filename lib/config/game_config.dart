import 'combat_config.dart';

// ════════════════════════════════════════════════════════
// GAME CONFIG
// Central registry for all loaded config entities.
// Populated once at startup by ConfigLoader.
// Access everything through static accessors below.
// ════════════════════════════════════════════════════════

// ── Entity types ──────────────────────────────────────────────────

class LocationEntity {
  final String id;
  final String name;
  final String icon;
  final int tier;
  final List<String> activityIds;   // gather activity IDs available here
  final String nearestHub;
  final Map<String, dynamic> raw;

  const LocationEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.tier,
    required this.activityIds,
    required this.nearestHub,
    required this.raw,
  });

  bool get isTeleportHub {
    if (raw['is_hub'] == true) return true;
    if (raw['is_teleport_hub'] == true) return true;
    final t = (raw['type'] as String? ?? '').toLowerCase();
    if (t == 'city' || t == 'hub' || t == 'teleport_hub') return true;
    final nh = raw['nearest_hub'] as String? ?? raw['nearestHub'] as String? ?? '';
    if (nh.isEmpty || nh == id) return true;
    return false;
  }
  String get danger => raw['danger'] as String? ?? 'safe';
  int get travelSteps => (raw['travel_steps'] as num? ?? 200).toInt();
  Map<String, double> get resourceAvailability {
    final r = raw['resource_availability'] as Map<String, dynamic>? ?? {};
    return r.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  factory LocationEntity.fromJson(Map<String, dynamic> j) => LocationEntity(
        id: j['id'] as String,
        name: j['name'] as String,
        icon: j['icon'] as String? ?? '🗺',
        tier: (j['tier'] as num? ?? 1).toInt(),
        activityIds: List<String>.from(j['activity_ids'] ?? j['activityIds'] ?? []),
        nearestHub: j['nearest_hub'] as String? ?? j['nearestHub'] as String? ?? 'ironhaven',
        raw: j,
      );
}

class ActivityEntity {
  final String id;
  final String name;
  final String type;       // 'gather' | 'craft' | 'station'
  final String? locationId;
  final int stepsPerAction;
  final Map<String, dynamic> raw;

  const ActivityEntity({
    required this.id,
    required this.name,
    required this.type,
    this.locationId,
    required this.stepsPerAction,
    required this.raw,
  });

  String get icon => raw['icon'] as String? ?? '⛏';
  String get outputItemId =>
      raw['output_item_id'] as String? ?? raw['outputItemId'] as String? ?? id;
  int get stepsPerNode => stepsPerAction;
  Map<String, int> get inputItems {
    final r = raw['input_items'] as Map<String, dynamic>? ?? {};
    return r.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  factory ActivityEntity.fromJson(Map<String, dynamic> j) => ActivityEntity(
        id: j['id'] as String,
        name: j['name'] as String,
        type: j['type'] as String? ?? 'gather',
        locationId: j['location_id'] as String? ?? j['locationId'] as String?,
        stepsPerAction: (j['steps_per_action'] as num? ?? j['stepsPerAction'] as num? ?? 100).toInt(),
        raw: j,
      );
}

class StationEntity {
  final String id;
  final String name;
  final String locationId;
  final List<String> craftingCategories;
  final Map<String, dynamic> raw;

  const StationEntity({
    required this.id,
    required this.name,
    required this.locationId,
    required this.craftingCategories,
    required this.raw,
  });

  String get icon => raw['icon'] as String? ?? '🔨';
  bool get isCrafting => (raw['type'] as String?) == 'crafting';
  List<String> get activityIds =>
      List<String>.from(raw['activity_ids'] ?? raw['activityIds'] ?? []);

  factory StationEntity.fromJson(Map<String, dynamic> j) => StationEntity(
        id: j['id'] as String,
        name: j['name'] as String,
        locationId: j['location_id'] as String? ?? j['locationId'] as String? ?? '',
        craftingCategories: List<String>.from(
            j['crafting_categories'] ?? j['craftingCategories'] ?? []),
        raw: j,
      );
}

class ItemEntity {
  final String id;
  final String name;
  final String icon;
  final String category;    // 'resource' | 'gear' | 'consumable'
  final String? gearSlot;   // 'weapon' | 'helmet' | 'chest' | 'legs' | 'offhand' | 'cape'
  final int tier;
  final Map<String, num> stats;  // speed (hp/attack/defense are now IP-derived)
  final Map<String, List<String>>? abilities; // active: [...], passive: [...]
  final Map<String, dynamic>? recipe;
  final String? model;      // armor set name → 'assets/models/armor/<model>.glb'; null = no 3D swap
  final Map<String, dynamic> raw;

  const ItemEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    this.gearSlot,
    required this.tier,
    required this.stats,
    this.abilities,
    this.recipe,
    this.model,
    required this.raw,
  });

  bool get isEquippable => gearSlot != null;

  // CHANGED: was `tier * 5` — GDD spec is tier × 100 per slot
  int get baseIp => (raw['ip'] as num? ?? tier * 100).toInt();

  factory ItemEntity.fromJson(Map<String, dynamic> j) {
    final statsRaw = j['stats'] as Map<String, dynamic>? ?? {};
    final stats = statsRaw.map((k, v) => MapEntry(k, (v as num)));

    Map<String, List<String>>? abilities;
    final abRaw = j['abilities'] as Map<String, dynamic>?;
    if (abRaw != null) {
      abilities = {};
      if (abRaw['active'] != null) {
        abilities['active'] = List<String>.from(abRaw['active'] as List);
      }
      if (abRaw['passive'] != null) {
        abilities['passive'] = List<String>.from(abRaw['passive'] as List);
      }
    }

    return ItemEntity(
      id: j['id'] as String,
      name: j['name'] as String,
      icon: j['icon'] as String? ?? '📦',
      category: j['category'] as String? ?? 'resource',
      gearSlot: j['gear_slot'] as String? ?? j['gearSlot'] as String?,
      tier: (j['tier'] as num? ?? 1).toInt(),
      stats: stats,
      abilities: abilities,
      recipe: j['recipe'] as Map<String, dynamic>?,
      model: j['model'] as String?,
      raw: j,
    );
  }
}

// ── Registry ──────────────────────────────────────────────────────

class GameConfig {
  GameConfig._();

  static final Map<String, LocationEntity> _locations  = {};
  static final Map<String, ActivityEntity> _activities = {};
  static final Map<String, StationEntity>  _stations   = {};
  static final Map<String, ItemEntity>     _items      = {};

  static final Map<String, AbilityEntity>    _abilities  = {};
  static final Map<String, MonsterTemplate>  _monsters   = {};
  static final Map<String, ZoneNodeConfig>   _zoneNodes  = {};

  // ── Registration ──────────────────────────────────────────────

  static void registerLocation(LocationEntity e)  => _locations[e.id]  = e;
  static void registerActivity(ActivityEntity e)  => _activities[e.id] = e;
  static void registerStation(StationEntity e)    => _stations[e.id]   = e;
  static void registerItem(ItemEntity e)          => _items[e.id]      = e;
  static void registerAbility(AbilityEntity e)    => _abilities[e.id]  = e;
  static void registerMonster(MonsterTemplate m)  => _monsters[m.id]   = m;
  static void registerZoneNodes(ZoneNodeConfig z) => _zoneNodes[z.zoneId] = z;

  // ── Accessors ──────────────────────────────────────────────────

  static LocationEntity?  location(String id)  => _locations[id];
  static ActivityEntity?  activity(String id)  => _activities[id];
  static StationEntity?   station(String id)   => _stations[id];
  static ItemEntity?      item(String id)      => _items[id];
  static AbilityEntity?   ability(String id)   => _abilities[id];
  static MonsterTemplate? monster(String id)   => _monsters[id];
  static ZoneNodeConfig?  zoneNodes(String id) => _zoneNodes[id];

  // ── Collection getters ─────────────────────────────────────────

  static List<LocationEntity>  get locations  => _locations.values.toList();
  static List<ActivityEntity>  get activities => _activities.values.toList();
  static List<StationEntity>   get stations   => _stations.values.toList();
  static List<ItemEntity>      get items      => _items.values.toList();
  static List<AbilityEntity>   get abilities  => _abilities.values.toList();
  static List<MonsterTemplate> get monsters   => _monsters.values.toList();

  static List<LocationEntity>  get allLocations => _locations.values.toList();
  static List<LocationEntity>  get hubs =>
      _locations.values.where((l) => l.isTeleportHub).toList();

  static List<ActivityEntity> gatherActivitiesForLocation(String locationId) {
    final byLocationId = _activities.values
        .where((a) => a.locationId == locationId && a.type == 'gather')
        .toList();
    if (byLocationId.isNotEmpty) return byLocationId;
    final loc = _locations[locationId];
    if (loc == null) return [];
    return loc.activityIds
        .map((id) => _activities[id])
        .whereType<ActivityEntity>()
        .toList();
  }

  static List<ActivityEntity> gatheringAt(String locationId) =>
      gatherActivitiesForLocation(locationId);

  static List<StationEntity> stationsAt(String locationId) =>
      _stations.values.where((s) => s.locationId == locationId).toList();

  static void clear() {
    _locations.clear();
    _activities.clear();
    _stations.clear();
    _items.clear();
    _abilities.clear();
    _monsters.clear();
    _zoneNodes.clear();
  }
}