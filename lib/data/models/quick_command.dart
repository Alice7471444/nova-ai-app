import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class QuickCommand extends Equatable {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String action;
  final bool isActive;

  const QuickCommand({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.action,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, description, icon, action, isActive];
}

class QuickCommands {
  static const List<QuickCommand> defaultCommands = [
    QuickCommand(
      id: '1',
      name: 'Send Message',
      description: 'Send a text message',
      icon: Icons.message,
      action: 'send_message',
    ),
    QuickCommand(
      id: '2',
      name: 'Make Call',
      description: 'Start a voice call',
      icon: Icons.phone,
      action: 'make_call',
    ),
    QuickCommand(
      id: '3',
      name: 'Set Reminder',
      description: 'Set a reminder',
      icon: Icons.alarm,
      action: 'set_reminder',
    ),
    QuickCommand(
      id: '4',
      name: 'Open App',
      description: 'Open an application',
      icon: Icons.apps,
      action: 'open_app',
    ),
    QuickCommand(
      id: '5',
      name: 'Search',
      description: 'Search the web',
      icon: Icons.search,
      action: 'search',
    ),
    QuickCommand(
      id: '6',
      name: 'Weather',
      description: 'Check weather',
      icon: Icons.cloud,
      action: 'weather',
    ),
  ];
}
