import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/create_event/model/event.dart';
import 'package:eventee/src/create_event/view_models/params/upload_event_params.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class AdminService {
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  final _imagePicker = ImagePicker();

  CollectionReference get _eventsCollection => _firestore.collection('events');

  Future<Object> fetchAllEvents() async {
    try {
      Stream<List<EventModel>> stream = _eventsCollection.snapshots().map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => EventModel.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList(),
      );

      return Success(response: stream);
    } catch (e) {
      return Failure(response: 'Fails to fetch all events: $e.');
    }
  }

  Future<Object> uploadEventDetail({required UploadEventParams params}) async {
    try {
      final imageResponse = await uploadEventImage(eventFile: params.imageUrl);

      if (imageResponse is Failure) {
        return Failure(response: imageResponse.response);
      }

      final imageUrl = (imageResponse as Success).response as String;
      DocumentReference eventId = _eventsCollection.doc();

      final event = EventModel(
        id: eventId.id,
        imageUrl: imageUrl,
        title: params.title,
        date: params.date,
        location: params.location,
        startTime: params.startTime,
        endTime: params.endTime,
        price: params.price,
        description: params.description,
        category: params.category,
      );

      await _eventsCollection.doc(eventId.id).set(event.toMap());

      return Success(response: 'Event uploaded successfully!');
    } catch (e) {
      return Failure(response: 'Failed to upload event detail: $e.');
    }
  }

  Future<Object> uploadEventImage({required File eventFile}) async {
    try {
      final eventImageId = randomAlphaNumeric(10);
      final ref = _storage.ref().child('event_images/$eventImageId');

      final uploadTask = ref.putFile(eventFile);
      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();

      return Success(response: downloadUrl);
    } catch (e) {
      return Failure(response: 'Failed to upload event image: $e.');
    }
  }

  Future<Object> pickEventImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1024,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return Failure(response: 'No image selected.');
      }

      return Success(response: File(pickedFile.path));
    } catch (e) {
      return Failure(response: 'Failed to pick event image: $e.');
    }
  }
}
