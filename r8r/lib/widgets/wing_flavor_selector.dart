import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WingFlavorSelector extends StatefulWidget {
  final List<String> selectedFlavors;
  final Function(List<String>) onFlavorsChanged;

  const WingFlavorSelector({
    super.key,
    required this.selectedFlavors,
    required this.onFlavorsChanged,
  });

  @override
  State<WingFlavorSelector> createState() => _WingFlavorSelectorState();
}

class _WingFlavorSelectorState extends State<WingFlavorSelector> {
  final List<String> _availableFlavors = [
    'Buffalo',
    'BBQ',
    'Honey Mustard',
    'Teriyaki',
    'Garlic Parmesan',
    'Lemon Pepper',
    'Cajun',
    'Sriracha',
    'Mango Habanero',
    'Carolina Reaper',
    'Ghost Pepper',
    'Jalapeño',
    'Ranch',
    'Blue Cheese',
    'Sweet & Sour',
    'Honey BBQ',
    'Smoky BBQ',
    'Chipotle',
    'Buffalo Ranch',
    'Spicy Garlic',
    'Hot Buffalo',
    'Mild Buffalo',
    'Extra Hot',
    'Nashville Hot',
    'Korean BBQ',
    'Thai Chili',
    'Honey Sriracha',
    'Maple Bourbon',
    'Old Bay',
    'Cajun Ranch',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.drumstickBite,
              color: const Color(0xFFC00000),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Wing Flavors',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFD00000).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.selectedFlavors.length} selected',
                style: TextStyle(
                  color: const Color(0xFFC00000),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'What flavors did you order? (Select all that apply)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        
        // Selected flavors chips
        if (widget.selectedFlavors.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedFlavors.map((flavor) {
              return Chip(
                label: Text(flavor),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  final newFlavors = List<String>.from(widget.selectedFlavors);
                  newFlavors.remove(flavor);
                  widget.onFlavorsChanged(newFlavors);
                },
                backgroundColor: const Color(0xFFD00000).withOpacity(0.1),
                deleteIconColor: const Color(0xFFC00000),
                labelStyle: TextStyle(
                  color: const Color(0xFFC00000),
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Flavor selection grid
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _availableFlavors.length,
            itemBuilder: (context, index) {
              final flavor = _availableFlavors[index];
              final isSelected = widget.selectedFlavors.contains(flavor);
              
              return GestureDetector(
                onTap: () {
                  final newFlavors = List<String>.from(widget.selectedFlavors);
                  if (isSelected) {
                    newFlavors.remove(flavor);
                  } else {
                    newFlavors.add(flavor);
                  }
                  widget.onFlavorsChanged(newFlavors);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFFD00000).withOpacity(0.2)
                        : Colors.grey[50],
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFFD00000)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      flavor,
                      style: TextStyle(
                        color: isSelected 
                            ? const Color(0xFFC00000)
                            : Colors.grey[700],
                        fontWeight: isSelected 
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 8),
        Text(
          'Tap flavors to select/deselect them',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
