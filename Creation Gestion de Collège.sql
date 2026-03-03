/* =============================================================================
PROJET : Système de Gestion et d'Analyse de Performance Académique (Collège)
AUTEUR : Ali Salia (Data Analyst Junior / Manager Base de données)
DESCRIPTION : Architecture SQL Server complète, simulation de 300 élèves, 
              calculs de moyennes pondérées et gestion de la sécurité.
=============================================================================
*/

-- 1. CRÉATION DE LA STRUCTURE
CREATE DATABASE GestionCollege_2026;
GO
USE GestionCollege_2026;
GO

CREATE TABLE Classes (
    ClasseID INT PRIMARY KEY IDENTITY(1,1),
    NomClasse NVARCHAR(20) NOT NULL
);

CREATE TABLE Etudiants (
    EtudiantID INT PRIMARY KEY IDENTITY(1,1),
    Nom NVARCHAR(50) NOT NULL,
    Prenom NVARCHAR(50) NOT NULL,
    ClasseID INT FOREIGN KEY REFERENCES Classes(ClasseID)
);

CREATE TABLE Matieres (
    MatiereID INT PRIMARY KEY IDENTITY(1,1),
    NomMatiere NVARCHAR(50) NOT NULL,
    Coefficient INT DEFAULT 2
);

CREATE TABLE Notes (
    NoteID INT PRIMARY KEY IDENTITY(1,1),
    EtudiantID INT FOREIGN KEY REFERENCES Etudiants(EtudiantID),
    MatiereID INT FOREIGN KEY REFERENCES Matieres(MatiereID) ON DELETE CASCADE,
    Trimestre INT CHECK (Trimestre IN (1, 2, 3)),
    TypeNote NVARCHAR(20) CHECK (TypeNote IN ('Controle', 'Examen')),
    ValeurNote DECIMAL(4,2) CHECK (ValeurNote BETWEEN 0 AND 20),
    DateSaisie DATETIME DEFAULT GETDATE()
);
GO

-- 2. INSERTION DES DONNÉES DE BASE (MODÈLE FRANÇAIS)
INSERT INTO Classes (NomClasse) VALUES ('6EME-A'), ('5EME-A'), ('4EME-A');

INSERT INTO Matieres (NomMatiere, Coefficient) VALUES 
(N'Français', 4), (N'Mathématiques', 4), (N'Histoire-Géo', 3), 
(N'Anglais (LV1)', 3), (N'SVT', 2), (N'Physique-Chimie', 2), 
(N'EPS', 2), (N'Arts Plastiques', 1);
GO

-- 3. GÉNÉRATION MASSIVE (300 ÉLÈVES ET ~7000 NOTES)
DECLARE @i INT = 1;
WHILE @i <= 300 BEGIN
    INSERT INTO Etudiants (Nom, Prenom, ClasseID) 
    VALUES (CONCAT('NOM_', @i), CONCAT('PRENOM_', @i), (@i % 3) + 1);
    SET @i = @i + 1;
END;
GO

DECLARE @EtudiantID INT = 1;
DECLARE @MatiereID INT;
DECLARE @Perf INT;
WHILE @EtudiantID <= 300 BEGIN
    SET @Perf = ABS(CHECKSUM(NEWID()) % 8); -- Simulation de profils variés
    SET @MatiereID = 1;
    WHILE @MatiereID <= 8 BEGIN
        -- 2 Contrôles + 1 Examen par matière
        INSERT INTO Notes (EtudiantID, MatiereID, Trimestre, TypeNote, ValeurNote) VALUES 
        (@EtudiantID, @MatiereID, 1, 'Controle', RAND()*10 + @Perf + 2),
        (@EtudiantID, @MatiereID, 1, 'Controle', RAND()*10 + @Perf + 2),
        (@EtudiantID, @MatiereID, 1, 'Examen', RAND()*10 + @Perf + 1);
        SET @MatiereID = @MatiereID + 1;
    END
    SET @EtudiantID = @EtudiantID + 1;
END;
-- Nettoyage des notes > 20
UPDATE Notes SET ValeurNote = 20 WHERE ValeurNote > 20;
GO

-- 4. COUCHE ANALYTIQUE (VUES)
CREATE VIEW Vue_Moyennes_Matieres AS
SELECT E.Nom, E.Prenom, M.NomMatiere, M.Coefficient,
    ROUND((AVG(CASE WHEN N.TypeNote = 'Controle' THEN N.ValeurNote END) + 
     MAX(CASE WHEN N.TypeNote = 'Examen' THEN N.ValeurNote END)) / 2, 2) AS Moyenne_Matiere
FROM Etudiants E
JOIN Notes N ON E.EtudiantID = N.EtudiantID
JOIN Matieres M ON N.MatiereID = M.MatiereID
GROUP BY E.Nom, E.Prenom, M.NomMatiere, M.Coefficient;
GO

CREATE VIEW Vue_Conseil_De_Classe AS
SELECT Nom, Prenom, 
    ROUND(SUM(Moyenne_Matiere * Coefficient) / SUM(Coefficient), 2) AS Moyenne_Generale,
    CASE 
        WHEN SUM(Moyenne_Matiere * Coefficient) / SUM(Coefficient) >= 16 THEN 'Félicitations'
        WHEN SUM(Moyenne_Matiere * Coefficient) / SUM(Coefficient) >= 10 THEN 'Admis'
        ELSE 'Avertissement'
    END AS Verdict
FROM Vue_Moyennes_Matieres
GROUP BY Nom, Prenom;
GO

-- 5. SÉCURITÉ (DATABASE MANAGEMENT)
CREATE ROLE Role_Enseignant;
GRANT SELECT ON Etudiants TO Role_Enseignant;
GRANT SELECT, INSERT ON Notes TO Role_Enseignant;
GRANT SELECT ON Vue_Moyennes_Matieres TO Role_Enseignant;

CREATE ROLE Role_Direction;
GRANT SELECT ON Vue_Conseil_De_Classe TO Role_Direction;
GO