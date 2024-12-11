import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

class AddressAutocomplete extends StatefulWidget {
  final Function(String) onSelected;
  final TextEditingController controller;

  const AddressAutocomplete({required this.onSelected, required this.controller, Key? key}) : super(key: key);

  @override
  _AddressAutocompleteState createState() => _AddressAutocompleteState();
}

class _AddressAutocompleteState extends State<AddressAutocomplete> {
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];

  @override
  void initState() {
    super.initState();
    String apiKey = 'AIzaSyC65Rjo_uj5HZhQYMqw3Np87ktG_nB85GI';  // Reemplaza con tu clave de API de Google Places
    googlePlace = GooglePlace(apiKey);
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.controller,  // Usa el controlador que viene como propiedad
          decoration: const InputDecoration(labelText: 'Dirección'),
          onChanged: (value) {
            if (value.isNotEmpty) {
              autoCompleteSearch(value);
            } else {
              setState(() {
                predictions = [];
              });
            }
          },
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: predictions.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(predictions[index].description ?? ''),
              onTap: () {
                String selectedDescription = predictions[index].description ?? '';
                widget.controller.text = selectedDescription;
                widget.onSelected(selectedDescription);
                setState(() {
                  predictions = [];
                });
              },
            );
          },
        ),
      ],
    );
  }
}
