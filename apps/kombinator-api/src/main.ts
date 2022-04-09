import express from 'express';
import { get } from 'env-var';
import { types } from '@kombo/types';

const app = express();

const port = get('PORT').default(3333).asPortNumber();

app.get('/api', (req, res) => {
  res.send({ message: types() });
});

const server = app.listen(port, () => {
  console.log(`Listening at http://localhost:${port}/api`);
});

server.on('error', console.error);
