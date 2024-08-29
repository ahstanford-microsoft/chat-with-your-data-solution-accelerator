// Import the necessary functions from MSW
import { setupWorker, rest } from 'msw';

// Define the request handlers
const handlers = [
  // Handler for GET /example
  rest.get('/example', (req, res, ctx) => {
    return res(
      ctx.status(200),
      ctx.json({ message: "Hello, world!" })
    );
  }),

  // Handler for POST /history/read with a valid GUID
  rest.post('/api/history/read', (req, res, ctx) => {
    const { conversation_id } = req.body;

    // Validate the GUID format
    const guidRegex = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/;
    if (guidRegex.test(conversation_id)) {
      return res(
        ctx.status(200),
        ctx.json({
          conversation_id: conversation_id,
          messages: [
            {
              content: "data ",
              createdAt: "2024-08-16T23:37:35.414232",
              feedback: null,
              id: "d9f47663-4a6f-4ae6-9712-ee4f3685b0c1",
              role: "user"
            }
          ]
        }),
        ctx.delay(100) // Optional delay to simulate real server response time
      );
    } else {
      return res(
        ctx.status(400),
        ctx.json({ error: "Invalid GUID format" })
      );
    }
  }),

  // Handler for POST /history/read with a bad request
  rest.post('/api/history/read', (req, res, ctx) => {
    return res(
      ctx.status(400),
      ctx.json({ error: "Error in the request" })
    );
  }),

  // Handler for POST /history/read with a server error
  rest.post('/api/history/read', (req, res, ctx) => {
    return res(
      ctx.status(500),
      ctx.json({ error: "Server error" })
    );
  }),

  // Handler for GET /api/history/list
  rest.get('/api/history/list', (req, res, ctx) => {
    // Simulate different responses based on some condition or randomly
    const randomResponse = Math.floor(Math.random() * 3);

    if (randomResponse === 0) {
      return res(
        ctx.status(400),
        ctx.json({ error: "Error in the request" })
      );
    } else if (randomResponse === 1) {
      return res(
        ctx.status(500),
        ctx.json({ error: "Server error" })
      );
    } else {
      return res(
        ctx.status(200),
        ctx.json([
          {
            "_attachments": "attachments/",
            "_etag": "\"0500efd3-0000-0200-0000-66bfe1210000\"",
            "_rid": "F+9-AIq9dQHVngAAAAAAAA==",
            "_self": "dbs/F+9-AA==/colls/F+9-AIq9dQE=/docs/F+9-AIq9dQHVngAAAAAAAA==/",
            "_ts": 1723851041,
            "createdAt": "2024-08-16T23:30:41.602059",
            "id": "e0076833-6b64-408c-8c99-8ee77a147f5d",
            "title": "Data conversation title requested",
            "type": "conversation",
            "updatedAt": "2024-08-16T23:30:41.623074",
            "userId": "00000000-0000-0000-0000-000000000000"
          }
        ])
      );
    }
  })
];

// Set up the service worker
const worker = setupWorker(...handlers);

// Start the service worker
worker.start();