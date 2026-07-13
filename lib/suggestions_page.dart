import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customerdetailsuggestion.dart';

class CustomerSuggestionsPage extends StatefulWidget {
  const CustomerSuggestionsPage({super.key});

  @override
  State<CustomerSuggestionsPage> createState() =>
      _CustomerSuggestionsPageState();
}

class _CustomerSuggestionsPageState extends State<CustomerSuggestionsPage> {
  // --- State Variables for Filters ---
  final List<String> _dateOptions = [
    'Date',
    'Today',
    'Last Week',
    'Last Month',
    'Last Year'
  ];
  final List<String> _typeOptions = [
    'Type',
    'Phone Case',
    'Miniature',
    'Model',
    'Props',
    'Jewelry',
    'Art',
    'Decor',
    'Mechanical',
    'Prototype',
    'Holder'
  ];
  final List<String> _customerOptions = [
    'Customer',
    'Sam Miller',
    'Jennifer Smith',
    'Noah Evans',
    'Sophia Bennett',
    'Liam Davis',
    'Isabella Foster',
    'Ethan Parker',
    'Mia Harper',
    'Mason Cooper',
    'Ava Hayes'
  ];

  String _selectedDate = 'Date';
  String _selectedType = 'Type';
  String _selectedCustomer = 'Customer';

  @override
  void initState() {
    super.initState();
    _seedDefaultSuggestionsIfEmpty();
  }

