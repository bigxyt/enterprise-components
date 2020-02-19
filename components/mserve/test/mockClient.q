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
/V/ 1.0
/S/ A test client process for mserve tests

system"l ",getenv[`EC_QSL_PATH],"/sl.q";
.sl.init[`mservClient];


.sl.lib["cfgRdr/cfgRdr"]; / check which are necessary 
.sl.lib["qsl/handle"]; 

.msrvc.results:();
.msrvc.p.resCallback:{ [res] .msrvc.results,:enlist res; };

.msrvc.p.query:{[n] :({[n] t:.mockBack.query[n];:(`.msrvc.p.resCallback;t)};n) };

.msrvc.p.mservPo:{[id].log.info[`msrvc]"Connection to ",(string id)," has been opened";};

/F/ sends a specified number of long queries to mserve
/P/ n:LONG - nmber of queries 
.msrvc.runLongQuery:{[n]
  // send n long queries
  .hnd.ah[`t.mserve] each .msrvc.p.longQuery each til n;
  };

.msrvc.p.longQuery:{[n] :({[n] t:.mockBack.longQuery[n];:(`.msrvc.p.resCallback;t)};n) };

/F/ runs a test, setting the debug
/P/ n:LONG - nmber of queries 
.msrvc.runTest:{[n]
  // send n queries
  .hnd.ah[`t.mserve] each .msrvc.p.query each til n;
  };

.sl.main:{[flags]
  .hnd.poAdd[`t.mserve;.msrvc.p.mservPo];
  .hnd.hopen[`t.mserve;100i;`eager];
  };
  
.sl.run[`mservClient;`.sl.main;`];
