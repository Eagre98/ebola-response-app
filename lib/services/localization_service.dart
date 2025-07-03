import 'package:flutter/material.dart';

enum AppLanguage { english, french, italian }

class LocalizationService {
  static AppLanguage _currentLanguage = AppLanguage.english;

  static AppLanguage get currentLanguage => _currentLanguage;

  static void setLanguage(AppLanguage language) {
    _currentLanguage = language;
  }

  static final Map<String, Map<AppLanguage, String>> _translations = {
    // Welcome Screen
    'welcome_title': {
      AppLanguage.english: 'Ebola Response',
      AppLanguage.french: 'Réponse Ebola',
      AppLanguage.italian: 'Risposta Ebola',
    },
    'welcome_subtitle': {
      AppLanguage.english: 'Congo Region',
      AppLanguage.french: 'Région du Congo',
      AppLanguage.italian: 'Regione del Congo',
    },
    'get_information': {
      AppLanguage.english: 'Get Information (Chatbot)',
      AppLanguage.french: 'Obtenir des informations (Chatbot)',
      AppLanguage.italian: 'Ottieni informazioni (Chatbot)',
    },
    'apply_medical_team': {
      AppLanguage.english: 'Apply for Medical Team',
      AppLanguage.french: 'Postuler pour l\'équipe médicale',
      AppLanguage.italian: 'Candidati per il team medico',
    },
    'staff_portal_login': {
      AppLanguage.english: 'Staff Portal Login',
      AppLanguage.french: 'Connexion portail personnel',
      AppLanguage.italian: 'Accesso portale staff',
    },

    // Authentication
    'login': {
      AppLanguage.english: 'Login',
      AppLanguage.french: 'Connexion',
      AppLanguage.italian: 'Accesso',
    },
    'register': {
      AppLanguage.english: 'Register',
      AppLanguage.french: 'S\'inscrire',
      AppLanguage.italian: 'Registrati',
    },
    'email': {
      AppLanguage.english: 'Email',
      AppLanguage.french: 'E-mail',
      AppLanguage.italian: 'Email',
    },
    'password': {
      AppLanguage.english: 'Password',
      AppLanguage.french: 'Mot de passe',
      AppLanguage.italian: 'Password',
    },
    'first_name': {
      AppLanguage.english: 'First Name',
      AppLanguage.french: 'Prénom',
      AppLanguage.italian: 'Nome',
    },
    'last_name': {
      AppLanguage.english: 'Last Name',
      AppLanguage.french: 'Nom de famille',
      AppLanguage.italian: 'Cognome',
    },
    'sign_in_google': {
      AppLanguage.english: 'Sign in with Google',
      AppLanguage.french: 'Se connecter avec Google',
      AppLanguage.italian: 'Accedi con Google',
    },
    'forgot_password': {
      AppLanguage.english: 'Forgot Password?',
      AppLanguage.french: 'Mot de passe oublié?',
      AppLanguage.italian: 'Password dimenticata?',
    },

    // Dashboard
    'dashboard': {
      AppLanguage.english: 'Dashboard',
      AppLanguage.french: 'Tableau de bord',
      AppLanguage.italian: 'Dashboard',
    },
    'total_alerts': {
      AppLanguage.english: 'Total Alerts',
      AppLanguage.french: 'Total des alertes',
      AppLanguage.italian: 'Avvisi totali',
    },
    'open_alerts': {
      AppLanguage.english: 'Open Alerts',
      AppLanguage.french: 'Alertes ouvertes',
      AppLanguage.italian: 'Avvisi aperti',
    },
    'my_alerts': {
      AppLanguage.english: 'My Alerts',
      AppLanguage.french: 'Mes alertes',
      AppLanguage.italian: 'I miei avvisi',
    },
    'create_alert': {
      AppLanguage.english: 'Create Alert',
      AppLanguage.french: 'Créer une alerte',
      AppLanguage.italian: 'Crea avviso',
    },

    // Alerts
    'alert_title': {
      AppLanguage.english: 'Alert Title',
      AppLanguage.french: 'Titre de l\'alerte',
      AppLanguage.italian: 'Titolo avviso',
    },
    'description': {
      AppLanguage.english: 'Description',
      AppLanguage.french: 'Description',
      AppLanguage.italian: 'Descrizione',
    },
    'category': {
      AppLanguage.english: 'Category',
      AppLanguage.french: 'Catégorie',
      AppLanguage.italian: 'Categoria',
    },
    'suspected_case': {
      AppLanguage.english: 'Suspected Case',
      AppLanguage.french: 'Cas suspect',
      AppLanguage.italian: 'Caso sospetto',
    },
    'confirmed_case': {
      AppLanguage.english: 'Confirmed Case',
      AppLanguage.french: 'Cas confirmé',
      AppLanguage.italian: 'Caso confermato',
    },
    'outbreak': {
      AppLanguage.english: 'Outbreak',
      AppLanguage.french: 'Épidémie',
      AppLanguage.italian: 'Focolaio',
    },
    'location': {
      AppLanguage.english: 'Location',
      AppLanguage.french: 'Emplacement',
      AppLanguage.italian: 'Posizione',
    },
    'add_images': {
      AppLanguage.english: 'Add Images',
      AppLanguage.french: 'Ajouter des images',
      AppLanguage.italian: 'Aggiungi immagini',
    },
    'add_videos': {
      AppLanguage.english: 'Add Videos',
      AppLanguage.french: 'Ajouter des vidéos',
      AppLanguage.italian: 'Aggiungi video',
    },

    // Status
    'status': {
      AppLanguage.english: 'Status',
      AppLanguage.french: 'Statut',
      AppLanguage.italian: 'Stato',
    },
    'open': {
      AppLanguage.english: 'Open',
      AppLanguage.french: 'Ouvert',
      AppLanguage.italian: 'Aperto',
    },
    'assigned': {
      AppLanguage.english: 'Assigned',
      AppLanguage.french: 'Assigné',
      AppLanguage.italian: 'Assegnato',
    },
    'in_progress': {
      AppLanguage.english: 'In Progress',
      AppLanguage.french: 'En cours',
      AppLanguage.italian: 'In corso',
    },
    'closed': {
      AppLanguage.english: 'Closed',
      AppLanguage.french: 'Fermé',
      AppLanguage.italian: 'Chiuso',
    },

    // Actions
    'save': {
      AppLanguage.english: 'Save',
      AppLanguage.french: 'Enregistrer',
      AppLanguage.italian: 'Salva',
    },
    'cancel': {
      AppLanguage.english: 'Cancel',
      AppLanguage.french: 'Annuler',
      AppLanguage.italian: 'Annulla',
    },
    'delete': {
      AppLanguage.english: 'Delete',
      AppLanguage.french: 'Supprimer',
      AppLanguage.italian: 'Elimina',
    },
    'assign': {
      AppLanguage.english: 'Assign',
      AppLanguage.french: 'Assigner',
      AppLanguage.italian: 'Assegna',
    },
    'close_alert': {
      AppLanguage.english: 'Close Alert',
      AppLanguage.french: 'Fermer l\'alerte',
      AppLanguage.italian: 'Chiudi avviso',
    },
    'approve': {
      AppLanguage.english: 'Approve',
      AppLanguage.french: 'Approuver',
      AppLanguage.italian: 'Approva',
    },
    'reject': {
      AppLanguage.english: 'Reject',
      AppLanguage.french: 'Rejeter',
      AppLanguage.italian: 'Rifiuta',
    },

    // Users
    'users': {
      AppLanguage.english: 'Users',
      AppLanguage.french: 'Utilisateurs',
      AppLanguage.italian: 'Utenti',
    },
    'pending_approval': {
      AppLanguage.english: 'Pending Approval',
      AppLanguage.french: 'En attente d\'approbation',
      AppLanguage.italian: 'In attesa di approvazione',
    },
    'medical_team': {
      AppLanguage.english: 'Medical Team',
      AppLanguage.french: 'Équipe médicale',
      AppLanguage.italian: 'Team medico',
    },
    'admin': {
      AppLanguage.english: 'Admin',
      AppLanguage.french: 'Administrateur',
      AppLanguage.italian: 'Amministratore',
    },
    'normal_user': {
      AppLanguage.english: 'Normal User',
      AppLanguage.french: 'Utilisateur normal',
      AppLanguage.italian: 'Utente normale',
    },

    // Chat
    'chat': {
      AppLanguage.english: 'Chat',
      AppLanguage.french: 'Chat',
      AppLanguage.italian: 'Chat',
    },
    'information_chatbot': {
      AppLanguage.english: 'Information Chatbot',
      AppLanguage.french: 'Chatbot d\'information',
      AppLanguage.italian: 'Chatbot informativo',
    },
    'type_message': {
      AppLanguage.english: 'Type your message...',
      AppLanguage.french: 'Tapez votre message...',
      AppLanguage.italian: 'Scrivi il tuo messaggio...',
    },
    'send': {
      AppLanguage.english: 'Send',
      AppLanguage.french: 'Envoyer',
      AppLanguage.italian: 'Invia',
    },

    // Settings
    'settings': {
      AppLanguage.english: 'Settings',
      AppLanguage.french: 'Paramètres',
      AppLanguage.italian: 'Impostazioni',
    },
    'language': {
      AppLanguage.english: 'Language',
      AppLanguage.french: 'Langue',
      AppLanguage.italian: 'Lingua',
    },
    'profile': {
      AppLanguage.english: 'Profile',
      AppLanguage.french: 'Profil',
      AppLanguage.italian: 'Profilo',
    },
    'logout': {
      AppLanguage.english: 'Logout',
      AppLanguage.french: 'Déconnexion',
      AppLanguage.italian: 'Disconnetti',
    },

    // Messages
    'success': {
      AppLanguage.english: 'Success',
      AppLanguage.french: 'Succès',
      AppLanguage.italian: 'Successo',
    },
    'error': {
      AppLanguage.english: 'Error',
      AppLanguage.french: 'Erreur',
      AppLanguage.italian: 'Errore',
    },
    'loading': {
      AppLanguage.english: 'Loading...',
      AppLanguage.french: 'Chargement...',
      AppLanguage.italian: 'Caricamento...',
    },
    'no_data': {
      AppLanguage.english: 'No data available',
      AppLanguage.french: 'Aucune donnée disponible',
      AppLanguage.italian: 'Nessun dato disponibile',
    },
    'alert_created': {
      AppLanguage.english: 'Alert created successfully',
      AppLanguage.french: 'Alerte créée avec succès',
      AppLanguage.italian: 'Avviso creato con successo',
    },
    'alert_updated': {
      AppLanguage.english: 'Alert updated successfully',
      AppLanguage.french: 'Alerte mise à jour avec succès',
      AppLanguage.italian: 'Avviso aggiornato con successo',
    },
    'user_approved': {
      AppLanguage.english: 'User approved successfully',
      AppLanguage.french: 'Utilisateur approuvé avec succès',
      AppLanguage.italian: 'Utente approvato con successo',
    },

    // Validation
    'field_required': {
      AppLanguage.english: 'This field is required',
      AppLanguage.french: 'Ce champ est obligatoire',
      AppLanguage.italian: 'Questo campo è obbligatorio',
    },
    'invalid_email': {
      AppLanguage.english: 'Please enter a valid email',
      AppLanguage.french: 'Veuillez saisir un e-mail valide',
      AppLanguage.italian: 'Inserisci un\'email valida',
    },
    'password_min_length': {
      AppLanguage.english: 'Password must be at least 6 characters',
      AppLanguage.french:
          'Le mot de passe doit comporter au moins 6 caractères',
      AppLanguage.italian: 'La password deve avere almeno 6 caratteri',
    },

    // Help Text
    'ebola_info_help': {
      AppLanguage.english:
          'Ask me anything about Ebola symptoms, prevention, or treatment.',
      AppLanguage.french:
          'Demandez-moi tout sur les symptômes, la prévention ou le traitement d\'Ebola.',
      AppLanguage.italian:
          'Chiedimi qualsiasi cosa sui sintomi, la prevenzione o il trattamento dell\'Ebola.',
    },
    'medical_team_application_help': {
      AppLanguage.english:
          'Your application will be reviewed by an administrator before granting access.',
      AppLanguage.french:
          'Votre candidature sera examinée par un administrateur avant d\'accorder l\'accès.',
      AppLanguage.italian:
          'La tua candidatura sarà esaminata da un amministratore prima di concedere l\'accesso.',
    },
  };

  static String translate(String key) {
    return _translations[key]?[_currentLanguage] ?? key;
  }

  static String get languageName {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.french:
        return 'Français';
      case AppLanguage.italian:
        return 'Italiano';
    }
  }

  static List<DropdownMenuItem<AppLanguage>> get languageDropdownItems {
    return [
      DropdownMenuItem(
        value: AppLanguage.english,
        child: Text('English'),
      ),
      DropdownMenuItem(
        value: AppLanguage.french,
        child: Text('Français'),
      ),
      DropdownMenuItem(
        value: AppLanguage.italian,
        child: Text('Italiano'),
      ),
    ];
  }
}
