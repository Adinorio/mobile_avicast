import 'dart:convert';

class OfflineBirdApiService {
  static final OfflineBirdApiService _instance = OfflineBirdApiService._internal();
  factory OfflineBirdApiService() => _instance;
  OfflineBirdApiService._internal();

  // Comprehensive offline bird database
  static const Map<String, Map<String, dynamic>> _birdDatabase = {
    'spoon_billed_sandpiper': {
      'common_name': 'Spoon-billed Sandpiper',
      'scientific_name': 'Calidris pygmaea',
      'family': 'Scolopacidae',
      'iucn_status': 'CR',
      'iucn_status_text': 'Critically Endangered',
      'habitat': 'Coastal mudflats, estuaries',
      'distribution': 'East Asia, breeds in Russia, winters in Southeast Asia',
      'conservation_notes': 'Population declining due to habitat loss and hunting',
      'identification': 'Small sandpiper with distinctive spoon-shaped bill',
      'behavior': 'Probes mud for invertebrates, often in small flocks',
      'migration': 'Long-distance migrant',
      'threats': ['Habitat loss', 'Hunting', 'Climate change', 'Disturbance'],
      'conservation_actions': ['Protected areas', 'Habitat restoration', 'Anti-poaching measures'],
    },
    'chinese_egret': {
      'common_name': 'Chinese Egret',
      'scientific_name': 'Egretta eulophotes',
      'family': 'Ardeidae',
      'iucn_status': 'EN',
      'iucn_status_text': 'Endangered',
      'habitat': 'Coastal wetlands, mangroves, estuaries',
      'distribution': 'East Asia, breeds in Korea and Russia, winters in Southeast Asia',
      'identification': 'White egret with yellow bill and black legs',
      'behavior': 'Solitary feeder, stalks prey in shallow water',
      'migration': 'Medium-distance migrant',
      'threats': ['Habitat destruction', 'Pollution', 'Disturbance'],
      'conservation_actions': ['Wetland protection', 'Pollution control', 'Public awareness'],
    },
    'black_faced_spoonbill': {
      'common_name': 'Black-faced Spoonbill',
      'scientific_name': 'Platalea minor',
      'family': 'Threskiornithidae',
      'iucn_status': 'VU',
      'iucn_status_text': 'Vulnerable',
      'habitat': 'Coastal wetlands, mudflats, fish ponds',
      'distribution': 'East Asia, breeds in Korea and China',
      'identification': 'White spoonbill with black face and distinctive spoon bill',
      'behavior': 'Social feeder, sweeps bill side to side',
      'migration': 'Short to medium-distance migrant',
      'threats': ['Habitat loss', 'Pollution', 'Climate change'],
      'conservation_actions': ['Wetland conservation', 'Habitat restoration', 'Monitoring'],
    },
    'baers_pochard': {
      'common_name': "Baer's Pochard",
      'scientific_name': 'Aythya baeri',
      'family': 'Anatidae',
      'iucn_status': 'CR',
      'iucn_status_text': 'Critically Endangered',
      'habitat': 'Freshwater lakes, wetlands, rice fields',
      'distribution': 'East Asia, breeds in Russia and China',
      'identification': 'Diving duck with dark head and chestnut body',
      'behavior': 'Dives for aquatic plants and invertebrates',
      'migration': 'Medium-distance migrant',
      'threats': ['Habitat destruction', 'Hunting', 'Pollution'],
      'conservation_actions': ['Wetland protection', 'Hunting regulations', 'Habitat restoration'],
    },
    'far_eastern_curlew': {
      'common_name': 'Far Eastern Curlew',
      'scientific_name': 'Numenius madagascariensis',
      'family': 'Scolopacidae',
      'iucn_status': 'EN',
      'iucn_status_text': 'Endangered',
      'habitat': 'Coastal mudflats, estuaries, salt marshes',
      'distribution': 'East Asia, breeds in Russia, winters in Australia',
      'identification': 'Large curlew with long, curved bill',
      'behavior': 'Probes deep into mud for worms and crabs',
      'migration': 'Long-distance migrant',
      'threats': ['Habitat loss', 'Climate change', 'Disturbance'],
      'conservation_actions': ['Coastal protection', 'Habitat restoration', 'Disturbance management'],
    },
    'whiskered_tern': {
      'common_name': 'Whiskered Tern',
      'scientific_name': 'Chlidonias hybrida',
      'family': 'Laridae',
      'iucn_status': 'LC',
      'iucn_status_text': 'Least Concern',
      'habitat': 'Freshwater wetlands, lakes, rivers',
      'distribution': 'Widespread in Europe, Asia, Africa, Australia',
      'identification': 'Small tern with dark cap and white cheeks',
      'behavior': 'Aerial feeder, catches insects in flight',
      'migration': 'Variable, some populations migratory',
      'threats': ['Habitat modification', 'Pollution', 'Climate change'],
      'conservation_actions': ['Wetland protection', 'Water quality management'],
    },
    'barn_swallow': {
      'common_name': 'Barn Swallow',
      'scientific_name': 'Hirundo rustica',
      'family': 'Hirundinidae',
      'iucn_status': 'LC',
      'iucn_status_text': 'Least Concern',
      'habitat': 'Open areas, farms, urban areas',
      'distribution': 'Cosmopolitan, found worldwide',
      'identification': 'Blue-black above, white below with forked tail',
      'behavior': 'Aerial insectivore, builds mud nests',
      'migration': 'Long-distance migrant in many populations',
      'threats': ['Habitat change', 'Pesticides', 'Climate change'],
      'conservation_actions': ['Habitat preservation', 'Reduced pesticide use'],
    },
    'peregrine_falcon': {
      'common_name': 'Peregrine Falcon',
      'scientific_name': 'Falco peregrinus',
      'family': 'Falconidae',
      'iucn_status': 'LC',
      'iucn_status_text': 'Least Concern',
      'habitat': 'Cliffs, mountains, urban areas',
      'distribution': 'Cosmopolitan, found worldwide',
      'identification': 'Large falcon with dark head and barred underparts',
      'behavior': 'High-speed stoop hunter, fastest animal',
      'migration': 'Variable, some populations migratory',
      'threats': ['Habitat loss', 'Pesticides', 'Disturbance'],
      'conservation_actions': ['Cliff protection', 'Reduced pesticide use', 'Monitoring'],
    },
    'great_knot': {
      'common_name': 'Great Knot',
      'scientific_name': 'Calidris tenuirostris',
      'family': 'Scolopacidae',
      'iucn_status': 'EN',
      'iucn_status_text': 'Endangered',
      'habitat': 'Coastal mudflats, estuaries',
      'distribution': 'East Asia, breeds in Russia, winters in Australia',
      'identification': 'Large sandpiper with long bill and streaked breast',
      'behavior': 'Probes mud for invertebrates, often in large flocks',
      'migration': 'Long-distance migrant',
      'threats': ['Habitat loss', 'Climate change', 'Disturbance'],
      'conservation_actions': ['Coastal protection', 'Habitat restoration', 'Disturbance management'],
    },
    'nordmanns_greenshank': {
      'common_name': "Nordmann's Greenshank",
      'scientific_name': 'Tringa guttifer',
      'family': 'Scolopacidae',
      'iucn_status': 'NT',
      'iucn_status_text': 'Near Threatened',
      'habitat': 'Coastal wetlands, mudflats, estuaries',
      'distribution': 'East Asia, breeds in Russia, winters in Southeast Asia',
      'identification': 'Medium-sized sandpiper with greenish legs',
      'behavior': 'Wades in shallow water, probes for prey',
      'migration': 'Medium-distance migrant',
      'threats': ['Habitat loss', 'Pollution', 'Disturbance'],
      'conservation_actions': ['Wetland protection', 'Habitat restoration', 'Monitoring'],
    },
    'common_redshank': {
      'common_name': 'Common Redshank',
      'scientific_name': 'Tringa totanus',
      'family': 'Scolopacidae',
      'iucn_status': 'LC',
      'iucn_status_text': 'Least Concern',
      'habitat': 'Wetlands, marshes, coastal areas',
      'distribution': 'Europe, Asia, Africa',
      'identification': 'Medium-sized wader with red legs and bill base',
      'behavior': 'Wades in shallow water, feeds on invertebrates',
      'migration': 'Variable, some populations migratory',
      'threats': ['Habitat loss', 'Pollution', 'Climate change'],
      'conservation_actions': ['Wetland protection', 'Water quality management'],
    },
    'saunderss_gull': {
      'common_name': "Saunders's Gull",
      'scientific_name': 'Saundersilarus saundersi',
      'family': 'Laridae',
      'iucn_status': 'VU',
      'iucn_status_text': 'Vulnerable',
      'habitat': 'Coastal wetlands, mudflats, salt marshes',
      'distribution': 'East Asia, breeds in China and Korea',
      'identification': 'Small gull with black head in breeding plumage',
      'behavior': 'Feeds on small fish and invertebrates',
      'migration': 'Short-distance migrant',
      'threats': ['Habitat loss', 'Pollution', 'Disturbance'],
      'conservation_actions': ['Coastal protection', 'Habitat restoration', 'Monitoring'],
    },
    'oriental_stork': {
      'common_name': 'Oriental Stork',
      'scientific_name': 'Ciconia boyciana',
      'family': 'Ciconiidae',
      'iucn_status': 'EN',
      'iucn_status_text': 'Endangered',
      'habitat': 'Wetlands, rice fields, grasslands',
      'distribution': 'East Asia, breeds in Russia and China',
      'identification': 'Large white stork with black wing feathers',
      'behavior': 'Wades in shallow water, feeds on fish and frogs',
      'migration': 'Medium-distance migrant',
      'threats': ['Habitat destruction', 'Hunting', 'Pollution'],
      'conservation_actions': ['Wetland protection', 'Hunting regulations', 'Habitat restoration'],
    },
    'red_crowned_crane': {
      'common_name': 'Red-crowned Crane',
      'scientific_name': 'Grus japonensis',
      'family': 'Gruidae',
      'iucn_status': 'VU',
      'iucn_status_text': 'Vulnerable',
      'habitat': 'Wetlands, marshes, rice fields',
      'distribution': 'East Asia, breeds in Russia and China',
      'identification': 'Large crane with red crown and white body',
      'behavior': 'Dances during courtship, feeds on plants and small animals',
      'migration': 'Medium-distance migrant',
      'threats': ['Habitat loss', 'Hunting', 'Pollution'],
      'conservation_actions': ['Wetland protection', 'Hunting regulations', 'Habitat restoration'],
    },
    'chinese_crested_tern': {
      'common_name': 'Chinese Crested Tern',
      'scientific_name': 'Thalasseus bernsteini',
      'family': 'Laridae',
      'iucn_status': 'DD',
      'iucn_status_text': 'Data Deficient',
      'habitat': 'Coastal areas, islands, estuaries',
      'distribution': 'East Asia, limited distribution',
      'identification': 'Medium-sized tern with distinctive crest',
      'behavior': 'Feeds on fish, nests in colonies',
      'migration': 'Unknown, likely short-distance',
      'threats': ['Habitat loss', 'Disturbance', 'Unknown'],
      'conservation_actions': ['Research needed', 'Habitat protection', 'Monitoring'],
    },
  };

