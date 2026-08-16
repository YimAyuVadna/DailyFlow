import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

IconData getHabitIcon(String iconName) {
  switch (iconName) {
    // Health & Body
    case 'drop': return PhosphorIconsFill.drop;
    case 'heartbeat': return PhosphorIconsFill.heartbeat;
    case 'pill': return PhosphorIconsFill.pill;
    case 'apple': return PhosphorIconsFill.appleLogo;
    case 'carrot': return PhosphorIconsFill.carrot;
    case 'knife': return PhosphorIconsFill.knife;
    case 'scales': return PhosphorIconsFill.scales;
    case 'thermometer': return PhosphorIconsFill.thermometer;
    case 'bandaids': return PhosphorIconsFill.bandaids;
    case 'syringe': return PhosphorIconsFill.syringe;
    
    // Fitness
    case 'barbell': return PhosphorIconsFill.barbell;
    case 'footprints': return PhosphorIconsFill.footprints;
    case 'bicycle': return PhosphorIconsFill.bicycle;
    case 'swimmer': return PhosphorIconsFill.swimmingPool;
    case 'person': return PhosphorIconsFill.person;
    case 'soccer-ball': return PhosphorIconsFill.soccerBall;
    case 'timer': return PhosphorIconsFill.timer;
    case 'trophy': return PhosphorIconsFill.trophy;

    // Mind & Wellness
    case 'sparkle': return PhosphorIconsFill.sparkle;
    case 'moon': return PhosphorIconsFill.moon;
    case 'sun': return PhosphorIconsFill.sun;
    case 'brain': return PhosphorIconsFill.brain;
    case 'smiley': return PhosphorIconsFill.smiley;
    case 'wind': return PhosphorIconsFill.wind;
    case 'butterfly': return PhosphorIconsFill.butterfly;
    case 'flower': return PhosphorIconsFill.flowerLotus;

    // Learning
    case 'bookOpenText': return PhosphorIconsFill.bookOpenText;
    case 'pencil': return PhosphorIconsFill.pencil;
    case 'graduation-cap': return PhosphorIconsFill.graduationCap;
    case 'chalkboard': return PhosphorIconsFill.chalkboard;
    case 'translate': return PhosphorIconsFill.translate;
    case 'music-note': return PhosphorIconsFill.musicNote;
    case 'palette': return PhosphorIconsFill.palette;

    // Work & Productivity
    case 'fire': return PhosphorIconsFill.fire;
    case 'code': return PhosphorIconsFill.code;
    case 'target': return PhosphorIconsFill.target;
    case 'chart-line': return PhosphorIconsFill.chartLineUp;
    case 'briefcase': return PhosphorIconsFill.briefcase;
    case 'clock': return PhosphorIconsFill.clock;
    case 'list-checks': return PhosphorIconsFill.listChecks;
    case 'lightning': return PhosphorIconsFill.lightning;

    // Finance & Life
    case 'money': return PhosphorIconsFill.currencyDollar;
    case 'piggy-bank': return PhosphorIconsFill.piggyBank;
    case 'shopping-cart': return PhosphorIconsFill.shoppingCart;
    case 'house': return PhosphorIconsFill.house;
    case 'plant': return PhosphorIconsFill.plant;
    case 'dog': return PhosphorIconsFill.dog;
    case 'car': return PhosphorIconsFill.car;
    case 'recycle': return PhosphorIconsFill.recycle;

    // Social
    case 'users': return PhosphorIconsFill.users;
    case 'phone': return PhosphorIconsFill.phone;
    case 'chat': return PhosphorIconsFill.chatCircle;
    case 'hands-clapping': return PhosphorIconsFill.handsClapping;

    // General
    case 'star': return PhosphorIconsFill.star;
    case 'bed': return PhosphorIconsFill.bed;
    case 'check': 
    default: 
      return PhosphorIconsFill.checkCircle;
  }
}
