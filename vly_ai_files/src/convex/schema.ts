import { authTables } from "@convex-dev/auth/server";
import { defineSchema, defineTable } from "convex/server";
import { Infer, v } from "convex/values";

// default user roles. can add / remove based on the project as needed
export const ROLES = {
  ADMIN: "admin",
  USER: "user",
  MEMBER: "member"
} as const;

export const roleValidator = v.union(
  v.literal(ROLES.ADMIN),
  v.literal(ROLES.USER),
  v.literal(ROLES.MEMBER),
)
export type Role = Infer<typeof roleValidator>;

const schema = defineSchema({
  // default auth tables using convex auth.
  ...authTables, // do not remove or modify

  // the users table is the default users table that is brought in by the authTables
  users: defineTable({
    name: v.optional(v.string()), // name of the user. do not remove
    image: v.optional(v.string()), // image of the user. do not remove
    email: v.optional(v.string()), // email of the user. do not remove
    emailVerificationTime: v.optional(v.number()), // email verification time. do not remove
    isAnonymous: v.optional(v.boolean()), // is the user anonymous. do not remove
    
    role: v.optional(roleValidator), // role of the user. do not remove
  })
    .index("email", ["email"]), // index for the email. do not remove or modify

  // Bracelets table to store bracelet information and QR codes
  bracelets: defineTable({
    patientId: v.id("patients"), // Reference to the patient
    qrCode: v.string(), // QR code data/URL
    details: v.string(), // Additional bracelet details
    createdAt: v.number(), // Timestamp of creation
    updatedAt: v.number(), // Timestamp of last update
  })
    .index("by_patient", ["patientId"]), // Index to quickly lookup bracelets by patient

  // Patients table to store patient information
  patients: defineTable({
    name: v.string(),
    dateOfBirth: v.string(), // Store as ISO string
    ssn: v.string(), // Note: Consider encryption for SSN storage
    allergies: v.array(v.string()),
    medicalHistory: v.string(),
    createdAt: v.number(),
    updatedAt: v.number(),
    createdBy: v.id("users"), // Reference to user who created the patient
  })
    .index("by_created_by", ["createdBy"]) // Index to lookup patients by creator
    .index("by_name", ["name"]) // Index to search patients by name

},
{
  schemaValidation: false
});

export default schema;