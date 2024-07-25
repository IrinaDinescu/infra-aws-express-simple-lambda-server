import serverlessExpress from 'aws-serverless-express';
import { Handler } from 'aws-lambda';
import app from './index';

const server = serverlessExpress.createServer(app);

export const handler: Handler = async (event, context) => {
  return serverlessExpress.proxy(server, event, context);
};
