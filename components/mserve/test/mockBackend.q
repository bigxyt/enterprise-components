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
/S/ Mock backend process for mserve tests

system"l ",getenv[`EC_QSL_PATH],"/sl.q";
.sl.init[`mockBack];

.sl.lib["cfgRdr/cfgRdr"]; / check which are necessary 
.sl.lib["qsl/handle"]; 

.mockBack.query:{[queryId] 
  system "sleep 1";
  :(queryId;.mockBack.cfg.instance) 
  };

.sl.main:{[flags]
  .mockBack.cfg.instance:value .cr.getCfgField[`THIS;`group;`EC_COMPONENT_INSTANCE];
  .log.info[`mockBack] "Mock backend process started, instance:",.Q.s1 .mockBack.cfg.instance;
  };
  
.sl.run[`mockB;`.sl.main;`];