  // Get bird information by common name
  Map<String, dynamic>? getBirdInfo(String commonName) {
    final key = commonName.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    return _birdDatabase[key];
  }

  // Search birds by name (partial match)
  List<Map<String, dynamic>> searchBirds(String query) {
    final results = <Map<String, dynamic>>[];
    final searchQuery = query.toLowerCase();
    
    _birdDatabase.forEach((key, bird) {
      if (bird['common_name'].toString().toLowerCase().contains(searchQuery) ||
          bird['scientific_name'].toString().toLowerCase().contains(searchQuery) ||
          bird['family'].toString().toLowerCase().contains(searchQuery)) {
        results.add(bird);
      }
    });
    
    return results;
  }

  // Get all birds
  List<Map<String, dynamic>> getAllBirds() {
    return _birdDatabase.values.toList();
  }

  // Get birds by IUCN status
  List<Map<String, dynamic>> getBirdsByStatus(String status) {
    return _birdDatabase.values
        .where((bird) => bird['iucn_status'] == status)
        .toList();
  }

  // Get birds by family
  List<Map<String, dynamic>> getBirdsByFamily(String family) {
    return _birdDatabase.values
        .where((bird) => bird['family'].toString().toLowerCase() == family.toLowerCase())
        .toList();
  }

  // Get conservation statistics
  Map<String, int> getConservationStats() {
    final stats = <String, int>{};
    
    _birdDatabase.values.forEach((bird) {
      final status = bird['iucn_status'] as String;
      stats[status] = (stats[status] ?? 0) + 1;
    });
    
    return stats;
  }

  // Get threats analysis
  Map<String, int> getThreatsAnalysis() {
    final threats = <String, int>{};
    
    _birdDatabase.values.forEach((bird) {
      final birdThreats = bird['threats'] as List<dynamic>?;
      if (birdThreats != null) {
        for (final threat in birdThreats) {
          threats[threat] = (threats[threat] ?? 0) + 1;
        }
      }
    });
    
    return threats;
  }

  // Export data as JSON (for offline storage)
  String exportDataAsJson() {
    return jsonEncode(_birdDatabase);
  }

  // Import data from JSON (for updates)
  void importDataFromJson(String jsonData) {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      // Note: In a real app, you'd want to validate this data
      // For now, we'll just use the static database
    } catch (e) {
      // Keep using static database if import fails
    }
  }
} 