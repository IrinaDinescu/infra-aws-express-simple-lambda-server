import express, { Request, Response } from 'express';

const app = express();
const PORT = 3000;

app.use(express.json());

app.get('/', (req: Request, res: Response) => {
  res.send('Hello!');
});

app.get('/hello', (req: Request, res: Response) => {
  console.log('/hello route was hit!');
  res.send('Hello from hello!');
});

// Start the server if running locally
if (process.env.NODE_ENV !== 'lambda') {
  app.listen(PORT, () => {
    console.log(`Server is running at http://localhost:${PORT}`);
  });
}

export default app;
