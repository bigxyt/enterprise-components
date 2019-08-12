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
/T/ q mserve.q

/S/ Integration of https://github.com/KxSystems/kdb/blob/master/e/mserve.q in Enterprise Components
system"l ",getenv[`EC_QSL_PATH],"/sl.q";
.sl.init[`mserv];

.sl.lib["cfgRdr/cfgRdr"];
.sl.lib["qsl/handle"];

/F/ checks if the function name starts with given symbol, followed by _<digit>
/P/ proc:SYMBOL - clone name (i.e. core.hdb_0)
/P/ base:SYMBOL - base of the clone
/R/ :BOOL - true if of the proc is of the form base_<number>
/E/ .mserve.p.isCloneOf[`core.hdb_0;`core.hdb]
.mserv.p.isCloneOf:{[proc;base]
  sbase:string base;
  if[not proc like sbase,"_*";:0b];
  // check if suffix of the form _<integer>
  :all ((1+count sbase)_string proc) in\:"1234567890"
  };

/G/ mapping from process id to the asynchronous handle.
/-/ This is needed for the pc callback that runs when the handles in .hnd.status are not available any more
.mserv.p.activeSources:()!();

/G/ dictionary that remembers the handles from which requests came that have been sent to the data source processes
/-/ The key are (asynchronous) data source handles, the values are lists of originating handles.
.mserv.h:()!();

/F/ The port open callback
.mserv.p.sourcePo:{[id]
  .log.info[`mserv]"Connection to ",(string id)," has been opened";
  .mserv.p.activeSources[id]:.hnd.status[id;`ashandle];
  .mserv.h[.hnd.status[id;`ashandle]]:();
  };

/F/ The port close callback.
.mserv.p.sourcePc:{[id]
  .log.warn[`mserv]"Connection to ",(string id)," has been closed";
  .mserv.h:(enlist .mserv.p.activeSources[id]) _ .mserv.h;
  };
  
/F/ The overwrite for .z.ps
.mserv.p.ps:{
  $[(w:neg .z.w)in key .mserv.h;
    [.mserv.h[w;0]x;.mserv.h[w]:1_.mserv.h w];
    [.mserv.h[a?:min a:count each .mserv.h],:w;a("{(neg .z.w)@[value;x;`error]}";x)]
  ]
  };


/F/ The overwrite for .z.ps, the debug version that shows asynchronous queries on the console
.mserv.p.psDbg:{
  // DBG
  show "query: ",.Q.s1 x;
  $[(w:neg .z.w)in key .mserv.h;
    [show "this is a server response";.mserv.h[w;0]x;.mserv.h[w]:1_.mserv.h w];
    [show "this is a client request";.mserv.h[a?:min a:count each .mserv.h],:w;a("{(neg .z.w)@[value;x;`error]}";x);show "sent to handle ",(.Q.s1 a)," query ",.Q.s1 ("{(neg .z.w)@[value;x;`error]}";x);.dbg.lastQuery:("{(neg .z.w)@[value;x;`error]}";x)]
  ]
  };


/==============================================================================/
/F/ Main function for the mserve component.
/P/ flags:LIST - nyi
/R/ no return value
/E/ .sl.main `
.sl.main:{[flags]
  .mserv.cfg.dataSource:.cr.getCfgField[`THIS;`group;`cfg.dataSource];
  procs:exec proc from .cr.getByProc[`host`port];
  .mserv.cfg.dataSources:procs where procs .mserv.p.isCloneOf\: .cr.getCfgField[`THIS;`group;`cfg.dataSource];
  if[0~count .mserv.cfg.dataSources;
    .log.fatal[`mserv] "no clones of the data source ",(string .cr.getCfgField[`THIS;`group;`cfg.dataSource])," found"
    ];
  .mserv.cfg.dataSources .hnd.poAdd\: `.mserv.p.sourcePo;
  .mserv.cfg.dataSources .hnd.pcAdd\: `.mserv.p.sourcePc;
  .hnd.hopen[.mserv.cfg.dataSources; 100i; `eager];
  .z.ps:.mserv.p.ps;
  };
/G/ Path to the actual hdb directory.
/------------------------------------------------------------------------------/
//initialization
.sl.run[`mserv;`.sl.main;`];