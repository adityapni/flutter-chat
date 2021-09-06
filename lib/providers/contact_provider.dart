import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';

class ContactProvider with ChangeNotifier{
  Iterable<Contact> contacts= [];
  Iterable<Item> phones =[];

  ContactProvider(){
    getContacts();
  }

  getContacts() async {
   contacts = await ContactsService.getContacts(withThumbnails: false);
   // phones = contacts.;
   notifyListeners();
  }



}