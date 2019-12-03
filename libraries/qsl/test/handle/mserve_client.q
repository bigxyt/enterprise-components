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
/S/ A test client process for testing .hnd.dh 

system"l ",getenv[`EC_QSL_PATH],"/sl.q";
.sl.init[`mservClient];

.sl.lib["cfgRdr/cfgRdr"]; / check which are necessary 
.sl.lib["qsl/handle"]; 

.msrvc.p.mservPo:{[id].log.info[`msrvc]"Connection to ",(string id)," has been opened";};

/F/ runs a test, setting the debug
.msrvc.runTest:{
  
  };

.sl.main:{[flags]
  .hnd.poAdd[`t.mserve1;.msrvc.p.mservPo];
  .hnd.hopen[`t.mserve1;100i;`eager];
  .hnd.poAdd[`t.mserve2;.msrvc.p.mservPo];
  .hnd.hopen[`t.mserve2;100i;`eager];
  };
  
.sl.run[`mservClient;`.sl.main;`];
