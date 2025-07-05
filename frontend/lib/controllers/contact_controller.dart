import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Contact {
  final String id;
  final String Name;
  final String Email;
  final String phone;
  final String address;

  Contact({
    required this.id,
    required this.Name,
    required this.Email,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': Name,
      'email': Email,
      'phone': phone,
      'address': address,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      Name: json['name'],
      Email: json['email'],
      phone: json['phone'],
      address: json['address'],
    );
  }
}

class UserContact extends GetxController {
  var contacts = <Contact>[].obs;

  void addContact(Contact contact) {
    contacts.add(contact);
  }

  void removeContact(String id) {
    contacts.removeWhere((contact) => contact.id == id);
  }

  Contact? getContactById(String id) {
    return contacts.firstWhereOrNull((contact) => contact.id == id);
  }

  List<Contact> get allContacts => contacts.toList();
}