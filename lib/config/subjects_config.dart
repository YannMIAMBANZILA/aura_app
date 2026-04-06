import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';

class SubjectsConfig {
  static final List<Map<String, dynamic>> defaultSubjects = [
    {'name': 'Maths', 'icon': Icons.calculate, 'color': AuraColors.cyan},
    {'name': 'Français', 'icon': Icons.menu_book, 'color': AuraColors.purple},
    {'name': 'Physique', 'icon': Icons.science, 'color': AuraColors.green},
    {'name': 'Histoire', 'icon': Icons.history_edu, 'color': AuraColors.orange},
    {'name': 'Anglais', 'icon': Icons.translate, 'color': AuraColors.cyan},
    {'name': 'Philo', 'icon': Icons.psychology, 'color': AuraColors.purple},
  ];

  static final Map<String, List<Map<String, dynamic>>> gradeSubjectsData = {
    '6ème': [
      {'name': 'Maths', 'icon': Icons.calculate, 'color': AuraColors.cyan},
      {'name': 'Français', 'icon': Icons.menu_book, 'color': AuraColors.purple},
      {'name': 'Histoire-Géo', 'icon': Icons.public, 'color': AuraColors.orange},
      {'name': 'SVT', 'icon': Icons.eco, 'color': AuraColors.green},
      {'name': 'Anglais', 'icon': Icons.translate, 'color': AuraColors.cyan},
    ],
    '5ème': [
      {'name': 'Maths', 'icon': Icons.calculate, 'color': AuraColors.cyan},
      {'name': 'Français', 'icon': Icons.menu_book, 'color': AuraColors.purple},
      {'name': 'Histoire-Géo', 'icon': Icons.public, 'color': AuraColors.orange},
      {'name': 'SVT', 'icon': Icons.eco, 'color': AuraColors.green},
      {'name': 'Physique-Chimie', 'icon': Icons.science, 'color': AuraColors.electricCyan},
      {'name': 'Anglais', 'icon': Icons.translate, 'color': AuraColors.cyan},
    ],
    '4ème': [
      {'name': 'Maths', 'icon': Icons.calculate, 'color': AuraColors.cyan},
      {'name': 'Français', 'icon': Icons.menu_book, 'color': AuraColors.purple},
      {'name': 'Histoire-Géo', 'icon': Icons.public, 'color': AuraColors.orange},
      {'name': 'SVT', 'icon': Icons.eco, 'color': AuraColors.green},
      {'name': 'Physique-Chimie', 'icon': Icons.science, 'color': AuraColors.electricCyan},
      {'name': 'Anglais', 'icon': Icons.translate, 'color': AuraColors.cyan},
    ],
    '3ème': [
      {'name': 'Maths', 'icon': Icons.calculate, 'color': AuraColors.cyan},
      {'name': 'Français', 'icon': Icons.menu_book, 'color': AuraColors.purple},
      {'name': 'Histoire-Géo', 'icon': Icons.public, 'color': AuraColors.orange},
      {'name': 'SVT', 'icon': Icons.eco, 'color': AuraColors.green},
      {'name': 'Physique-Chimie', 'icon': Icons.science, 'color': AuraColors.electricCyan},
      {'name': 'Anglais', 'icon': Icons.translate, 'color': AuraColors.cyan},
    ],
    'Seconde': [
      {'name': 'Maths', 'icon': Icons.calculate, 'color': AuraColors.cyan},
      {'name': 'Français', 'icon': Icons.menu_book, 'color': AuraColors.purple},
      {'name': 'Histoire-Géo', 'icon': Icons.public, 'color': AuraColors.orange},
      {'name': 'SVT', 'icon': Icons.eco, 'color': AuraColors.green},
      {'name': 'Physique-Chimie', 'icon': Icons.science, 'color': AuraColors.electricCyan},
      {'name': 'Anglais', 'icon': Icons.translate, 'color': AuraColors.cyan},
    ],
    'Première': [
      {'name': 'Maths', 'icon': Icons.calculate, 'color': AuraColors.cyan},
      {'name': 'Français', 'icon': Icons.menu_book, 'color': AuraColors.purple},
      {'name': 'Histoire-Géo', 'icon': Icons.public, 'color': AuraColors.orange},
      {'name': 'Enseignement Scientifique', 'icon': Icons.science, 'color': AuraColors.green},
      {'name': 'Spécialité 1', 'icon': Icons.star, 'color': AuraColors.electricCyan},
      {'name': 'Spécialité 2', 'icon': Icons.star_half, 'color': AuraColors.purple},
      {'name': 'Anglais', 'icon': Icons.translate, 'color': AuraColors.cyan},
    ],
    'Terminale': [
      {'name': 'Maths', 'icon': Icons.calculate, 'color': AuraColors.cyan},
      {'name': 'Philo', 'icon': Icons.psychology, 'color': AuraColors.purple},
      {'name': 'Histoire-Géo', 'icon': Icons.public, 'color': AuraColors.orange},
      {'name': 'Enseignement Scientifique', 'icon': Icons.science, 'color': AuraColors.green},
      {'name': 'Spécialité 1', 'icon': Icons.star, 'color': AuraColors.electricCyan},
      {'name': 'Spécialité 2', 'icon': Icons.star_half, 'color': AuraColors.purple},
      {'name': 'Anglais', 'icon': Icons.translate, 'color': AuraColors.cyan},
    ],
  };

  static List<Map<String, dynamic>> getSubjectsForGrade(String? gradeLevel) {
    if (gradeLevel == null || !gradeSubjectsData.containsKey(gradeLevel)) {
      return defaultSubjects;
    }
    return gradeSubjectsData[gradeLevel]!;
  }
}
