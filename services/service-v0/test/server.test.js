import test from 'node:test';
import assert from 'node:assert/strict';
import {createServer} from '../src/server.js';
async function withServer(query, callback) {
  const server = createServer({query});
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  try {await callback(`http://127.0.0.1:${server.address().port}`);} finally {await new Promise(resolve => server.close(resolve));}
}
test('liveness works while the DB is unavailable; readiness does not leak errors', async () => {
  await withServer(async () => {throw new Error('password=secret endpoint=private');}, async base => {
    assert.equal((await fetch(base+'/healthz')).status, 200);
    const response = await fetch(base+'/readyz');assert.equal(response.status,503);
    assert.doesNotMatch(await response.text(), /secret|private|password/);
  });
});
test('readiness actually checks SELECT 1', async () => {
  let sql;await withServer(async value => {sql=value;},async base=>{
    const response=await fetch(base+'/readyz');assert.equal(response.status,200);assert.equal(sql,'SELECT 1');assert.equal((await response.json()).database,'connected');
  });
});
test('unknown routes and writes fail', async()=>withServer(async()=>{},async base=>{
 assert.equal((await fetch(base+'/missing')).status,404);assert.equal((await fetch(base+'/',{method:'POST'})).status,405);
}));
