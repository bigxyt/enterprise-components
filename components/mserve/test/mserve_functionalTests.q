/L/ Copyright (c) 2019 Big XYT
/-/
/-/ Licensed under the Apache License, Version 2.0 (the "License");
/-/ you may not use this file except in compliance with the License.
/-/ You may obtain a copy of the License at
/-/
/-/   http://www.apache.org/licenses/LICENSE-2.0
/-/
/-/ Unless required by applicable law or agreed to in writing, software
/-/ distributed under the License is distributed on an "AS IS" BASIS,
/-/ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/-/ See the License for the specific language governing permissions and
/-/ limitations under the License.

/A/ Slawomir Kolodynski
/S/ Functional test for the mserve component
/V/ 1.0

.tmserve.testSuite:"mserve functional tests";

.tmserve.setUp:{
  .log.info[`tmserv]"starting services";
  .test.start `mock.backend_0`mock.backend_1`mock.backend_2`mock.backend_3`mock.backend_4;
  .test.start `t.mserve;
  .test.start `t.client;
  .log.info[`tmserv]"services started";
  };


.tmserve.tearDown:{
  .test.stop `t.client;
  .test.stop `t.mserve;
  .test.stop `mock.backend_0`mock.backend_1`mock.backend_2`mock.backend_3`mock.backend_4;
  };

.tmserve.test.case0:{
  .assert.remoteWaitUntilEqual["client should connect to mserve ";`t.client;".hnd.status[`t.mserve;`state]";`open;100;1000];
  .hnd.oh[`t.client]".msrvc.runTest[5]";
  .assert.remoteWaitUntilEqual["all 5 services should be queried";`t.client;"asc .msrvc.results @\\: 0";til 5;1000;10000];
  };

.tmserve.test.case1:{
  .assert.remoteWaitUntilEqual["client should connect to mserve ";`t.client;".hnd.status[`t.mserve;`state]";`open;100;1000];
  .assert.match["mserve signals slave crash";
                .hnd.oh[`t.client]".hnd.Dh[enlist `t.mserve;enlist (`.mockBack.exit;1)]";
                enlist (`SIGNAL;"disconnected while processing query")];
  };

.tmserve.test.case2:{
  .assert.remoteWaitUntilEqual["client should connect to mserve ";`t.client;".hnd.status[`t.mserve;`state]";`open;100;1000];
  .hnd.oh[`t.mserve]".mserv.setLogMode `DEBUG";
  .hnd.oh[`t.client]".msrvc.runLongQuery[1]";
  .hnd.oh[`t.client]".hnd.hclose[`t.mserve]";
  .assert.remoteWaitUntilEqual["message should be dropped from queue on mserve ";`t.mserve;"all 0 in/: count each .mserv.h ";1b;100;15000];
  .assert.match["query will not return to the client";.hnd.oh[`t.client]".msrvc.results"; ()];
  .hnd.oh[`t.client]".hnd.hopen[`t.mserve;100i;`eager]";
  .hnd.oh[`t.client]".msrvc.runTest[5]";
  .assert.remoteWaitUntilEqual["message should be dropped from queue on mserve ";`t.mserve;"all 0 in/: count each .mserv.h ";1b;100;15000];
  .assert.remoteWaitUntilEqual["all 5 services should be queried";`t.client;"asc .msrvc.results @\\: 0";til 5;1000;6000];
  };


.tmserve.test.case3:{
  .assert.remoteWaitUntilEqual["client should connect to mserve ";`t.client;".hnd.status[`t.mserve;`state]";`open;100;1000];
  .hnd.oh[`t.client]".msrvc.runLongQuery[1]";
  .hnd.oh[`t.client]".hnd.hclose[`t.mserve]";
  .assert.remoteWaitUntilEqual["message should be dropped from queue on mserve ";`t.mserve;"all 0 in/: count each .mserv.h ";1b;100;15000];

  };

.tmserve.test.withDbg:{
  .assert.remoteWaitUntilEqual["client should connect to mserve ";`t.client;".hnd.status[`t.mserve;`state]";`open;100;1000];
  .hnd.oh[`t.mserve]".mserv.setLogMode `DEBUG";
  .hnd.oh[`t.client]".msrvc.runTest[5]";
  .assert.remoteWaitUntilEqual["all 5 services should be queried";`t.client;"asc .msrvc.results @\\: 0";til 5;1000;6000];
  };
