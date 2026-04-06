class CurriculumConfig {
  static final Map<String, Map<String, List<String>>> curriculumData = {
    '6ème': {
      'Maths': ['Nombres entiers et décimaux', 'Fractions', 'Proportionnalité', 'Géométrie de base', 'Aires et périmètres', 'Symétrie axiale'],
      'Français': ['Le monstre, aux limites de l\'humain', 'Récits de création', 'La poésie', 'Le théâtre'],
      'Histoire-Géo': ['La Révolution néolithique', 'Premiers États, premières écritures', 'Le monde des cités grecques', 'L\'Empire romain', 'Habiter une métropole'],
      'SVT': ['La Terre, une planète peuplée par des êtres vivants', 'Le vivant et son évolution', 'Le corps humain et la santé'],
      'Anglais': ['Se présenter', 'La famille', 'Les routines quotidiennes', 'Dire l\'heure', 'Les animaux'],
    },
    '5ème': {
      'Maths': ['Nombres relatifs', 'Fractions', 'Proportionnalité', 'Symétrie centrale', 'Triangles', 'Statistiques et Probabilités', 'Calcul littéral'],
      'Français': ['Le voyage et l\'aventure', 'Héros et héroïsme', 'La comédie', 'L\'être humain est-il maître de la nature ?'],
      'Histoire-Géo': ['Chrétientés et islam (VIe-XIIIe siècles)', 'Société, Église et pouvoir politique', 'La croissance démographique', 'L\'énergie et l\'eau'],
      'SVT': ['Respiration et occupation des milieux', 'Fonctionnement de l\'organisme', 'Géologie externe'],
      'Physique-Chimie': ['L\'eau dans notre environnement', 'Les mélanges', 'Les circuits électriques simples'],
      'Anglais': ['Les tâches ménagères', 'Donner des conseils', 'Les règles scolaires', 'Parler de ses capacités', 'Le passé (prétérit)'],
    },
    '4ème': {
      'Maths': ['Nombres relatifs en écriture fractionnaire', 'Puissances', 'Théorème de Pythagore', 'Équations', 'Proportionnalité', 'Cylindres et cônes'],
      'Français': ['Dire l\'amour', 'Individu et société : confrontations', 'La fiction pour interroger le réel', 'Informer, s\'informer'],
      'Histoire-Géo': ['Le XVIIIe siècle et la Révolution', 'L\'Europe de la révolution industrielle', 'L\'urbanisation du monde', 'Les migrations transnationales'],
      'SVT': ['Reproduction et environnement', 'La transmission de la vie chez l\'Homme', 'L\'activité interne du globe'],
      'Physique-Chimie': ['De la matière aux molécules', 'Les lois du courant électrique', 'Lumière et couleurs'],
      'Anglais': ['Les actions en cours (be+ing)', 'Les prédictions', 'L\'obligation et l\'interdiction', 'Histoires de détectives'],
    },
    '3ème': {
      'Maths': ['Théorème de Thalès', 'Trigonométrie', 'Calcul littéral et équations', 'Fonctions affines', 'Statistiques et probabilités', 'Notions de géométrie dans l\'espace'],
      'Français': ['Se raconter, se représenter', 'Dénoncer les travers de la société', 'Vision poétique du monde', 'Agir dans la cité'],
      'Histoire-Géo': ['L\'Europe et le monde (1914-1945)', 'Le monde depuis 1945', 'La République française', 'Aménagement du territoire'],
      'SVT': ['Génétique', 'Évolution des espèces', 'Système nerveux et immunitaire'],
      'Physique-Chimie': ['La gravitation', 'L\'énergie cinétique', 'Les ions et le pH', 'Piles et énergie chimique'],
      'Anglais': ['L\'expérience passée (Present Perfect)', 'La voix passive', 'Le discours indirect', 'Conditionnel'],
    },
    'Seconde': {
      'Maths': ['Fonctions de référence', 'Vecteurs', 'Statistiques', 'Probabilités', 'Équations et inéquations', 'Géométrie repérée'],
      'Français': ['La poésie du XIXe au XXIe siècle', 'Le roman et le récit', 'Le théâtre du XVIIe au XXIe siècle', 'La littérature d\'idées'],
      'Histoire-Géo': ['Le monde méditerranéen', 'Révolutions et dynamiques', 'Transition démographique', 'Transition écologique', 'L\'Afrique du Sud'],
      'SVT': ['Organisation du vivant', 'Biodiversité et évolution', 'Procréation et sexualité', 'Micro-organismes et santé'],
      'Physique-Chimie': ['Constitution de la matière', 'Mouvements et forces', 'Ondes et signaux', 'Lumière'],
      'Anglais': ['L\'art de vivre ensemble', 'Mémoire', 'Sentiments', 'Visions d\'avenir', 'Création et rapport aux arts'],
    },
    'Première': {
      'Maths': ['Dérivation', 'Suites numériques', 'Fonction exponentielle', 'Trigonométrie', 'Probabilités conditionnelles', 'Produit scalaire'],
      'Français': ['La poésie', 'La littérature d\'idées', 'Le roman', 'Le théâtre'],
      'Histoire-Géo': ['L\'Europe face aux révolutions', 'La France dans le monde (XIXe)', 'La métropolisation', 'Espaces ruraux'],
      'Enseignement Scientifique': ['Une longue histoire de la matière', 'Le Soleil, notre source d\'énergie', 'La Terre, un astre singulier', 'Son et musique'],
      'Anglais': ['Identités et échanges', 'Espace privé et espace public', 'Art et pouvoir', 'Citoyenneté et mondes virtuels'],
    },
    'Terminale': {
      'Maths': ['Limites de fonctions', 'Continuité', 'Suites', 'Logarithme népérien', 'Primitives et équations différentielles', 'Géométrie dans l\'espace', 'Lois à densité'],
      'Philo': ['L\'art', 'Le bonheur', 'La conscience', 'Le devoir', 'L\'État', 'L\'inconscient', 'La justice', 'Le langage', 'La liberté', 'La nature', 'La raison', 'La religion', 'La science', 'La technique', 'Le temps', 'Le travail', 'La vérité'],
      'Histoire-Géo': ['Le monde depuis 1945', 'Guerre froide', 'Colonisation et décolonisation', 'La mondialisation en fonctionnement'],
      'Enseignement Scientifique': ['Science, climat et société', 'Le futur des énergies', 'Une histoire du vivant', 'Intelligence Artificielle'],
      'Anglais': ['Fictions et réalités', 'Diversité et inclusion', 'Territoire et mémoire', 'Innovations scientifiques et responsabilité'],
    },
  };

  /// Récupère la liste des chapitres pour un niveau et une matière donnés.
  /// Si non trouvés, retourne une liste par défaut avec 3 chapitres.
  static List<String> getChapters(String gradeLevel, String subject) {
    if (curriculumData.containsKey(gradeLevel)) {
      if (curriculumData[gradeLevel]!.containsKey(subject)) {
        return curriculumData[gradeLevel]![subject]!;
      }
    }
    // Liste de secours
    return ['Chapitre 1', 'Chapitre 2', 'Chapitre 3'];
  }
}
