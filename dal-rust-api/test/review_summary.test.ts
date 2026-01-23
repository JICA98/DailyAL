import { describe, expect, test } from "bun:test";

const API_URL = "http://localhost:8001";
const TOKEN = process.env.BEARER_SECRET;

// Sample reviews since the original dataset was truncated in the prompt.
// This is sufficient to test the flow.
const reviews = [
    "One Piece is an absolute masterpiece. The world-building is unmatched, and the characters feel like real friends.",
    "The pacing can be a bit slow at times, especially in the anime adaptation. Toei Animation drags out scenes too much.",
    "Oda is a genius. The foreshadowing is incredible sometime. Events from hundreds of chapters ago pay off in unexpected ways."
];

describe("Review Summary Flow", () => {
    test("POST /reviews should return a structured summary", async () => {
        console.log(`Testing against ${API_URL} with token ${TOKEN.substring(0, 5)}...`);

        const response = await fetch(`${API_URL}/reviews`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${TOKEN}`
            },
            body: JSON.stringify(reviews),
        });

        // Debugging output if request fails
        if (!response.ok) {
            console.error("Response status:", response.status);
            console.error("Response text:", await response.text());
        }

        expect(response.status).toBe(200);

        const data = await response.json();
        console.log("Response data:", JSON.stringify(data, null, 2));

        expect(data).toHaveProperty("pros");
        expect(data).toHaveProperty("cons");
        expect(data).toHaveProperty("verdict");

        // Pros and Cons should be arrays of objects with title and description
        expect(Array.isArray(data.pros)).toBe(true);
        if (data.pros.length > 0) {
            expect(data.pros[0]).toHaveProperty("title");
            expect(data.pros[0]).toHaveProperty("description");
        }

        expect(Array.isArray(data.cons)).toBe(true);
        if (data.cons.length > 0) {
            expect(data.cons[0]).toHaveProperty("title");
            expect(data.cons[0]).toHaveProperty("description");
        }

        expect(typeof data.verdict).toBe("string");
        expect(data.verdict.length).toBeGreaterThan(0);

    }, 60000); // 60s timeout for LLM
});
