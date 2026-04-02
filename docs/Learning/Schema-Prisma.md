# Transformation du Modèle Relationnel vers Prisma (RIMA 2)

Ce document détaille la méthodologie utilisée pour transcrire le **MCD (Modèle Conceptuel)** et le **MLD (Modèle Logique)** de l'application vers le schéma technique **Prisma ORM**.

## 🧩 Méthodologie de passage (Étape par étape)

### 1. Des Tables aux Modèles (`model`)
En SQL (MLD), les tables sont souvent nommées au pluriel (`users`). Prisma utilise le **singulier** pour définir ses modèles (`User`), car chaque modèle représente une **instance** (un objet unique) manipulée dans le code TypeScript.

* **Mapping SQL** : Utilisation de l'attribut `@@map("table_name")` pour conserver la convention *snake_case* en base de données tout en utilisant le *camelCase* dans le code applicatif pour une meilleure intégration JS/TS.

### 2. Typage et Sécurisation (Enums)
Contrairement au SQL classique qui utilise souvent des `VARCHAR` pour les statuts, Prisma permet l'utilisation d'**Enums** natifs.
* **Avantage** : Cela garantit que le statut d'un verbe ne peut être que `TO_LEARN`, `LEARNING` ou `MASTERED`. Toute autre valeur provoquera une erreur de validation avant même l'écriture en base.

### 3. La Logique des Relations (Le "Cœur" de Prisma)
C'est l'étape la plus cruciale. En SQL, on ne définit que la **Clé Étrangère (FK)**. Dans Prisma, la relation est **bidirectionnelle**.

* **Exemple : User <-> UserVerb**
    * **Côté User** : On déclare une liste `userVerbs UserVerb[]`. Cela permet d'accéder aux données via `user.userVerbs` en JS.
    * **Côté UserVerb** : On déclare le champ de stockage (`userId Int`) **ET** le champ de relation abstraite (`user User @relation(...)`). 
    * **Lien technique** : Prisma utilise ces informations pour générer les `JOIN` SQL automatiquement lors des requêtes.

### 4. Application des Contraintes Métier
Le schéma Prisma traduit les règles de gestion définies dans le MCD :
* **Unicité Composite** : La contrainte `@@unique([userId, verbId])` dans `UserVerb` empêche qu'un utilisateur possède deux fois le même verbe dans son cahier personnel.
* **Cascade** : L'instruction `onDelete: Cascade` assure que si un `Verb` est supprimé du dictionnaire global, toutes les `Conjugations` et `Translations` associées sont nettoyées automatiquement.
* **Gestion temporelle** : `@default(now())` gère la création, tandis que `@updatedAt` automatise la mise à jour des horodatages.

---

## 🛠 Table de Correspondance Technique

| Concept MCD / MLD | Syntaxe Prisma | Usage dans RIMA 2 |
| :--- | :--- | :--- |
| **Entité / Table** | `model Name { ... }` | `model Verb`, `model User` |
| **Clé Primaire** | `@id @default(autoincrement())` | IDs numériques auto-gérés |
| **Clé Étrangère** | `fieldId Int` | `categoryId`, `userId` |
| **Relation d'objet** | `relationName RelationType` | Permet le "Include" en TypeScript |
| **Champ Optionnel** | `Type?` (ex: `String?`) | `usageNote` ou `transliteration` |
| **Contrainte Composite** | `@@unique([A, B])` | Unicité Vote / UserVerbs |
| **Renommage SQL** | `@map` / `@@map` | Compatibilité convention snake_case |

---

## 💡 Note pour le Développeur
Après chaque modification de ce schéma, ne pas oublier de lancer la commande suivante pour synchroniser la base de données et mettre à jour le client TypeScript :

```bash
npx prisma migrate dev --name description_du_changement