-- CreateEnum
CREATE TYPE "Role" AS ENUM ('MEMBER', 'ADMIN');

-- CreateEnum
CREATE TYPE "VerbStatus" AS ENUM ('TO_LEARN', 'LEARNING', 'MASTERED');

-- CreateEnum
CREATE TYPE "ProposalStatus" AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED');

-- CreateEnum
CREATE TYPE "VoteValue" AS ENUM ('APPROVE', 'REJECT');

-- CreateTable
CREATE TABLE "users" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'MEMBER',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sessions" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "token_hash" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "categories" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,

    CONSTRAINT "categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "verbs" (
    "id" SERIAL NOT NULL,
    "greek" TEXT NOT NULL,
    "transliteration" TEXT,
    "category_id" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "verbs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "translations" (
    "id" SERIAL NOT NULL,
    "verb_id" INTEGER NOT NULL,
    "french" TEXT NOT NULL,
    "usage_note" TEXT,

    CONSTRAINT "translations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "conjugations" (
    "id" SERIAL NOT NULL,
    "verb_id" INTEGER NOT NULL,
    "tense" TEXT,
    "mood" TEXT,
    "voice" TEXT,
    "person" TEXT,
    "greek_form" TEXT,
    "transliteration" TEXT,
    "french_form" TEXT,
    "hidden_part" TEXT,

    CONSTRAINT "conjugations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_verbs" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "verb_id" INTEGER NOT NULL,
    "status" "VerbStatus" NOT NULL DEFAULT 'TO_LEARN',
    "date_added" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_practiced" TIMESTAMP(3),

    CONSTRAINT "user_verbs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "exercises" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "score" DOUBLE PRECISION,
    "completed_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "exercises_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "verb_proposals" (
    "id" SERIAL NOT NULL,
    "submitted_by" INTEGER NOT NULL,
    "verb_id" INTEGER,
    "greek" TEXT,
    "transliteration" TEXT,
    "category_id" INTEGER,
    "status" "ProposalStatus" NOT NULL DEFAULT 'PENDING',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "verb_proposals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "verb_proposal_votes" (
    "id" SERIAL NOT NULL,
    "proposal_id" INTEGER NOT NULL,
    "admin_id" INTEGER NOT NULL,
    "vote" "VoteValue" NOT NULL,
    "comment" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "verb_proposal_votes_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "user_verbs_user_id_verb_id_key" ON "user_verbs"("user_id", "verb_id");

-- CreateIndex
CREATE UNIQUE INDEX "verb_proposal_votes_proposal_id_admin_id_key" ON "verb_proposal_votes"("proposal_id", "admin_id");

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "verbs" ADD CONSTRAINT "verbs_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "translations" ADD CONSTRAINT "translations_verb_id_fkey" FOREIGN KEY ("verb_id") REFERENCES "verbs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conjugations" ADD CONSTRAINT "conjugations_verb_id_fkey" FOREIGN KEY ("verb_id") REFERENCES "verbs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_verbs" ADD CONSTRAINT "user_verbs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_verbs" ADD CONSTRAINT "user_verbs_verb_id_fkey" FOREIGN KEY ("verb_id") REFERENCES "verbs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exercises" ADD CONSTRAINT "exercises_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "verb_proposals" ADD CONSTRAINT "verb_proposals_submitted_by_fkey" FOREIGN KEY ("submitted_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "verb_proposals" ADD CONSTRAINT "verb_proposals_verb_id_fkey" FOREIGN KEY ("verb_id") REFERENCES "verbs"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "verb_proposals" ADD CONSTRAINT "verb_proposals_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "verb_proposal_votes" ADD CONSTRAINT "verb_proposal_votes_proposal_id_fkey" FOREIGN KEY ("proposal_id") REFERENCES "verb_proposals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "verb_proposal_votes" ADD CONSTRAINT "verb_proposal_votes_admin_id_fkey" FOREIGN KEY ("admin_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
