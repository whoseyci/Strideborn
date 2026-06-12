import 'dart:math';

import '../config/game_config.dart';
import '../config/combat_config.dart';

class MapGenerator {
  static final Map<String, LocationEntity> generatedLocations = {};
  static final Map<String, ZoneNodeConfig> generatedZoneNodes = {};

  static void generate() {
    generatedLocations.clear();
    generatedZoneNodes.clear();

    const int size = 11;
    const int center = 5;

    // Define hub coordinates
    const Point<int> oreHub = Point(2, 2);
    const Point<int> woodHub = Point(8, 2);
    const Point<int> hideHub = Point(2, 8);
    const Point<int> fibreHub = Point(8, 8);

    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        // Calculate Chebyshev distance to center
        int distToCenter = max((x - center).abs(), (y - center).abs());
        int tier = (6 - distToCenter).clamp(1, 6);

        String id = 'zone_${x}_${y}';
        String name = 'Wilds [$x, $y]';
        bool isHub = false;
        String icon = '🌲';

        // Check if it's a special city
        if (x == center && y == center) {
          name = 'The Crimson Citadel';
          id = 'crimson_citadel';
          isHub = true;
          icon = '🏰';
        } else if ((x == 0 && y == 0) || (x == 10 && y == 0) || (x == 0 && y == 10) || (x == 10 && y == 10)) {
          name = 'Beginner Town [$x,$y]';
          id = 'beginner_town_${x}_$y';
          isHub = true;
          icon = '⌂';
        } else if (x == oreHub.x && y == oreHub.y) {
          name = 'Ironhaven';
          id = 'ironhaven';
          isHub = true;
          icon = '⌂';
        } else if (x == woodHub.x && y == woodHub.y) {
          name = 'Ashgrove';
          id = 'ashgrove';
          isHub = true;
          icon = '⌂';
        } else if (x == hideHub.x && y == hideHub.y) {
          name = 'Tanners\' Rest';
          id = 'tanners_rest';
          isHub = true;
          icon = '⌂';
        } else if (x == fibreHub.x && y == fibreHub.y) {
          name = 'Silkwatch';
          id = 'silkwatch';
          isHub = true;
          icon = '⌂';
        }

        // Calculate resource weights using inverse square distance
        double dist(Point<int> p) => sqrt(pow(x - p.x, 2) + pow(y - p.y, 2));
        
        double wOre = 1.0 / (pow(dist(oreHub) + 1, 2));
        double wWood = 1.0 / (pow(dist(woodHub) + 1, 2));
        double wHide = 1.0 / (pow(dist(hideHub) + 1, 2));
        double wFibre = 1.0 / (pow(dist(fibreHub) + 1, 2));
        
        double totalW = wOre + wWood + wHide + wFibre;
        wOre /= totalW;
        wWood /= totalW;
        wHide /= totalW;
        wFibre /= totalW;

        // Pick activity IDs matching the tier
        List<String> activities = [];
        // Only inject activities if weight > 0.15 to keep zone identities strong
        if (wOre > 0.15) activities.addAll(_getActivitiesFor('mining', tier));
        if (wWood > 0.15) activities.addAll(_getActivitiesFor('woodcutting', tier)); // Assuming foraging
        if (wHide > 0.15) activities.addAll(_getActivitiesFor('hunting', tier));
        if (wFibre > 0.15) activities.addAll(_getActivitiesFor('gathering', tier)); // Assuming gathering
        
        // If empty (due to missing high tier definitions), fallback
        if (activities.isEmpty) {
          activities.addAll(_getActivitiesFor('mining', max(1, tier - 1)));
        }

        generatedLocations[id] = LocationEntity(
          id: id,
          name: name,
          icon: icon,
          tier: tier,
          activityIds: isHub ? [] : activities,
          nearestHub: 'crimson_citadel',
          raw: {
            'is_teleport_hub': isHub,
            'nearest_hub': 'crimson_citadel',
            'danger': isHub ? 'none' : (tier > 3 ? 'borderlands' : 'safe'),
            'travel_steps': 200 * tier,
            'resource_availability': {
              'iron_ore': wOre,
              'oak_wood': wWood,
              'coarse_hide': wHide,
              'rough_fibre': wFibre,
            }
          },
        );

        // Generate a ZoneNodeConfig for this location
        if (!isHub) {
          generatedZoneNodes[id] = _generateNodeConfig(id, tier);
        }
      }
    }
  }

  static List<String> _getActivitiesFor(String track, int tier) {
    // Find activities in GameConfig
    // Note: since GameConfig loads JSON asynchronously, this might need to run AFTER GameConfig loads items.
    // Assuming activities are pre-loaded by the time this is fully utilized.
    
    // We can hardcode the mappings for now if GameConfig isn't loaded yet during generation, 
    // but ideally MapGenerator.generate() is called at the end of ConfigLoader.loadAll().
    
    // Since we don't know the exact track names, let's use string matching on the ID
    final List<String> matches = [];
    for (final act in GameConfig.activities) {
      if (act.type != 'gather') continue;
      final actTier = (act.raw['tier'] as num? ?? 1).toInt();
      if (actTier != tier) continue;
      
      final id = act.id.toLowerCase();
      if (track == 'mining' && id.contains('mine')) matches.add(act.id);
      if (track == 'woodcutting' && (id.contains('chop') || id.contains('forage_oak') || id.contains('forage_ash'))) matches.add(act.id);
      if (track == 'hunting' && id.contains('hunt')) matches.add(act.id);
      if (track == 'gathering' && (id.contains('gather') || id.contains('forage') && !id.contains('oak') && !id.contains('ash'))) matches.add(act.id);
    }
    return matches;
  }

  static ZoneNodeConfig _generateNodeConfig(String zoneId, int tier) {
    return ZoneNodeConfig(
      zoneId: zoneId,
      stepsPerNodeBase: 100 * tier,
      nodeTable: [
        NodeTableEntry(type: NodeType.gather, weight: 60),
        NodeTableEntry(type: NodeType.combat, weight: 30, monsterIds: _getMonstersForTier(tier)),
        NodeTableEntry(type: NodeType.treasure, weight: 10, lootTable: []), // We can leave loot empty or generate it
      ]
    );
  }

  static List<String> _getMonstersForTier(int tier) {
    return GameConfig.monsters.where((m) => m.tier == tier).map((m) => m.id).toList();
  }
}