  Future<void> _seedDefaultSuggestionsIfEmpty() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('suggestions')
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        final List<Map<String, dynamic>> defaultSuggestions = [
          {
            "name": "Sam Miller",
            "contact": "Email: sam.miller@example.com",
            "topic": "Board game miniatures",
            "type": "Miniature",
            "avatar_asset": "assets/avatar.png",
            "suggestion_text":
                "I am creating a fantasy-themed board game and I need highly detailed miniatures for the characters. Each miniature should be around 28mm scale and include fine details such as armor engravings, facial expressions, and weapons. They should be suitable for painting with acrylics and come in durable resin. I also want a set that includes different poses and multiple character classes, such as warriors, mages, and archers. These miniatures are meant for collectors and gamers, so quality and precision are extremely important. Additionally, I would like the bases to be compatible with modular terrain so they can fit into different battlefield setups.",
            "preview_image_url": "",
            "local_preview_asset": "assets/miniature.png",
            "model_file_name": "miniature_base.stl",
            "model_file_size": "850 KB",
            "model_thumbnail_url": "assets/miniature.png",
            "timestamp": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(minutes: 10))),
          },
          {
            "name": "Jennifer Smith",
            "contact": "Email: jennifer.smith@email.com",
            "topic": "Custom phone cases",
            "type": "Phone Case",
            "avatar_asset": "assets/avatar.png",
            "suggestion_text":
                "I am looking for a custom phone case design that incorporates a unique geometric pattern combined with my initials subtly engraved on the back. The case should have a matte finish, reinforced edges for protection against drops, and a lightweight build so it does not make the phone bulky. The design should also allow for easy grip, and it should be compatible with wireless charging. I am also hoping to have multiple color options, and I need the model to be durable for long-term usage while maintaining a sleek, aesthetic appearance. Reference images will be provided for pattern inspiration.",
            "preview_image_url": "",
            "local_preview_asset": "assets/phone.png",
            "model_file_name": "Geometric Case.stl",
            "model_file_size": "1.2 MB",
            "model_thumbnail_url": "assets/phone.png",
            "timestamp": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(hours: 3))),
          },
          {
            "name": "Noah Evans",
            "contact": "Email: noah.evans@example.com",
            "topic": "Architectural models",
            "type": "Model",
            "avatar_asset": "assets/avatar.png",
            "suggestion_text":
                "I require a detailed scaled 3D model of a modern architectural building design. The model should include the façade, windows, roof structures, and exterior landscaping features such as pathways and trees. It should be printed in a neutral color to highlight the design details for presentation purposes. The final product will be used in client meetings and exhibitions, so precision is key. I would also like the option for modular parts so the building can be opened to display interior layouts if possible. The model must be sturdy and easy to transport while keeping intricate details intact.",
            "preview_image_url": "",
            "local_preview_asset": "assets/other.png",
            "model_file_name": "building_v2.obj",
            "model_file_size": "5.5 MB",
            "model_thumbnail_url": "assets/other.png",
            "timestamp": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 2))),
          },
          {
            "name": "Sophia Bennett",
            "contact": "Phone: +91 2345678910",
            "topic": "Cosplay props",
            "type": "Props",
            "avatar_asset": "assets/avatar.png",
            "suggestion_text":
                "I am looking for a cosplay prop sword designed from concept art. The sword should be lightweight, safe to use at conventions, and made from durable materials suitable for painting. I want the design to capture fine details from the concept, including hilt engravings, blade patterns, and decorative accents. The prop should be modular so it can be disassembled for transport, and all edges must be rounded or reinforced to prevent injuries. Ideally, the final product should look realistic while remaining lightweight enough for long-term wear at events.",
            "preview_image_url": "",
            "local_preview_asset": "assets/toy.png",
            "model_file_name": "prop_sword.fbx",
            "model_file_size": "2.1 MB",
            "model_thumbnail_url": "assets/toy.png",
            "timestamp": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 5))),
          },
          {
            "name": "Liam Davis",
            "contact": "Email: liam.davis@example.com",
            "topic": "Jewelry designs",
            "type": "Jewelry",
            "avatar_asset": "assets/avatar.png",
            "suggestion_text":
                "I need a custom-designed pendant based on my sketch. The pendant should be suitable for 3D printing and subsequent casting in precious metals such as silver or gold. The design must include intricate patterns and textures, with a bail that allows it to be worn on various chains. I also want to experiment with alternative materials like resin or polymer for prototype versions before final metal casting. The pendant must maintain the balance and proportion of the original design and be polished so that it is ready for presentation or gifting. Small engravings and details are essential to match the sketch exactly.",
            "preview_image_url": "",
            "local_preview_asset": "assets/jewellery.png",
            "model_file_name": "pendant.3dm",
            "model_file_size": "500 KB",
            "model_thumbnail_url": "assets/jewellery.png",
            "timestamp": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 10))),
          },
          {
            "name": "Isabella Foster",
            "contact": "Phone: +91 7412583697",
            "topic": "Artistic sculptures",
            "type": "Art",
            "avatar_asset": "assets/avatar.png",
            "suggestion_text":
                "I would like a modern abstract sculpture for office décor. The sculpture should be 30–40 cm tall, 3D printable, and visually striking. It should combine geometric shapes with flowing curves, providing a balance between minimalism and elegance. The sculpture will be displayed on a desk or shelf, so weight distribution is important for stability. I would like the design to allow for color differentiation in different parts if possible and to be easy to paint or finish. The final piece should serve as a conversation starter and enhance the aesthetics of a professional workspace.",
            "preview_image_url": "",
            "local_preview_asset": "assets/vase3.png",
            "model_file_name": "abstract_form.stl",
            "model_file_size": "3.0 MB",
            "model_thumbnail_url": "assets/vase3.png",
            "timestamp": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 15))),
          },
          {
            "name": "Ethan Parker",
            "contact": "Email: ethan.parker@example.com",
            "topic": "Educational models",
            "type": "Model",
            "avatar_asset": "assets/avatar.png",
            "suggestion_text":
                "I need an anatomically accurate 3D model of a human heart for educational purposes. The model should clearly differentiate chambers, valves, and vessels. It should be suitable for 3D printing in multiple colors to highlight different parts. I want it to be robust enough to handle repeated use in classrooms, yet lightweight for easy handling. Labels or markings for educational purposes are desired. The model will be used by students and teachers, so accuracy and clarity of details are very important.",
            "preview_image_url": "",
            "local_preview_asset": "assets/bookmarks.png",
            "model_file_name": "heart_anatomy.stl",
            "model_file_size": "4.2 MB",
            "model_thumbnail_url": "assets/bookmarks.png",
            "timestamp": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 20))),
          },
          {
            "name": "Mia Harper",
            "contact": "Phone: +91 5649871285",
            "topic": "Home decor items",
            "type": "Decor",
            "avatar_asset": "assets/avatar.png",
            "suggestion_text":
                "I want a unique 3D-printed wall décor item for my living room. The design should incorporate geometric and modern elements, approximately 1 meter in width. It should be lightweight but sturdy enough to mount on the wall. The surface finish should be smooth with optional texture details. The design must complement contemporary home interiors. I also want the option to customize colors and patterns to match my home theme. The final product should serve both decorative and functional purposes, like a frame or centerpiece.",
            "preview_image_url": "",
            "local_preview_asset": "assets/wall.png",
            "model_file_name": "wall_clock.stl",
            "model_file_size": "1.8 MB",
            "model_thumbnail_url": "assets/wall.png",
            "timestamp": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 45))),
          },
          {
            "name": "Mason Cooper",
            "contact": "Email: mason.cooper@example.com",
            "topic": "Holder parts",
            "type": "Holder",
            "avatar_asset": "assets/avatar.png",
            "suggestion_text":
                "I need precise mechanical holder parts for a prototype assembly. They should fit strict dimensions, be 3D printable in durable material like ABS or PETG, and be compatible with my existing components. The design should allow for assembly without additional modifications. Parts should also be tested for load-bearing and tolerance limits. I may need multiple iterations for adjustments, so the files should be editable for future improvements. Each piece must maintain functionality, accuracy, and robustness.",
            "preview_image_url": "",
            "local_preview_asset": "assets/holder.png",
            "model_file_name": "gear_part_v3.step",
            "model_file_size": "300 KB",
            "model_thumbnail_url": "assets/holder.png",
            "timestamp": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 100))),
          },
          {
            "name": "Ava Hayes",
            "contact": "Phone: +91 7529513698",
            "topic": "Prototypes",
            "type": "Prototype",
            "avatar_asset": "assets/avatar.png",
            "suggestion_text":
                "I require a functional prototype of an electronic device enclosure. The prototype should include proper slots for components, screw mounts, and ventilation holes. It should be 3D printable and easy to assemble and modify. I want to test component fit and airflow before manufacturing the final version. Materials should be lightweight yet sturdy, and the design should allow easy iteration. The prototype must also account for heat dissipation, durability, and aesthetic appeal. Accuracy and usability are essential.",
            "preview_image_url": "",
            "local_preview_asset": "assets/vase1.png",
            "model_file_name": "enclosure_rev2.stl",
            "model_file_size": "2.5 MB",
            "model_thumbnail_url": "assets/vase1.png",
            "timestamp": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 200))),
          },
        ];
        for (var sugg in defaultSuggestions) {
          final docRef =
              FirebaseFirestore.instance.collection('suggestions').doc();
          batch.set(docRef, sugg);
        }
        await batch.commit();
      }
    } catch (_) {}
  }

  Widget _buildFilterDropdown({
    required List<String> options,
    required String currentValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
          onChanged: onChanged,
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSuggestionTile({
    required String name,
    required String contact,
    required String topic,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blueGrey,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    topic,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Customer Suggestions',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Dropdowns Row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    options: _dateOptions,
                    currentValue: _selectedDate,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() => _selectedDate = newValue);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterDropdown(
                    options: _typeOptions,
                    currentValue: _selectedType,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() => _selectedType = newValue);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterDropdown(
                    options: _customerOptions,
                    currentValue: _selectedCustomer,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() => _selectedCustomer = newValue);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Suggestions List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('suggestions')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text("No suggestions found."));
                }

                // Compute Date threshold offset
                final now = DateTime.now();
                DateTime? thresholdDate;
                if (_selectedDate == 'Today') {
                  thresholdDate = DateTime(now.year, now.month, now.day);
                } else if (_selectedDate == 'Last Week') {
                  thresholdDate = now.subtract(const Duration(days: 7));
                } else if (_selectedDate == 'Last Month') {
                  thresholdDate = now.subtract(const Duration(days: 30));
                } else if (_selectedDate == 'Last Year') {
                  thresholdDate = now.subtract(const Duration(days: 365));
                }

                // Perform multi-tier filtering
                final filteredSuggestions = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  // 1. Date filter
                  if (thresholdDate != null) {
                    final dynTimestamp = data['timestamp'];
                    if (dynTimestamp is Timestamp) {
                      if (dynTimestamp.toDate().isBefore(thresholdDate)) {
                        return false;
                      }
                    } else {
                      return false; // exclude if no timestamp recorded
                    }
                  }

                  // 2. Type filter
                  if (_selectedType != 'Type') {
                    if (data['type'] != _selectedType) return false;
                  }

                  // 3. Customer filter
                  if (_selectedCustomer != 'Customer') {
                    if (data['name'] != _selectedCustomer) return false;
                  }

                  return true;
                }).toList();

                if (filteredSuggestions.isEmpty) {
                  return const Center(child: Text("No suggestions match filters."));
                }

                return ListView.builder(
                  itemCount: filteredSuggestions.length,
                  itemBuilder: (context, index) {
                    final doc = filteredSuggestions[index];
                    final suggestion = doc.data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          _buildSuggestionTile(
                            name: suggestion['name'] ?? 'Anonymous',
                            contact: suggestion['contact'] ?? 'No contact info',
                            topic: suggestion['topic'] ?? 'N/A',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CustomerDetailSuggestion(
                                    suggestionData: {
                                      ...suggestion,
                                      // convert Timestamp type to string to prevent encoding errors on detail subpage
                                      'timestamp': (suggestion['timestamp']
                                              as Timestamp?)
                                          ?.toDate()
                                          .toIso8601String()
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          if (index < filteredSuggestions.length - 1)
                            const Divider(height: 1, thickness: 1),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}