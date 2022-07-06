import 'dart:io';
import 'package:flutter/material.dart';

class Filter {
  final File? img;
  final Color? color;

  Filter({required this.img, required this.color});

  // Data
  static List<Filter> filters(File? img) {
    return <Filter>[
      Filter(img: null, color: null),
      Filter(img: img, color: Colors.black),
      Filter(img: img, color: Colors.yellow),
      Filter(img: img, color: Colors.red),
      Filter(img: img, color: Colors.green),
      Filter(img: img, color: Colors.blue),
      Filter(img: img, color: Colors.orange),
      Filter(img: img, color: Colors.brown),
      Filter(img: img, color: Colors.grey),
      Filter(img: img, color: Colors.pink),
      Filter(img: img, color: Colors.purple),
    ];
  }
}
