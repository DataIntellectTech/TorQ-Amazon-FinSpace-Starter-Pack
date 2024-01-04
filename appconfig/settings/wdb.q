// Bespoke WDB settings for AWS finspace Starter Pack
\d .wdb
replay:0b;    //set replay to false so that replay isnt carried out during intial subscribe process
upd:{[t;x]};    //set upd to discard data until the end of period signals the start of new period

