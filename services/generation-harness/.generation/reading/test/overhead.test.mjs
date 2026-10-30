import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { measureOverhead } from '../bench/overhead.mjs';
test('declarations stay small and registration does no domain initialization',async()=>{
 const m=await measureOverhead({warmups:5,iterations:20});assert.ok(m.declarationBytes<=16384);
 assert.deepEqual(m.registration,{contractReads:0,vectorReads:0,sourceReads:0,schemaCompiles:0});
 assert.equal(m.firstUse.contractReads,1);assert.equal(m.firstUse.contractParses,1);
 assert.equal(m.concurrentFirstUse.contractReads,1);assert.equal(m.concurrentFirstUse.contractParses,1);
 assert.equal(m.timings.registrationDelta.samples.length,20);assert.equal(m.timings.warmQuestion.samples.length,20);assert.equal(m.timings.warmExam100.samples.length,20);
});
