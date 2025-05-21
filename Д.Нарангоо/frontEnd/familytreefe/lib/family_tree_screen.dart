import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../models/family_member.dart';
import '../api/api_service.dart';
import 'package:flutter/foundation.dart';
import 'add_person_form.dart';

class FamilyTreeScreen extends StatefulWidget {
  final AuthService authService;

  const FamilyTreeScreen({super.key, required this.authService});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  final Graph graph = Graph();
  SugiyamaConfiguration builder = SugiyamaConfiguration();
  bool isLoading = true;
  List<FamilyMember> members = [];

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();

    // Configure the Sugiyama layout for better tree visualization
    builder
      ..nodeSeparation = 100
      ..levelSeparation = 150
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  Future<void> _loadFamilyMembers() async {
    try {
      final loadedMembers = await widget.authService.getFamilyMembers();
      if (kDebugMode) {
        print('Loaded members count: ${loadedMembers.length}');
        print('Loaded members: $loadedMembers');
      }
      setState(() {
        members = loadedMembers;
        _buildTree();
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading family members: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  String? findRootId() {
    // Find the current user's ID
    final currentUserId = widget.authService.userInfo?['uid'];
    if (currentUserId == null) return null;

    // Find the current user's node
    final currentUser = members.firstWhere(
      (m) => m.fromPersonId == currentUserId && m.relationshipType == 'ӨӨРӨӨ',
      orElse: () => members.first,
    );

    return currentUser.fromPersonId;
  }

  void _buildTree() {
    // Clear existing nodes and edges
    graph.nodes.clear();
    graph.edges.clear();

    if (members.isEmpty) {
      if (kDebugMode) {
        print('No members to build tree');
      }
      return;
    }

    if (kDebugMode) {
      print('Building tree with ${members.length} members');
    }

    // Create nodes for each family member
    final Map<String, Node> nodeMap = {};
    for (var member in members) {
      // Create a unique node ID using fromPersonId and name
      final nodeId = '${member.fromPersonId}_${member.name}';
      final node = Node.Id(nodeId);
      nodeMap[nodeId] = node;
      graph.addNode(node);
      if (kDebugMode) {
        print('Added node for member: ${member.name} with ID: $nodeId');
      }
    }

    // Find the root node (current user)
    final rootId = findRootId();
    if (rootId == null) {
      if (kDebugMode) {
        print('Could not find root node');
      }
      return;
    }

    final rootMember = members.firstWhere((m) => m.fromPersonId == rootId);
    final rootNodeId = '${rootId}_${rootMember.name}';
    final rootNode = nodeMap[rootNodeId];

    if (rootNode == null) {
      if (kDebugMode) {
        print('Root node not found in nodeMap');
      }
      return;
    }

    // Group members by relationship type
    Map<String, List<FamilyMember>> relationshipGroups = {};
    for (var member in members) {
      final relType = member.relationshipType.toLowerCase();
      if (!relationshipGroups.containsKey(relType)) {
        relationshipGroups[relType] = [];
      }
      relationshipGroups[relType]!.add(member);
    }

    // Find key family members

    List<FamilyMember> fathers =
        relationshipGroups['эцэг'] ?? relationshipGroups['father'] ?? [];
    List<FamilyMember> mothers =
        relationshipGroups['эх'] ?? relationshipGroups['mother'] ?? [];
    List<FamilyMember> grandfathers =
        relationshipGroups['өвөө'] ?? relationshipGroups['grandfather'] ?? [];
    List<FamilyMember> grandmothers =
        relationshipGroups['эмээ'] ?? relationshipGroups['grandmother'] ?? [];
    List<FamilyMember> siblings = [
      ...(relationshipGroups['ах'] ?? []),
      ...(relationshipGroups['brothers'] ?? []),
      ...(relationshipGroups['эгч'] ?? []),
      ...(relationshipGroups['sisters'] ?? []),
      ...(relationshipGroups['дүү'] ?? []),
      ...(relationshipGroups['youngsiblings'] ?? []),
    ];
    List<FamilyMember> children =
        relationshipGroups['хүүхэд'] ?? relationshipGroups['children'] ?? [];
    List<FamilyMember> spouses =
        relationshipGroups['гэр бүл'] ?? relationshipGroups['spouse'] ?? [];

    // Get nodes for family members
    Node? fatherNode =
        fathers.isNotEmpty
            ? nodeMap['${fathers.first.fromPersonId}_${fathers.first.name}']
            : null;
    Node? motherNode =
        mothers.isNotEmpty
            ? nodeMap['${mothers.first.fromPersonId}_${mothers.first.name}']
            : null;
    Node? grandfatherNode =
        grandfathers.isNotEmpty
            ? nodeMap['${grandfathers.first.fromPersonId}_${grandfathers.first.name}']
            : null;
    Node? grandmotherNode =
        grandmothers.isNotEmpty
            ? nodeMap['${grandmothers.first.fromPersonId}_${grandmothers.first.name}']
            : null;

    // Paint for spousal relationships - dashed line in red
    final Paint spousePaint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Paint for parent-child relationships
    final Paint parentChildPaint =
        Paint()
          ..color = Colors.green
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Connect grandparents to father - ensuring proper hierarchy
    for (var grandfather in grandfathers) {
      final gfNode = nodeMap['${grandfather.fromPersonId}_${grandfather.name}'];
      if (gfNode != null && fatherNode != null) {
        graph.addEdge(gfNode, fatherNode, paint: parentChildPaint);
      }
    }

    for (var grandmother in grandmothers) {
      final gmNode = nodeMap['${grandmother.fromPersonId}_${grandmother.name}'];
      if (gmNode != null && fatherNode != null) {
        graph.addEdge(gmNode, fatherNode, paint: parentChildPaint);
      }
    }

    // Connect parents to self
    if (fatherNode != null) {
      graph.addEdge(fatherNode, rootNode, paint: parentChildPaint);
    }

    if (motherNode != null) {
      graph.addEdge(motherNode, rootNode, paint: parentChildPaint);
    }

    // Connect siblings - they should all connect to the same parent as self
    Node? parentForSiblings = fatherNode ?? motherNode;
    if (parentForSiblings != null) {
      for (var sibling in siblings) {
        final siblingNode = nodeMap['${sibling.fromPersonId}_${sibling.name}'];
        if (siblingNode != null) {
          graph.addEdge(
            parentForSiblings,
            siblingNode,
            paint: parentChildPaint,
          );
        }
      }
    } else {
      // If no parents, create connections between siblings and root
      for (var sibling in siblings) {
        final siblingNode = nodeMap['${sibling.fromPersonId}_${sibling.name}'];
        if (siblingNode != null) {
          graph.addEdge(
            rootNode,
            siblingNode,
            paint: Paint()..color = Colors.teal,
          );
        }
      }
    }

    // Connect children
    for (var child in children) {
      final childNode = nodeMap['${child.fromPersonId}_${child.name}'];
      if (childNode != null) {
        graph.addEdge(rootNode, childNode, paint: parentChildPaint);
      }
    }

    // Connect spouses
    for (var spouse in spouses) {
      final spouseNode = nodeMap['${spouse.fromPersonId}_${spouse.name}'];
      if (spouseNode != null) {
        graph.addEdge(rootNode, spouseNode, paint: spousePaint);
      }
    }

    // Connect father and mother as spouses
    if (fatherNode != null && motherNode != null) {
      graph.addEdge(fatherNode, motherNode, paint: spousePaint);
    }

    // Connect grandfather and grandmother as spouses
    if (grandfatherNode != null && grandmotherNode != null) {
      graph.addEdge(grandfatherNode, grandmotherNode, paint: spousePaint);
    }

    if (kDebugMode) {
      print('Tree building completed');
      print('Total nodes: ${graph.nodes.length}');
      print('Total edges: ${graph.edges.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ургийн мод',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.green),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              _loadFamilyMembers();
            },
          ),
          // Add help button to explain relationship colors
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.green),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Харилцаа холбооны тайлбар'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('🟢 Ногоон зураас - Эцэг эх, хүүхдийн холбоо'),
                          Text('🔴 Улаан зураас - Гэр бүлийн холбоо'),
                          Text('🟣 Ягаан хүрээ - Өөрөө'),
                          Text('🔵 Цэнхэр хүрээ - Эцэг'),
                          Text('🩷 Ягаан хүрээ - Эх'),
                          Text('🟤 Бор хүрээ - Өвөө'),
                          Text('🟣 Нил ягаан хүрээ - Эмээ'),
                          Text('🟢 Ногоон хүрээ - Ах, эгч, дүү'),
                          Text('🟠 Улбар шар хүрээ - Хүүхэд'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AddPersonForm(authService: widget.authService),
            ),
          ).then((_) {
            // Reload when returning from add person form
            setState(() {
              isLoading = true;
            });
            _loadFamilyMembers();
          });
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.person_add),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(150),
                minScale: 0.1,
                maxScale: 5.0,
                child: GraphView(
                  graph: graph,
                  algorithm: SugiyamaAlgorithm(builder),
                  paint:
                      Paint()
                        ..color = Colors.green
                        ..strokeWidth = 2
                        ..style = PaintingStyle.stroke,
                  builder: (Node node) {
                    final member = members.firstWhere(
                      (m) => '${m.fromPersonId}_${m.name}' == node.key?.value,
                      orElse: () => members.first,
                    );
                    return _buildFamilyMemberNode(member);
                  },
                ),
              ),
    );
  }

  Widget _buildFamilyMemberNode(FamilyMember member) {
    // Map English relationship types to Mongolian
    String getMongolianRelationshipType(String type) {
      switch (type.toLowerCase()) {
        case 'father':
          return 'ЭЦЭГ';
        case 'mother':
          return 'ЭХ';
        case 'children':
          return 'ХҮҮХЭД';
        case 'brothers':
          return 'АХ';
        case 'sisters':
          return 'ЭГЧ';
        case 'youngsiblings':
          return 'ДҮҮ';
        case 'spouse':
          return 'ГЭР БҮЛ';
        case 'grandfather':
          return 'ӨВӨӨ';
        case 'grandmother':
          return 'ЭМЭЭ';
        default:
          return type;
      }
    }

    // Determine color based on relationship type
    Color getBorderColor(String relationType) {
      switch (relationType.toLowerCase()) {
        case 'өөрөө':
          return Colors.deepPurple;
        case 'эцэг':
        case 'father':
          return Colors.blue;
        case 'эх':
        case 'mother':
          return Colors.pink;
        case 'өвөө':
        case 'grandfather':
          return Colors.brown;
        case 'эмээ':
        case 'grandmother':
          return Colors.purple;
        case 'ах':
        case 'brothers':
        case 'эгч':
        case 'sisters':
        case 'дүү':
        case 'youngsiblings':
          return Colors.teal;
        case 'хүүхэд':
        case 'children':
          return Colors.orange;
        case 'гэр бүл':
        case 'spouse':
          return Colors.red;
        default:
          return Colors.green;
      }
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: getBorderColor(member.relationshipType),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.5 * 255).round()),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: getBorderColor(member.relationshipType),
            child: Icon(
              member.gender == 'Эр' ? Icons.male : Icons.female,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${member.lastname ?? ''} ${member.name}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            'Төрсөн: ${member.birthdate.year}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            getMongolianRelationshipType(member.relationshipType),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
