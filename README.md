# SQL-School-Management-System
Système complet de gestion académique sous SQL Server : Architecture relationnelle, simulation de +10 000 enregistrements, analyses de performances via des vues complexes et gestion de la sécurité (RBAC).
🏫 Système de Gestion de Collège & Analyse de Données (SQL Server)
📌 Présentation
Ce projet consiste en la conception et l'implémentation d'une base de données relationnelle complète pour un établissement scolaire. L'objectif est de passer de la donnée brute (notes d'élèves) à de la donnée décisionnelle (moyennes générales et verdicts automatisés).

C'est un projet de bout en bout démontrant des compétences en Architecture de données, SQL Avancé et Gouvernance.

🛠️ Stack Technique
Moteur : SQL Server (T-SQL)

Outil : SQL Server Management Studio (SSMS)

Concepts utilisés : Contraintes d'intégrité, Boucles WHILE, Algorithmes de simulation, Vues complexes imbriquées, Sécurité RBAC.

🚀 Points Forts du Projet
1. Architecture Relationnelle Robuste
Modélisation de 4 tables clés : Classes, Etudiants, Matieres, Notes.

Gestion de l'intégrité avec des Clés Étrangères et des suppressions en cascade (ON DELETE CASCADE).

2. Simulation de Données Massives (Data Gen)
Utilisation d'un script SQL automatisé pour générer 300 élèves et environ 10 000 notes.

Mise en place d'un algorithme de "Profil de performance" (@Perf) pour simuler des résultats réalistes (élèves brillants, moyens ou en difficulté).

3. Couche Analytique (Vues)
Calcul des moyennes par matière : Pondération automatique entre contrôles continus et examens finaux.

Calcul de la Moyenne Générale : Utilisation des coefficients réels du système scolaire français.

Logique Décisionnelle : Attribution automatique des mentions (Félicitations, Admis, Avertissement).

4. Sécurité & Gestion des Rôles
Création de rôles spécifiques (Role_Enseignant, Role_Direction).

Sécurisation des accès : Les enseignants peuvent saisir des notes, tandis que la direction seule accède aux rapports de conseils de classe.


📊 Exemple de Résultat (Requête sur les Vues)
Élève,Moyenne Générale,Verdict
NOM_10,16.45,Félicitations
NOM_42,11.20,Admis
NOM_88,08.15,Avertissement
