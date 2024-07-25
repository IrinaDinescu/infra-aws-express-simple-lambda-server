import { Handler } from 'aws-lambda';
import serverless from 'serverless-http';
import app from './index';

const server = serverless(app);

export const handler: Handler = async (event, context) => {
  return server(event, context);
};
